// ME 477, Lab 1
// Nathan Isaman

/* includes */
#include <stdio.h>
#include "MyRio.h"
#include "me477.h"
#include <string.h>
#include <stdarg.h>

/* prototypes */

double	double_in(char *prompt);
int printf_lcd(char *format, ...);

/* definitions */

int main(int argc, char **argv){
// Main function
// The purpose of this function is to perform the high level tasks of requesting
// data entry from the user and properly printing it on the LCD display.
// Inputs: integer argc and character argv
// Outputs: MyRio status

	NiFpga_Status status;
	double val1, val2;

    status = MyRio_Open();		     // Open the myRIO NiFpga Session.*/
    if (MyRio_IsNotSuccess(status)) return status;

    // Main code to execute
    printf_lcd("\f");				 // clearing the display
    val1=double_in("Entr Vel 1: ");  // First velocity input from the user
    printf_lcd("\f");				 // clearing the display
    val2=double_in("Entr Vel 2: ");  // Second velocity input from the user

    printf_lcd("\fVelocity 1: %f \nVelocity 2: %f", val1, val2); //Printing results to screen
    // End of main code to execute

	status = MyRio_Close();	 /*Close the myRIO NiFpga Session. */
	return status;
}

double double_in(char *prompt){
// double_in()
// The purpose of this function is to verify that the user has correctly entered a double
// on the keypad. The function performs a number of tests to ensure common entry errors
// have not occurred. If the function finds an error, a message is printed on the LCD
// screen telling the user that they have made a mistake. A detailed error message is
// provided when possible/practical.
// Inputs: a string prompt from calling function.
// Outputs: double 'val' is returned to calling function upon successful entry.

	int err;
	char string[40];		// declaring function variables
	double val;

	err = 1;				// initializing the error state to "error present"

	while (err==1){
		printf_lcd("\v%s",prompt);					// Displays the prompt passed into
		if (fgets_keypad(string,40)==NULL){			// the function
			printf_lcd("\f\nEntry Too Short.");
		}											// tests for null entry (i.e. ENTR only)
		else if(strpbrk(string,"[")){
			printf_lcd("\f\nEntry Invalid.");		// tests for arrow entry
		}
		else if(strpbrk(string,"]")){
			printf_lcd("\f\nEntry Invalid.");		// tests for arrow entry
		}
		else if(strpbrk(&string[1],"-")){
			printf_lcd("\f\nDbl Neg Detected.");	// tests for double -
		}
		else if(strstr(string, "..")){
			printf_lcd("\f\nDbl Punct Detected.");	// tests for a double .
		}
		else {
			err=0;									// Assign "no error" value
			sscanf(string,"%lf",&val);				// Convert string to double
		}											// and stores number in val.
	}
	return val;										// Returning valid entry to main
}

int printf_lcd(char *format, ...){
// printf_lcd()
// The purpose of this function is to print a passed string to an LCD screen. The string
// is first passed through vsnprintf() to create a printf() formatted string.
// Input: format string from calling function
// Output: function returns nothing to calling function; its purpose is to print to a screen

	va_list args;
	int n,i;
	char string[80];							// declaring function variables
	char *ptr;

	va_start(args, format);						// using va macros for function args
	n = vsnprintf(string, 80, format, args);	// create buffer string given
	va_end(args);								// standard printf() format input

	ptr=string;									// increment pointer
	i=0;

	while (*ptr){								// continues until pointing at '\0'
		if (i>79){								// test for going beyond string length
			break;
		}
		putchar_lcd(*ptr++);					// print char on LCD & increment
		i++;									// increment length test counter
	}
	return 0;									// int returned, but real output is the
}												// message printed to LCD screen
