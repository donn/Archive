//Project Headers
#include "FiniteStateMachine.h"

//C++ STL
#include <iostream>

int main(int argc, char** argv)
{
    if (argc != 2)
    {
        std::cout << "Error: Initial FSM must be provided as a lone commandline argument (with no file extension)." << std::endl;
        return 64;
    }

    std::string initialFSM = std::string(argv[1]);

    try
    {
        /*
            The reason there's a "dummy" initialization first is that in case of recursive FSMs, it doesn't try to compile the same FSM again.
        */
        FiniteStateMachine::list[initialFSM] = FiniteStateMachine();
        FiniteStateMachine::list[initialFSM] = FiniteStateMachine(initialFSM);

        FiniteStateMachine::list[initialFSM].run();
    }
    catch (std::string error)
    {
        std::cout << error << std::endl;
    }
    return 0;
}