//Project Headers
#include "FiniteStateMachine.h"
#include "Action.h"

//C++ STL
#include <iostream>
#include <fstream>
#include <sstream>
#include <regex>
#include <iterator>

//String Splitting
//Code by Evan Teran, StackOverflow https://stackoverflow.com/questions/236129/split-a-string-in-c
template<typename Out>
void split(const std::string &s, char delim, Out result) {
    std::stringstream ss;
    ss.str(s);
    std::string item;
    while (std::getline(ss, item, delim)) {
        *(result++) = item;
    }
}

std::vector<std::string> split(const std::string &s, char delim) {
    std::vector<std::string> elems;
    split(s, delim, std::back_inserter(elems));
    return elems;
}

/*
    State Definitions
*/
FiniteStateMachine::State::State() {}
void FiniteStateMachine::State::play(FiniteStateMachine& fsm)
{
    for (int i = 0; i < actions.size(); i++)
    {
        actions[i]->play(fsm);
    }
}

/*
    Finite State Machine Definitions
*/
std::unordered_map<std::string, FiniteStateMachine> FiniteStateMachine::list;
FiniteStateMachine::FiniteStateMachine() {} //Only here for std::unordered_map
FiniteStateMachine::FiniteStateMachine(std::string fsmName)
{
    std::ifstream input;
    input.open(fsmName + ".fsm");

    std::regex whitespace("\\s*");
    
    if (input.fail())
    {
        throw "Finite state machine '" + fsmName + "' cannot be found.";
    }
    std::cout << "Initializing finite state machine " << fsmName << "..." << std::endl;


    //Compilation
    std::string line;
    auto name = true;
    auto variables = false;
    auto states = false;
    auto transitions = false;
    int lineCounter = 1;

    while (std::getline(input, line))
    {
        if (std::regex_match(line, whitespace))
        {
            lineCounter++;
            continue;
        }
        if (name)
        {
            std::regex nameDeclaration("^\\s*FSM\\s*([_A-Za-z][_A-Za-z0-9]*)\\s*$");
            std::smatch match;
            if (std::regex_match(line, match, nameDeclaration))
            {
                if (fsmName != match[1])
                {
                    throw "Name mismatch ('" + fsmName + "' must be equal to '" + std::string(match[1]) + "'.)";
                }
                name = false;
                variables = true;
            }
            else
            {
                throw "Line " + std::to_string(lineCounter) + ": Expected name declaration.";
            }            
        }
        else if (variables)
        {
            std::regex variableDeclaration("^\\s*VAR\\s*(.+)\\s*$");
            std::smatch match;
            if (std::regex_match(line, match, variableDeclaration))
            {
                auto variableList = split(match[1], ',');
                std::regex checkVariable("^\\s*([_A-Za-z][_A-Za-z0-9]*)\\s*$");
                for (int j = 0; j < variableList.size(); j++)
                {
                    if (std::regex_match(variableList[j], match, checkVariable))
                    {
                        this->variables[match[1]] = 0;
                    }
                    else
                    {
                        throw "Variable '" + variableList[j] + "' is malformed.";
                    }                    
                }
            }            
            else
            { 
                std::regex stateListStart("^\\s*States\\s*:\\s*$");
                if (std::regex_match(line, match, stateListStart))
                {
                    variables = false;
                    states = true;
                }
                else
                {
                    throw "Line " + std::to_string(lineCounter) + ": Expected variable declaration.";
                }
            }    
        }
        else if (states)
        {
            std::regex stateDeclaration("^\\s*([_A-Za-z][_A-Za-z0-9]*)\\s*:\\s*(.+)\\s*");
            std::smatch match;
            if (std::regex_match(line, match, stateDeclaration))
            {
                if (this->state[0] == '\0')
                {
                    this->state = match[1];
                }
                this->states[match[1]] = State();
                auto actionList = split(match[2], ',');
                for (int i = 0; i < actionList.size(); i++)
                {
                    try
                    {
                        this->states[match[1]].actions.push_back(Action::Compile(*this, actionList[i]));
                    }
                    catch (std::string error)
                    {
                        throw "Line " + std::to_string(lineCounter) + ": " + error;
                    }
                }
            }
            else
            {
                std::regex transitionListStart("^\\s*Transitions\\s*:\\s*$");
                if (std::regex_match(line, match, transitionListStart))
                {
                    states = false;
                    transitions = true;
                }
                else
                {
                    throw "Line " + std::to_string(lineCounter) + ": Expected state declaration.";
                }
            }
        }
        else if (transitions)
        {
            std::regex transitionDeclaration("^\\s*([_A-Za-z][_A-Za-z0-9]*)\\s*,\\s*([_A-Za-z][_A-Za-z0-9]*)\\s*,\\s*([0-9]+)\\s*");
            std::smatch match;
            if (std::regex_match(line, match, transitionDeclaration))
            {
                if (this->states.find(match[1]) != this->states.end())
                {
                    if (this->states.find(match[2]) != this->states.end())
                    {
                        this->states[match[1]].transitions[std::stoi(match[3])] = match[2];
                    }
                    else
                    {
                        throw "Line " + std::to_string(lineCounter) + ": Destination state unknown.";
                    }
                }
                else
                {
                    throw "Line " + std::to_string(lineCounter) + ": Initial state unknown.";
                }
            }
            else
            {
                throw "Line " + std::to_string(lineCounter) + ": Malformed transition (to end the transition list, just leave whitespace).";
            }   
        }
        lineCounter++;
    }

    if (name)
    {
        throw std::string("Error: FSM not found");
    }
    if (this->states.size() == 0)
    {
        throw std::string("Error: I mean, zero states is still finite, but c'mon...'");
    }

}

void FiniteStateMachine::run()
{
    while (state[0] != 0)
    {
        states[state].play(*this);
    }
}