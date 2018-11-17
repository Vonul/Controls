// Lab #5 - Nathan Isaman

// Includes
#include <stdio.h>
#include "MyRio.h"
#include "DIO.h"
#include "me477.h"
#include <unistd.h>
#include "DIIRQ.h"
#include "IRQConfigure.h"
#include <pthread.h>
#include <string.h>

// Prototypes
void wait(void);
void *DI_Irq_Thread(void*);

// Definitions
typedef struct {
	NiFpga_IrqContext irqContext; 							// IRQ context reserved
	NiFpga_Bool irqThreadRdy; 								// IRQ thread ready flag
	uint8_t irqNumber; 										// IRQ number value
} ThreadResource;

int32_t status;												//---------------------------
MyRio_IrqDi irqDI0;											// Interrupt thread variables
ThreadResource irqThread0;									//
pthread_t thread;											//---------------------------

int main(int argc, char **argv){
// Main
// The purpose of this function is to increment a "time" counter from 0 to 60 using the wait() function
// and servicing interrupts when they are triggered by a hardware switch.
// Inputs: integer argc and character argv
// Outputs: MyRio status

	int i, tcount=0;
	NiFpga_Status statusO;


    statusO = MyRio_Open();		   							// Open the myRIO NiFpga Session.
    if (MyRio_IsNotSuccess(statusO)) return statusO;

    // Configure the DI IRQ
    const uint8_t IrqNumber = 2;
    const uint32_t Count = 1;
    const Irq_Dio_Type TriggerType = Irq_Dio_FallingEdge;

    // Specify IRQ channel settings
    irqDI0.dioChannel = Irq_Dio_A0;
    irqDI0.dioIrqNumber = IRQDIO_A_0NO;
    irqDI0.dioCount = IRQDIO_A_0CNT;
    irqDI0.dioIrqRisingEdge = IRQDIO_A_70RISE;
    irqDI0.dioIrqFallingEdge = IRQDIO_A_70FALL;
    irqDI0.dioIrqEnable = IRQDIO_A_70ENA;

    // Initiate the IRQ number resource for new thread.
    irqThread0.irqNumber = IrqNumber;

    // Register DI0 IRQ. Terminate if not successful
    status=Irq_RegisterDiIrq(&irqDI0,&(irqThread0.irqContext),IrqNumber,Count,TriggerType);

    // Set the indicator to allow the new thread.
    irqThread0.irqThreadRdy = NiFpga_True;

    // Create new thread to catch the IRQ.
    status = pthread_create(&thread,NULL,DI_Irq_Thread,&irqThread0);

    //main code here
    while(tcount<=60){										// main() will count up for ~60 seconds
    	printf_lcd("\f\vCount: %d",tcount);					// Prints current "time" count on LCD
    	for(i=0; i<200; i++){								// One second delay (200 calls x 5ms)
    		wait();											// wait() consumes about 5ms of time per call
    	}
    	tcount++;											// increment time count by 1 second.
    }

    irqThread0.irqThreadRdy = NiFpga_False;					// Signal new thread to terminate
    pthread_join(thread,NULL);

    // Unregistering the interrupt
    int32_t Irq_UnregisterDiIrq( MyRio_IrqDi* irqChannel,NiFpga_IrqContext irqContext,uint8_t irqNumber);

	statusO = MyRio_Close();	 							// Close the myRIO NiFpga Session.
	return statusO;
}


void *DI_Irq_Thread(void* resource){
// DI_Irq_Thread: Interrupt service function
// The purpose of this function is to service the interrupt when the button on the breadboard is
// pressed.
// Inputs: resource
// Outputs: Null.
    ThreadResource* threadResource = (ThreadResource*) resource;
    while (threadResource->irqThreadRdy == NiFpga_True){	// while the main thread does not signal this thread to stop
    	 uint32_t irqAssert = 0;
    	 Irq_Wait( threadResource->irqContext,				// wait for the occurrence or time out of IRQ
    	    			threadResource->irqNumber,
    	    			&irqAssert,
    	    			(NiFpga_Bool*) &(threadResource->irqThreadRdy));

    	 if (irqAssert & (1 << threadResource->irqNumber)){	// If the numbered IRQ has been asserted
    	 	printf_lcd("\nInterrupt_");						// Message printed to LCD when button pressed
    	 	Irq_Acknowledge(irqAssert);						// Interrupt acknowledged to the scheduler
    	 }
    }
	pthread_exit(NULL);										// Terminates the new thread
	return NULL;											// Returns to main() function
}

void wait(void) {
	// wait function
	// Function kills time (approx. 5ms using a 667MHz processor)
	// Input: None
	// Output: None
	uint32_t i;
	i = 417000;
	while(i>0){
		i--;
	}
	return;
}
