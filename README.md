
# iOSAppIntegrityCheck


This is a Proof of Concept application that during launch it validates that the application code has not been tampered with.

# Overview


* Create a build phase script that after the compilation (but before the app signing) that:
	* Calculates the hash for the binary’s machine code (The __text section  of the __TEXT segment)
	* Add this hash to your App’s binary (in the __cstring section of the __TEXT segment)
* Add a method that will be called during the app’s launch( `correctCheckSumForTextSection()` ) that calculates the hash of current running code and compare the original. If the values differ it crashes the app.

### Testing the solution

The easiest way to test the solution is to run it in the simulator and add a breakpoint(e.g. in the viewWillAppear of the viewController). This will cause the loaded code to change and will fail the validation, since Software breakpoints work by *replacing* an existing opcode at the position the debugger should halt our program with an opcode that forces the CPU to emit a software interrupt.

## Notes
If you change the code of application you need to perform a clean build. Because it searches for a placeholder hash in the binary and replaces it with the hash of the code of the current build, it will not find that placeholder if it has been replaced by an incremental build.

### iOS Athens meetup
This was presented in the iOS Athens meetup https://www.meetup.com/Athens-iOS-MeetUps/.
You can download the [presentation sildes](ios_app_integrity.pdf).

## Author

Christos Koninis

## License

The code is available under the LGPL license. See the LICENSE file for more info.