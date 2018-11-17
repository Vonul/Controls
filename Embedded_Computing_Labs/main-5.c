// Lab #6 - Nathan Isaman

// includes
#include "MyRio.h"
#include "stdio.h"
#include "me477.h"
#include <string.h>
#include <pthread.h>
#include <IRQConfigure.h>
#include "AIO.h"
#include "TimerIRQ.h"
#include "matlabfiles.h"

// Global Variables
struct biquad {
	double b0; double b1; double b2; 						// numerator
	double a0; double a1; double a2; 						// denominator
	double x0; double x1; double x2;						// input
	double y1; double y2; }; 								// output

typedef struct {
	NiFpga_IrqContext irqContext; // IRQ context reserved
	NiFpga_Bool irqThreadRdy; // IRQ thread ready flag
} ThreadResource;

int myFilter_ns = 2; 										// No. of sections
uint32_t timeoutValue = 500; 								// T - us; f_s = 2000 Hz
int32_t status;
NiFpga_Session myrio_session;
MyRio_IrqTimer irqTimer0;
ThreadResource irqThread0;
pthread_t thread;

MyRio_Aio CI0, CO0;

int count=0;
int err;
double output[500];											// Output buffer
double *o=output;											// Output buffer pointer

// prototypes
double cascade(int ns, double xin, struct biquad *fa);
void *Timer_Irq_Thread(void*);

// definitions
#define VDAmax +5.											// Saturation limit set to preserve hardware
#define VDAmin -5.
#define SATURATE(x,lo,hi) ((x) < (lo) ? (lo) : (x) > (hi) ? (hi): (x))


int main(int argc, char **argv){
// main function
// The purpose of this function is to execute the high level functions of a continuous loop
// and saving the output buffer data in a MATLAB file.
// Inputs: argc, argv
// Outputs: status


	NiFpga_Status statusO;
	MATFILE *mf;											// MATLAB file pointer

    statusO = MyRio_Open();		   				 			// Open the myRIO NiFpga Session.
    if (MyRio_IsNotSuccess(statusO)) return statusO;

    // Specify IRQ channel settings
    irqTimer0.timerWrite = IRQTIMERWRITE;
    irqTimer0.timerSet = IRQTIMERSETTIME;
    timeoutValue = 500;

    // Initialize analog interfaces before allowing IRQ
    AIO_initialize(&CI0, &CO0); 							// initialize analog I/O
    Aio_Write(&CO0, 0.0); 									// zero analog output

    // Configure Timer IRQ. Terminate if not successful
    status = Irq_RegisterTimerIrq(
    		&irqTimer0,
    		&irqThread0.irqContext,
    		timeoutValue);

    // Set the indicator to allow the new thread.
    irqThread0.irqThreadRdy = NiFpga_True;

    // Create new thread to catch the IRQ.
    status = pthread_create(
    		&thread,
    		NULL,
    		Timer_Irq_Thread,
    		&irqThread0);

    // main loop
    while(getkey()!=DEL){
    	//Continue until DEL button pushed
    }
    printf_lcd("Filter Terminated");						// message to user on LCD (DEL success)

    irqThread0.irqThreadRdy = NiFpga_False;					// Signal new thread to terminate
    pthread_join(thread,NULL);

    // Unregistering the interrupt
    status = Irq_UnregisterTimerIrq(
    		&irqTimer0,
    		irqThread0.irqContext);

    // MATLAB file creation and population
    mf=openmatfile("Lab6.mat", &err);
    if(!mf){
    	printf("Error \n%d", err);
    }
    matfile_addstring(mf,"MyName","Nathan Isaman");
    matfile_addmatrix(mf,"y",output,500,1,0);
    matfile_close(mf);

	statusO = MyRio_Close();	 // Close the myRIO NiFpga Session.
	return statusO;
}

void *Timer_Irq_Thread(void* resource){
// Timer_Irq_Thread: Interrupt service routine
// The purpose of this function is to service the timer-based interrupt and call the
// cascade function in order to process a new input/output.
// Inputs: resource
// Outputs: Null.
	struct biquad *fa;
	static struct biquad myFilter[] = {
		{1.0000e+00, 9.9999e-01, 0.0000e+00,
		1.0000e+00, -8.8177e-01, 0.0000e+00, 0, 0, 0, 0, 0},	// Biquad initial conditions and
		{2.1878e-04, 4.3755e-04, 2.1878e-04,					// coefficient values
		1.0000e+00, -1.8674e+00, 8.8220e-01, 0, 0, 0, 0, 0}
	};
	double y,xin;
	y=SATURATE(y,VDAmin,VDAmax);

    ThreadResource* threadResource = (ThreadResource*) resource;

    while (threadResource->irqThreadRdy == NiFpga_True){		// while the main thread does not signal this thread to stop
    	uint32_t irqAssert = 0;
    	Irq_Wait( threadResource->irqContext,					// IRQ wait and timer scheduling
    			TIMERIRQNO,										// written here
    			&irqAssert,
    			(NiFpga_Bool*) &(threadResource->irqThreadRdy));
    	NiFpga_WriteU32( myrio_session,
    			IRQTIMERWRITE,
    			timeoutValue);
    	NiFpga_WriteBool( myrio_session,
    			IRQTIMERSETTIME,
    			NiFpga_True);

    	if (irqAssert){											// If the numbered IRQ has been asserted
    		xin=Aio_Read(&CI0);									// x input from analog input
    		y=cascade(myFilter_ns,xin,myFilter);				// cascade function called on timer interrupt
    	 	if(count<500){
    	 		*o=y;											// save output to buffer
    	 		o++;											// increment buffer and counter
    	 		count++;
    	 	}
    	 	else{
    	 		count=0;										// reset count
    	 		o=output;  										// reset pointer to beginning of circular buffer
    	 	}

    		Aio_Write(&CO0,y);
    	 	Irq_Acknowledge(irqAssert);							// Interrupt acknowledged to the scheduler
    	 }
    }
	pthread_exit(NULL);											// Terminates the new thread
	return NULL;												// Returns to main() function
}


double cascade(int ns, double xin, struct biquad *fa){
// (Biquad) Cascade function
// The purpose of this function is to take in xin and use a difference equation to develop the output y0.
// Xin comes from the analog input and the difference equation utilizes a biquad structure.
// Inputs: ns, xin, and *fa
// Outputs: y0
	double y0=xin;
	int i;
	struct biquad *f=fa;

	for(i=0; i<ns; i++){
		f->x0=y0;												// The following lines implement the difference
																// equation and push variables (i.e. y_old=y_new)
		y0 = (f->b0*f->x0 + f->b1*f->x1 + f->b2*f->x2 - f->a1*f->y1 - f->a2*f->y2) /f->a0;

		f->y2 = f->y1;
		f->y1 = y0;

		f->x2 = f->x1;
		f->x1 = f->x0;

		f++;													// Incrementing pointer to next biquad structure
	}

	return y0;
}

