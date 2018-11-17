// Lab #8 - Nathan Isaman

// includes
#include "MyRio.h"
#include "stdio.h"
#include "me477.h"
#include <string.h>
#include <pthread.h>
#include <IRQConfigure.h>
#include "AIO.h"
#include "TimerIRQ.h"
#include "ctable.h"
#include "matlabfiles.h"

// Global Variables
struct biquad {
	double b0; double b1; double b2; 						// numerator
	double a0; double a1; double a2; 						// denominator
	double x0; double x1; double x2;						// input
	double y1; double y2; }; 								// output

typedef struct {											// Resource for Timer thread
	NiFpga_IrqContext irqContext; 							// context
	struct table *a_table; 									// table of variables
	NiFpga_Bool irqThreadRdy; 								// ready flag
} ThreadResource;

typedef struct {											// Resource for Update thread
	long int looptime_ns;									// IRQ loop time in nanoseconds
	NiFpga_Bool irqThreadRdy; 								// IRQ thread ready flag
} ThreadResource2;

MyRio_Encoder encC0;
int myFilter_ns = 1; 										// No. of biquad cascade sections
uint32_t timeoutValue = 5000;								// Initial
MyRio_Aio CI0, CO0;
NiFpga_Session myrio_session;
int buffcount=0;


//MATLAB Data Arrays and pertinent variables
double V_act_data[1000];
double Torque_data[1000];
double V_ref_c, V_ref_p, Kp_data, Ki_data, BTI_data;
double *o=V_act_data;
double *t=Torque_data;


// prototypes
double cascade(int ns, double xin, struct biquad *fa);
void *Timer_Irq_Thread(void* resource);
void *Table_Update_Thread(void* resource);
double vel(void);

// definitions
#define VDAmax +10.											// Saturation limit set to preserve hardware
#define VDAmin -10.
#define SATURATE(x,lo,hi) ((x) < (lo) ? (lo) : (x) > (hi) ? (hi): (x))


int main(int argc, char **argv){
// main function
// The purpose of this function is to initialize I/O, (un)register threads, and call ctable().
//
// Inputs: argc, argv
// Outputs: status
	NiFpga_Status statusO;
	int32_t status;
	MyRio_IrqTimer irqTimer0;
	ThreadResource irqThread0;
	ThreadResource2 updateThread;
	pthread_t thread, thread2;

    statusO = MyRio_Open();		   				 			// Open the myRIO NiFpga Session.
    if (MyRio_IsNotSuccess(statusO)) return statusO;

	char *Table_Title = "Control Table";
	static struct table controlTable[] = {
		{"V_ref [rpm]:",1,0.0},
		{"V_act [rpm]:",0,0.0},
		{"VDAout [mV]:",0,0.0},
		{"Kp  [V-s/r]:",1,0.0},
		{"Ki    [V/r]:",1,0.0},
		{"BTI    [ms]:",1,5.0}
	};

    // Specify IRQ channel settings
    irqTimer0.timerWrite = IRQTIMERWRITE;
    irqTimer0.timerSet = IRQTIMERSETTIME;

    // Initialize analog interfaces before allowing IRQ
    AIO_initialize(&CI0, &CO0); 							// initialize analog I/O
    Aio_Write(&CO0, 0.0); 									// zero analog output

    // Initialize the encoder
	EncoderC_initialize(myrio_session,&encC0);

    // Configure Timer IRQ. Terminate if not successful
    status = Irq_RegisterTimerIrq(
    		&irqTimer0,
    		&irqThread0.irqContext,
    		timeoutValue);

    // Set the indicator to allow the new thread.
    irqThread0.irqThreadRdy = NiFpga_True;
    updateThread.irqThreadRdy = NiFpga_True;
    irqThread0.a_table = controlTable;
    updateThread.looptime_ns = 500000000L;

    //Create new thread to catch timer IRQ.
    status = pthread_create(
    		&thread,
    		NULL,
    		Timer_Irq_Thread,
    		&irqThread0);

    // Create new thread to catch update IRQ.
    pthread_create(&thread2,
    		NULL,
    		Table_Update_Thread,
    		&updateThread);

    // main code body
    ctable(Table_Title, controlTable, 6);

    // MATLAB file creation and population
    MATFILE *mf;											//MATLAB File
    int err;
    mf=openmatfile("Lab8_NPI.mat", &err);
    if(!mf){
    	printf("Error \n%d", err);
    }
    matfile_addstring(mf,"MyName","Nathan Isaman");
    matfile_addmatrix(mf,"V_act",V_act_data,1000,1,0);
    matfile_addmatrix(mf,"Torque",Torque_data,1000,1,0);
    matfile_addmatrix(mf,"V_ref_c",&V_ref_c,1,1,0);
    matfile_addmatrix(mf,"V_ref_p",&V_ref_p,1,1,0);
    matfile_addmatrix(mf,"Kp",&Kp_data,1,1,0);
    matfile_addmatrix(mf,"Ki",&Ki_data,1,1,0);
    matfile_addmatrix(mf,"BTI",&BTI_data,1,1,0);
    matfile_close(mf);

    // Signal timer and update threads to terminate
    irqThread0.irqThreadRdy = NiFpga_False;
    updateThread.irqThreadRdy = NiFpga_False;
    pthread_join(thread2,NULL);
    pthread_join(thread,NULL);

    // Unregistering the interrupt
    status = Irq_UnregisterTimerIrq(
    		&irqTimer0,
    		irqThread0.irqContext);

    printf_lcd("\fDone.");										// verification message on LCD

	statusO = MyRio_Close();	 								// Close the myRIO NiFpga Session.
	return statusO;
}


void *Timer_Irq_Thread(void* resource){
// Timer_Irq_Thread: Interrupt service routine
// The purpose of this function is to service the timer-based interrupt and call the
// cascade function in order to process a new input/output and then write the value to the motor.
// Inputs: resource
// Outputs: Null.

	ThreadResource* threadResource = (ThreadResource*) resource;

	double *Vref=&((threadResource->a_table+0)->value);			//-----------------------------
	double *Vact=&((threadResource->a_table+1)->value);
	double *VDAout=&((threadResource->a_table+2)->value);		// Convenient pointers for the
	double *Kp=&((threadResource->a_table+3)->value);			// various table elements
	double *Ki=&((threadResource->a_table+4)->value);
	double *BTI=&((threadResource->a_table+5)->value);			//------------------------------

	static struct biquad myFilter[] = {
		{1.0000e+00, 9.9999e-01, 0.0000e+00,
		1.0000e+00, -8.8177e-01, 0.0000e+00, 0, 0, 0, 0, 0},	// Biquad initial conditions and
		{2.1878e-04, 4.3755e-04, 2.1878e-04,					// coefficient values (mutable)
		1.0000e+00, -1.8674e+00, 8.8220e-01, 0, 0, 0, 0, 0}
	};

	timeoutValue = *BTI*1000;									// timeoutValue adjusted based on BTI

    while (threadResource->irqThreadRdy == NiFpga_True){		// while the main thread does not signal this thread to stop
    	uint32_t irqAssert = 0;
    	Irq_Wait( threadResource->irqContext,					// IRQ wait and timer scheduling
    			TIMERIRQNO,										// written
    			&irqAssert,
    			(NiFpga_Bool*) &(threadResource->irqThreadRdy));
    	NiFpga_WriteU32( myrio_session,							// IRQ Wait component
    			IRQTIMERWRITE,
    			timeoutValue);
    	NiFpga_WriteBool( myrio_session,						// IRQ Wait component
    			IRQTIMERSETTIME,
    			NiFpga_True);


    	if (irqAssert){											// If the numbered IRQ has been asserted

    		if (V_ref_c != *Vref){
    			V_ref_p = V_ref_c;
    			V_ref_c = *Vref;
    			o = V_act_data;
    			t = Torque_data;
    			buffcount = 0;
    		}

    		double T=*BTI/1000.0;
    		*Vact=vel()*60.0/(T*2000.0);						// velocity input from the encoder

    		myFilter->a0=1;										//-----------
    		myFilter->a1=-1;									// Updating difference eq coefficients
    		myFilter->b0=*Kp+0.5*T*(*Ki);						//
    		myFilter->b1=(-1)*(*Kp)+0.5*T*(*Ki);				//-----------

    		double en=(*Vref-*Vact)*2*3.1415926/60.0;			// Error value for feedback loop

    		double VDAtest=cascade(myFilter_ns,en,myFilter);	// cascade function called on timer interrupt

    		*VDAout=SATURATE(VDAtest,VDAmin,VDAmax);			// Saturating the output for safety
    		Aio_Write(&CO0,*VDAout);							// Computed control value sent to DAC

    		*VDAout=*VDAout*1000.0;								// Unit conversion for display purposes

    		if (buffcount < 1000){
    			*o=*Vact;										// Storing V_act in buffer for matlab
    			*t=(*VDAout)*0.11*0.41;							// Torque Calculation
    			o++;											// Increment buffer count and pointers
    			t++;
    			buffcount++;
    			Kp_data=*Kp;
    			Ki_data=*Ki;									// Additional MATLAB Variable storage
    			BTI_data=*BTI;
    		}

    		Irq_Acknowledge(irqAssert);							// Interrupt acknowledged to the scheduler
    	 }
    }
	pthread_exit(NULL);											// Terminates the new thread
	return NULL;												// Returns to main() function
}

void *Table_Update_Thread(void* resource){
// Table_Update_Thread: Interrupt service routine
// The purpose of this function is to wait 0.5 seconds using nanosleep() and then update
// the ctable by calling the update() function. These updated values are used in the
// feedback control system implemented in Timer_Irq_Thread.
// Inputs: resource
// Outputs: Null.

    ThreadResource2* threadResource = (ThreadResource2*) resource;

    while (threadResource->irqThreadRdy == NiFpga_True){		// while the main thread does not signal this thread to stop
    	nanosleep((const struct timespec[]){{0, threadResource->looptime_ns}}, NULL);
    	update();
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
	static struct biquad *f;
	f=fa;

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

double vel(void){
	// vel function
	// Function calculates RPM to return to speed() function
	// Input: None
	// Output: double (velocity)
	static int velcalls;
	static int32_t cn, cnm1;
	double BDI;

	cn=Encoder_Counter(&encC0);			// get current encoder count

	if (velcalls==0){					// If this is the first time vel() is called,
		cnm1=cn;						// set the previous velocity to the current
		velcalls++;						// velocity.
	}
	BDI=cn-cnm1;						// current count minus the previous count
	cnm1=cn;							// setting previous count to current count for future iteration

	return BDI;							// returning BDI/BTI to speed() function

}
