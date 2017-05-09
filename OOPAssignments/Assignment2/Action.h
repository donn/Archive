#pragma once
//C++ STL
#include <string>

class FiniteStateMachine;

/*
    Action

    An abstract class called Action and have various subclasses for each action.
*/
class Action
{
public:
    /*
        play

        Executes compiled action. Throws error on failure.
        
        Arguments:
        FiniteStateMachine& fsm:
            As actions may modify variables in the finite state machine, run different ones or something of the sort, they need access to the FSM to accomplish that.

    */
    virtual void play(FiniteStateMachine& fsm) = 0;
    Action();

    /*
        Compile

        Compiles action into one of the subclasses for actions. Throws error if the action is not found.

        Arguments:
        FiniteStateMachine &fsm:
            As actions may modify variables in the finite state machine, run different ones or something of the sort, they need access to the FSM to accomplish that
        std::string& line:
            The action to be compiled.
    */
    static Action* Compile(FiniteStateMachine& fsm, std::string& line);
};

/*
    Operand

    Represents either a constant or a variable in a bit of an easier way.
*/
struct Operand
{
    bool constant;
    std::string variable;
    int value;

    Operand();
    Operand(FiniteStateMachine& fsm, std::string line);

    /*
        getValue

        Arguments:
        FiniteStateMachine &fsm:
            If it's a variable, the actual FSM is needed to get its current value.
    */
    int getValue(FiniteStateMachine& fsm);
};


class AddAction: public Action
{
    std::string destination;
    Operand one, two;
public:
    void play(FiniteStateMachine& fsm);
    AddAction(FiniteStateMachine& fsm, std::string& line);
};

class OutAction: public Action
{
    Operand operand;
public:
    void play(FiniteStateMachine& fsm);
    OutAction(FiniteStateMachine& fsm, std::string& line);
};

class OutStrAction: public Action
{
    std::string operand;
public:
    void play(FiniteStateMachine& fsm);
    OutStrAction(FiniteStateMachine& fsm, std::string& line);
};

class SleepAction: public Action
{
    int duration;
public:
    void play(FiniteStateMachine& fsm);
    SleepAction(FiniteStateMachine& fsm, std::string& line);
};

class WaitAction: public Action
{
public:
    void play(FiniteStateMachine& fsm);
    WaitAction(FiniteStateMachine& fsm, std::string& line);
};

class RunAction: public Action
{
    std::string target;
public:
    void play(FiniteStateMachine& fsm);
    RunAction(FiniteStateMachine& fsm, std::string& line);
};

class EndAction: public Action
{
public:
    void play(FiniteStateMachine& fsm);
    EndAction(FiniteStateMachine& fsm, std::string& line);
};