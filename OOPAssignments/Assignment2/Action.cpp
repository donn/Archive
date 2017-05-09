//Project Headers
#include "Action.h"
#include "FiniteStateMachine.h"

//C++ STL
#include <iostream>
#include <regex>
#include <chrono>
#include <thread>
#include <iterator>

//Numeric Input Verification
//Code by me and a collaborator for a previous project, GitHub https://github.com/Skyus/Archive/blob/master/Optimizer/Sources/main.cpp
bool checkNumber(std::string convertible, int &target)
{
	try
    {
		target = std::stoi(convertible);
		return true;
	}
    catch (const std::invalid_argument& ia)
    {
		return false;
	}
}

int verifyNumber(std::string convertible, std::string prompt)
{	
	while (true)
    {
		int n;
		try
        {
			return std::stoi(convertible);
		}
        catch (const std::invalid_argument& ia)
        {
			//Do nothing.
		}

		std::cout << prompt;
		std::cin >> convertible;		
	}
}

/*
    Operand Definitions
*/
Operand::Operand() {}
Operand::Operand(FiniteStateMachine& fsm, std::string line)
{
    constant = true;

    if (!checkNumber(line, value))
    {
        if (fsm.variables.find(line) != fsm.variables.end())
        {
            variable = line;
            constant = false;
        }
        else
        {
            throw std::string("Unknown constant/variable " + line + ".");
        }
    }
}

int Operand::getValue(FiniteStateMachine &fsm)
{
    return constant? value: fsm.variables[variable];
}


/*
    Action Definitions
*/
Action::Action() {}
AddAction::AddAction(FiniteStateMachine& fsm, std::string& line)
{
    std::regex pattern("^\\s*([_A-Za-z][_A-Za-z0-9]*)\\s*=\\s*([_A-Za-z0-9]+)\\s*\\+([_A-Za-z0-9]+)\\s*$");
    std::smatch match;
    if (!std::regex_match(line, match, pattern))
    {
        throw -1;
    }
    
    if (fsm.variables.find(match[1]) == fsm.variables.end())
    {
        throw std::string("Unknown destination variable.");
    }

    destination = match[1];

    try
    {
        one = Operand(fsm, std::string(match[2]));
    }
    catch (std::string error)
    {
        throw error;
    }
    
    try
    {
        two = Operand(fsm, std::string(match[3]));
    }
    catch (std::string error)
    {
        throw error;
    }
}

void AddAction::play(FiniteStateMachine& fsm)
{
    fsm.variables[destination] = one.getValue(fsm) + two.getValue(fsm);
}

OutAction::OutAction(FiniteStateMachine& fsm, std::string& line)
{
    std::regex pattern("^\\s*out\\s*([_A-Za-z][_A-Za-z0-9]*)\\s*$");
    std::smatch match;
    if (std::regex_match(line, match, pattern))
    {       
        try
        {
            operand = Operand(fsm, std::string(match[1]));
        }
        catch (std::string error)
        {
            throw error;
        }

        return;
    }
    
    throw -1;
}

void OutAction::play(FiniteStateMachine& fsm)
{
    std::cout << operand.getValue(fsm) << std::endl;
}

OutStrAction::OutStrAction(FiniteStateMachine& fsm, std::string& line)
{
    std::regex pattern("^\\s*out\\s*\"(.+)\"\\s*$");
    std::smatch match;
    if (std::regex_match(line, match, pattern))
    {
        operand = match[1];
        return;
    }
    
    throw -1;
}

void OutStrAction::play(FiniteStateMachine& fsm)
{
    std::cout << operand << std::endl;
}

SleepAction::SleepAction(FiniteStateMachine& fsm, std::string& line)
{
    std::regex pattern("^\\s*sleep\\s*([0-9]+)\\s*$");
    std::smatch match;
    if (std::regex_match(line, match, pattern))
    {
        if (!checkNumber(match[1], duration))
        {
            throw std::string("Invalid duration.");
        }
        return;
    }
    throw -1;
}

void SleepAction::play(FiniteStateMachine& fsm)
{
    std::cout << "🛏" << std::flush;
#ifndef _DO_NOT_WAIT
    std::this_thread::sleep_for(std::chrono::milliseconds(duration * 1000));
#endif
    std::cout << std::endl;
}

WaitAction::WaitAction(FiniteStateMachine& fsm, std::string& line)
{
    std::regex pattern("^\\s*wait\\s*$");
    std::smatch match;
    if (!std::regex_match(line, match, pattern))
    {
        throw -1;
    }
}

void WaitAction::play(FiniteStateMachine& fsm)
{
    std::string buffer;
    std::cout << "Waiting for an input (currently on state '" << fsm.state << "'): ";
    std::cin >> buffer;
    if (std::cin.eof())
    {
        std::cout << std::endl;
        exit(65);
    }
    int input = verifyNumber(buffer, "Invalid. Retry [Numeric]: ");
    while (fsm.states[fsm.state].transitions.find(input) == fsm.states[fsm.state].transitions.end())
    {
        std::cout << "Input " << input << " not a valid transition. Retry: ";
        std::cin >> buffer;
        if (std::cin.eof())
        {
            std::cout << std::endl;
            exit(65);
        }
        input = verifyNumber(buffer, "Invalid. Retry [Numeric]: ");
    }
    fsm.state = fsm.states[fsm.state].transitions[input];
}


RunAction::RunAction(FiniteStateMachine& fsm, std::string& line)
{
    std::regex pattern("^\\s*run\\s*([_A-Za-z][_A-Za-z0-9]*)\\s*$");
    std::smatch match;
    if (std::regex_match(line, match, pattern))
    {
        try
        {
            if (FiniteStateMachine::list.find(match[1]) == FiniteStateMachine::list.end())
            {
                FiniteStateMachine::list[match[1]] = FiniteStateMachine();
                FiniteStateMachine::list[match[1]] = FiniteStateMachine(match[1]);
            }
            target = match[1];
        }
        catch (std::string error)
        {
            throw error;
        }
        return;
    }
    throw -1;
}

void RunAction::play(FiniteStateMachine& fsm)
{
    try
    {
        FiniteStateMachine::list[target].run();
    }
    catch (std::string error)
    {
        throw error;
    }
}

EndAction::EndAction(FiniteStateMachine& fsm, std::string& line)
{
    std::regex pattern("^\\s*end\\s*$");
    std::smatch match;
    if (!std::regex_match(line, match, pattern))
    {
        throw -1;
    }
}

void EndAction::play(FiniteStateMachine& fsm)
{
    fsm.state = "\0";
}

Action* Action::Compile(FiniteStateMachine& fsm, std::string& line)
{
    try
    {
        return new AddAction(fsm, line);
    }
    catch (std::string error)
    {
        throw error;
    }
    catch (int error)
    {
        try
        {
            return new OutAction(fsm, line);
        }
        catch (std::string error)
        {
            throw error;
        }
        catch (int error)
        {
            try
            {
                return new OutStrAction(fsm, line);
            }
            catch (std::string error)
            {
                throw error;
            }
            catch (int error)
            {
                try
                {
                    return new SleepAction(fsm, line);
                }
                catch (std::string error)
                {
                    throw error;
                }
                catch (int error)
                {
                    try
                {
                    return new WaitAction(fsm, line);
                    }
                    catch (std::string error)
                    {
                        throw error;
                    }
                    catch (int error)
                    {
                        try
                        {
                            return new RunAction(fsm, line);
                        }
                        catch (std::string error)
                        {
                            throw error;
                        }
                        catch (int error)
                        {
                            try
                            {
                                return new EndAction(fsm, line);
                            }
                            catch (std::string error)
                            {
                                throw error;
                            }
                            catch (int error)
                            {
                                throw std::string("Action doesn't match anything.");
                            }
                        }
                    }
                }
            }
        }
    }
}