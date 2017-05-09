#Usage
To run the assignment, change your directory to its folder and run ./build.sh on a Unix or Unix-like system and then run the generated .bin file.

The program can be compiled with a compiler flag _DO_NOT_WAIT to cut sleep times to zero for faster testing.

You need to supply an argument which is the name of the FSM. The .fsm file must be in the same folder where you're running the application. Do not supply the whole name of the file as an argument.

#About the FSM simulator
It's flexible and mostly whitespace unconscious, as in, distances between words and separators are a non-factor. An end of line is required between statements, however.

The FSMs are all statically compiled before interpretation. Please note there is only one instance of every loaded FSM, that is, if you run an FSM that is already on the run stack chances are you'll end up in an infinite loop. There was no requirement to avoid such a situation.

All variables are initialized at 0.