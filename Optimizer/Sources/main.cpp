// Project
#include "Optimizer.h"

// CPP STL
#include <iostream>
#include <iomanip>
#include <stdexcept>

// C STD
#include <cmath>

#include <string>

int verifyNumber(std::string convertible, std::string prompt)
{	
	while (true) {
		int n;
		try {
			return std::stoi(convertible);
		} catch (const std::invalid_argument& ia) {
			//Do nothing.
		}

		std::cout << prompt;
		std::cin >> convertible;		
	}
}

bool checkNumber(std::string convertible, int &target)
{
	try {
		target = std::stoi(convertible);
		return true;
	} catch (const std::invalid_argument& ia) {
		return false;
	}
}

int main(int argc, char** argv)
{
#ifndef Test
	//Input Variable Count
	int varCount;
	std::string buffer;
	std::cout << "Input the number of variables (max 16): ";
	std::cin >> buffer;
	varCount = verifyNumber(buffer, "Invalid number. Retry: ");
	while ((varCount < 1) || (varCount > 16)) {
		std::cout << "Number out of range [1-16 incl.] Retry: ";
		std::cin >> buffer;
		varCount = verifyNumber(buffer, "Invalid number. Retry: ");
	}

	//Build Implication Table
	int possibilities = pow(2, varCount);
    Optimizer impt(varCount);
	
	//Input Minterms
	std::cout << "Input the terms (space delimited, mX for minterms, dX for don't cares. Write END to finish):\n";
	bool input = true;
	while (input) {
		std::cin >> buffer;
		if (buffer == "END") {
			input = false;
		} else if ((buffer[0] == 'm' || buffer[0] == 'd') && buffer.size() > 1) {
			std::string termNo = buffer;
			termNo.erase(0, 1);
			int term;
			if (checkNumber(termNo, term) && term < possibilities) {
				std::cout << "Encoded " << buffer << ".\n";

				if (buffer[0] == 'm')
					impt.addMinTerm(term);
				else
					impt.addDontCareTerm(term);
			} else {
				std::cout << "Warning: Term " << buffer << " invalid. Ignored.\n";
			}
		} else {
			std::cout << "Warning: Term " << buffer << " unrecognized or unsupported. Ignored.\n";
		}
	}
	std::cout << std::endl << std::endl;

#else
	Optimizer impt(4);

    impt.addMinTerm(4);
	impt.addMinTerm(5);
	impt.addMinTerm(6);
	impt.addMinTerm(8);
	impt.addMinTerm(9);
	impt.addMinTerm(10);
	impt.addMinTerm(13);
	impt.addDontCareTerm(0);
	impt.addDontCareTerm(7);
	impt.addDontCareTerm(15);
#endif

	std::cout << "\nImplication Table:\n\n";
	impt.combine();
	impt.printImplication();

	std::cout << "\nPrime Implicant Table:\n\n";
	impt.printPI();

	std::cout << "\nResults:\n";
	impt.extract();

	std::cout << "\n";

#ifdef _MSC_VER
	system("pause");
#endif
    return 0;
}