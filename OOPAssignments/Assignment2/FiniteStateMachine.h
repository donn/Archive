#pragma once
//C++ STL
#include <string>
#include <vector>
#include <unordered_map>

//Project Headers
#include "Action.h"

/*
    Finite State Machine

    The finite state machine nests structures that are necessary for executing finite state machines.
*/
class FiniteStateMachine
{
    friend class Action;
    friend class AddAction;
    friend class OutAction;
    friend class OutStrAction;
    friend class SleepAction;
    friend class WaitAction;
    friend class RunAction;
    friend class EndAction;
    friend class Operand;
    /*
        State

        The actual state.

        Has a list of actions in string form and a dictionary of transitions.
    */
    struct State
    {
        std::vector<Action*> actions;
        std::unordered_map<int, std::string> transitions;

        State();
        /*
            play

            Begins execution of the state's list of actions. 

            Arguments:
            FiniteStateMachine &machine:       
                As states may modify variables in the finite state machine or change altogether, they need access to the FSM to accomplish that.
        */
        void play(FiniteStateMachine& fsm);
    };


    std::string state = "\0";
    
public:

    std::unordered_map<std::string, State> states;
    std::unordered_map<std::string, int> variables;


    FiniteStateMachine();
    FiniteStateMachine(std::string name);

    /*
        run

        Begins the execution of the finite state machine.
    */
    void run();

    static std::unordered_map<std::string, FiniteStateMachine> list;
};