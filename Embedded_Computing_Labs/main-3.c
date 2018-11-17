//Lab #4 Nathan Isaman


// includes
#include <stdio.h>
#include "Encoder.h"
#include "MyRio.h"
#include "DIO.h"
#include "me477.h"
#include <unistd.h>
#include <string.h>
#include "matlabfiles.h"

// prototypes
double vel(void);
void initializeSM(void);
void wait(void);
void low(void);
void high(void);
void speed(void);
void stop(void);

// definitions
#define IMAX 2400							// max points (for matlab)

// global variables
NiFpga_Session myrio_session;
MyRio_Encoder encC0;
MyRio_Dio Ch0,Ch6,Ch7;
int exitflag=0;
typedef enum {state_low=0, state_high, state_speed, state_stop} State_Type;
static void (*state_table[])(void)={low, high, speed, stop};
State_Type curr_state; 						// The "current state" for the finite state machine
int Clock,BTI,BTIm1;
double cycle=0.00500151424;					// cycle time for the wait() function in seconds
double M;
double N;

//matlab globals
static double buffer[IMAX];					// speed buffer
static double *bp=buffer;					// buffer pointer

int main(int argc, char **argv){
	// main function
	// Function executes a finite state machine to produce a PWM signal to drive a DC motor.
	// Input: argc, argv
	// Output: status

	NiFpga_Status status;

    status = MyRio_Open();		    				//Open the myRIO NiFpga Session.
    if (MyRio_IsNotSuccess(status)) return status;


    //Duty Cycle Parameters
    M = double_in("\fEnter duty (M): ");
    N = double_in("\fEnter wait (N): ");
    // Initialize the State Machine
    initializeSM();									// sets curr_state to state_low
    while(exitflag==0){
    	state_table[curr_state]();
    	wait();
    	Clock++;
    }

	status = MyRio_Close();	 						// Close the myRIO NiFpga Session.
	return status;
}

void low(void){
	// low function
	// Function sets motor condition to "off"
	// Input: None
	// Output: None
	if( Clock == M ) {
		curr_state = state_high;
		Dio_WriteBit(&Ch0, NiFpga_True);
	}
}

void high(void){
	// high function
	// Function sets motor condition to "on" and checks for Ch6 and Ch7 buttons depression.
	// Input: None
	// Output: None
	if( Clock == N ) {
		Clock=0;
		BTI++;
		int stoptest=Dio_ReadBit(&Ch6);					// checking channel 6 for STOP button state
		int speedtest=Dio_ReadBit(&Ch7);				// checking channel 7 for SPEED button state

		Dio_WriteBit(&Ch0, NiFpga_False);				// send "run" state to motor

		if (stoptest==NiFpga_False){					// switching state to STOP if button is pressed
			curr_state = state_stop;
		}
		else if (speedtest==NiFpga_False && stoptest==NiFpga_True){
			curr_state = state_speed;					// switching state to SPEED if only the SPEED
		}												// button is pressed
		else {
			curr_state = state_low;						// LOW state becomes current state if other
		}												// tests fail
	}
}

void speed(void){
	// speed function
	// Function calls vel() to get RPM from encoder and then prints value on the LCD after data conversion.
	// Input: None
	// Output: None
	double spd=vel();
	double rpm=spd*(60.0/(2000.0*cycle*N));				// unit conversion for rpm
	printf_lcd("\fspeed %g rpm",rpm);
	//if (bp<buffer+IMAX){
		//*bp++=rpm;
	//}
	curr_state = state_low;								// setting current state to low after output
}

void stop(void){
	// stop function
	// Function stops the motor, raises exit flag for main while loop and saves data
	// to a MATLAB file.
	// Input: None
	// Output: None
	int err;
	MATFILE *mf;
	Dio_WriteBit(&Ch0, NiFpga_True);					// turning the motor off
	exitflag++;											// setting exit flag condition for main() loop
	printf_lcd("\f\vStopping Motor...");				// message to the LCD to inform the user

	mf = openmatfile("Lab.mat", &err);					// saving a MATLAB file
	if(!mf){
		printf("Can’t open mat file %d\n", err);
	}

	matfile_addstring(mf, "myName", "Nathan Isaman");
	matfile_addmatrix(mf, "N", &N, 1, 1, 0);
	matfile_addmatrix(mf, "M", &M, 1, 1, 0);
	matfile_addmatrix(mf, "Vel", buffer, IMAX, 1, 0);
	matfile_close(mf);
}

void initializeSM(void){
// initializeSM function
// Function initializes the encoder, motor output, clock, and state
// Input: None
// Output: None

	EncoderC_initialize(myrio_session,&encC0);			// Initialize the encoder

	Ch0.dir = DIOA_70DIR;								// Initialize the communication channels
	Ch0.out = DIOA_70OUT;
	Ch0.in = DIOA_70IN;
	Ch0.bit = 0;

	Ch6.dir = DIOA_70DIR;
	Ch6.out = DIOA_70OUT;
	Ch6.in = DIOA_70IN;
	Ch6.bit = 6;

	Ch7.dir = DIOA_70DIR;
	Ch7.out = DIOA_70OUT;
	Ch7.in = DIOA_70IN;
	Ch7.bit = 7;

	curr_state = state_low;								// starting the motor sequence at LOW
	Dio_WriteBit(&Ch0, NiFpga_True);					// sending low value to motor
	Clock = 0;											// initializing the clock
}


double vel(void){
	// vel function
	// Function calculates RPM to return to speed() function
	// Input: None
	// Output: double (velocity)
	static int velcalls;
	static int32_t cn, cnm1;
	double BDI;
	double dummy;

	cn=Encoder_Counter(&encC0);			// get current encoder count

	if (velcalls==0){					// If this is the first time vel() is called,
		cnm1=cn;						// set the previous velocity to the current
		velcalls++;						// velocity.
	}
	BDI=cn-cnm1;						// current count minus the previous count
	cnm1=cn;							// setting previous count to current count for future iteration
	dummy=BTI-BTIm1;					// placeholder variable for BTI calculation
	BTIm1=BTI;							// setting previous BTI to current BTI value for future iteration

	return BDI/dummy;					// returning BDI/BTI to speed() function

}

void wait(void) {
	// wait function
	// Function kills time (approx 5ms at 667MHz processor)
	// Input: None
	// Output: None
	uint32_t i;
	i = 417000;
	while(i>0){
		i--;
	}
	return;
}
