/* Lab 3 - Nathan Isaman*/

/* includes */
#include "stdio.h"
#include "MyRio.h"
#include "me477.h"
#include "UART.h"
#include "DIO.h"
#include <time.h>
#include <stdarg.h>
#include <string.h>

/* prototypes */
int putchar_lcd(int value);
char getkey(void);
void wait(void);

/* definitions */
MyRio_Dio Ch[8];

int main(int argc, char **argv){
// Main
// The purpose of this function is to perform the high level tasks of requesting
// data entry from the user and properly printing it on the LCD display.
// Inputs: integer argc and character argv
// Outputs: MyRio status

	NiFpga_Status status;
	char key;
	char str1[82];
    status = MyRio_Open();		    /*Open the myRIO NiFpga Session.*/
    if (MyRio_IsNotSuccess(status)) return status;

    //Testing, putchar_lcd (these were commented/uncommented to test)
    putchar_lcd('\f');									// Basic calls to putchar_lcd()
    //wait();
    putchar_lcd('M');
    wait();
    wait();
    //putchar_lcd('\n')
    //putchar_lcd(256);									// tests for beyond range call
    //putchar_lcd(35);
    // wait();
    //wait();
    printf_lcd("\f\vHi, FF\briend \n enter a key: ");	// tests all escape sequences

    // Testing getkey();								// and purchar_lcd() indirectly
    key=getkey();										// individual call to getkey()
    printf_lcd("\fYou entered: %s",&key);				// Feedback to verify accurate
    printf_lcd("\nEnter Another Key: ");				// key capture.
    fgets_keypad(str1,80);								// call to getkey() via fgets_keypad()
    printf_lcd("\f\vYou entered: %s", str1);


	status = MyRio_Close();	 /*Close the myRIO NiFpga Session. */
	return status;
}

int putchar_lcd(int value){
// putchar_lcd
// The purpose of this function is to display a single character or execute an escape
// sequence on the LCD via the MyRio's UART. The character entry is first checked to
// see if it is one of the four prescribed escape sequences, then it is checked to
// ensure it is in the range of acceptable entry values. If the character does not
// trigger any of the initial tests, it is treated as a character to print to the LCD.
// Inputs: character ASCII value  or char in 'x' form
// Outputs: character or EOF

	static int n;
	static MyRio_Uart uart;
	NiFpga_Status status;
	uint8_t writeS[10];
	size_t nData=1;

	if (n==0){									// Initializing UART on first call
		uart.name = "ASRL2::INSTR";				// UART on Connector B
		uart.defaultRM = 0;						// def. resource manager
		uart.session = 0;						// session reference
		status = Uart_Open( &uart,				// port information
							19200,				// baud rate
							8,					// number of data bits
							Uart_StopBits1_0,	// 1 stop bit
							Uart_ParityNone);	// No parity
		n++;
		if (status < VI_SUCCESS){
			return EOF;
		}
	}

	if (value=='\f'){							// Clear screen
		writeS[0] = 12;
		writeS[1] = 17;
		nData = 2;
	}
	else if (value=='\b'){						// Back space
		writeS[0] = 8;
	}
	else if (value=='\v'){						// Cursor to start line 0
		writeS[0] = 128;
	}
	else if (value=='\n'){						// Cursor to start next line
		writeS[0] = 13;
	}
	else if(value > 255) {						// check for arguments beyond range
		return EOF;								// EOF if beyond range detected
	}
	else {
		writeS[0] = value;						// Entry not an escape sequence--
	}											// just pass on the character.
	status = Uart_Write(&uart,writeS,nData);	// Send the data array to the UART for
	if (status < VI_SUCCESS){					// display on the LCD
		return EOF;								// EOF if the transmission isn't
	}											// successful
	else {
		return value;							// Return the character to calling
	}											// function
}

char getkey(void){
// getkey
// The purpose of this function is to detect and return the key a user presses on the
// keypad attached to the MyRio. The returned value depends on the table of defined
// key values. The function starts by initializing the 8 digital channels connected
// to the keypad and then iterates over the keypad until a column and a row are found
// to be low, which can only occur if the user has depressed a key. The column and row
// indicies are then compared against the table of values and the corresponding key
// entry is returned to the calling function. There is a built in delay to ensure
// that multiple entries for the same key press are not returned.
// Inputs: none
// Outputs: user's keypad entry

	int i,j;											// col/row iteration vars
	static int in=0;									// channel initialization counter
	int lowbit=0;										// Lowbit found flag
	NiFpga_Bool testrow=NiFpga_True;
	static char table[4][4] = {{'1','2','3',UP},		// Table that defines what the
								{'4','5','6',DN},		// key entries will return
								{'7','8','9',ENT},
								{'0','.','-',DEL}};

	if (in==0){
		for (i=0; i<8; i++){							// Initializing the 8 digital channels
			Ch[i].dir = DIOB_70DIR;
			Ch[i].out = DIOB_70OUT;
			Ch[i].in = DIOB_70IN;
			Ch[i].bit = i;
		}
		in++;										// Prevents re-initialization after
	}												// first call.

	while (lowbit==0){								// while no low-bit found
		for (i=0; i<4; i++){
			Dio_ReadBit(&Ch[0]);					// Setting all columns Hi-Z
			Dio_ReadBit(&Ch[1]);
			Dio_ReadBit(&Ch[2]);
			Dio_ReadBit(&Ch[3]);

			Dio_WriteBit(&Ch[i], NiFpga_False);		// Write ith column low

			for (j=4; j<8; j++){					// Iterating down the rows
				testrow=Dio_ReadBit(&Ch[j]);		// Checking the jth row
				if (testrow==NiFpga_False){			// Testing for a low row.
					lowbit=1;						// Low bit found means key pressed.
					break;							// Exit out of row when low
				}									// bit found.
			}

			if (lowbit==1){							// Exit out of columns when
				break;								// low bit found
			}

			wait();
		}

	}
	while (Dio_ReadBit(&Ch[j])==NiFpga_False){		// Wait for the user to release
	}												// the key. Prevents multiple entries.
	return table[j-4][i];							// Return the character associated
}													// with the row/col value of the
													// low bit.
void wait(void){
// wait
// This function serves to slow down program execution by consuming computation time
// with a while loop whose duration is controlled by the variable i.
// Inputs: none
// Outputs: none
	uint32_t i;

	i=417000;
	while(i>0){
		i--;
	}
	return;
}
