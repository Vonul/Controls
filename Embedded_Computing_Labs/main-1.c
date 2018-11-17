// ME 477, Lab 2
// Nathan Isaman

/* includes */
#include "stdio.h"
#include "MyRio.h"
#include "me477.h"
#include <string.h>

// prototypes
int getchar_keypad(void);

// definitions


int main(int argc, char **argv){
// Main
// The purpose of this function is to perform the high level tasks of requesting
// data entry from the user and properly printing it on the LCD display.
// Inputs: integer argc and character argv
// Outputs: MyRio status
	char str1[82];								// Strings to save keypad input to
	char str2[82];

	NiFpga_Status status;

    status = MyRio_Open();		   				// Open the myRIO NiFpga Session.
    if (MyRio_IsNotSuccess(status)) return status;

    printf_lcd("\fFirst Number: ");				// User keypad entry prompt
    fgets_keypad(str1,80);						// Read the keypad entries
    printf_lcd("\fSecond Number: ");			// User keypad entry prompt
    fgets_keypad(str2,80);						// Read the keypad entries
    printf_lcd("\f\vValue1: %s \nValue2: %s", str1, str2);	// Displaying entered values
    														// for verification
	status = MyRio_Close();	 					// Close the myRIO NiFpga Session.
	return status;
}

int getchar_keypad(void){
// getchar_keypad
// This function creates a buffer string from user inputs to the keypad and returns
// the characters one-by-one to the calling function (fgets_keypad()) after ENTER
// has been entered by the user or the buffer length has been met. This function allows
// for character deletion from the buffer and adjusts the screen display for when
// the delete key is entered.
// Inputs: none
// Outputs: character that chptr is pointing to

	static int n=0;									// Setting static variables for
	static int buf_len=80;							// getchar_keypad to use
	static char string[82];
	static char *chptr;

	char ch;									// Variable where keypad entry is
												// initially stored before the buffer
	if (n==0){									// Empty buffer string test (i.e. fresh call)
		ch=getkey();							// Get a character from keypad
		chptr=&string[0];						// Set pointer at beginning of the string
		while (ch != ENT){						// Loop until ENT received from keypad
			if (n<buf_len){						// Test to make sure within string length
				if (ch==DEL && n>0){			// Action if DEL is entered and not first
					putchar_lcd('\b');			// key entered.
					putchar_lcd(' ');
					putchar_lcd('\b');			// Removing the character from the screen
					chptr--;					// Move the pointer and counter back to
					n--;						// previous location.
					ch=getkey();				// Get a new character from keypad
				}
				else if (ch==DEL && n==0){		// No action if first character is DEL
					ch=getkey();				// Get a new character from keypad
				}
				else {							// What to do if no DEL or ENT detected
					*chptr=ch;					// Store keypad entry in buffer string
					putchar_lcd(*chptr++);		// Display keypad entry on the screen
					n++;						// and increment the pointer and counter
					ch=getkey();				// Get a new character from keypad
				}
			}
		}
		n++;									// Adjust n to # of chars +1
		chptr=&string[0];						// Return pointer to the beginning of
	}											// the buffer string for output sequence.
	if (n>1){
		n--;									// Output sequence:
		return *chptr++;						// Iterating up the string and returning
	}											// the character in the buffer string
	else {										// at the current pointer position
		n--;									// and decreasing the character count
		return EOF;								// once the end of the string is reached,
												// EOF is returned to signal end of string.
	}											// to calling function.
}
