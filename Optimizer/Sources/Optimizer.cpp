// Project
#include "Optimizer.h"

// CPP STL
#include <iostream>
#include <iomanip>

// C STD
#include <cmath>
#include <string>

#define PRINT_WIDTH 80

inline uint8 Optimizer::getBitCounts()
{
    return varCount + 1;
}

uint8 Optimizer::bitCount(uint16 term)
{
    uint8 count = 0;
    while (term > 0)
    {
        count += term & 1;
        term = term >> 1;
    }
    return count;
}

Term Optimizer::encode(uint16 term) {
    Term t;

    // Add terms
    t.minterms = new uint16[1];
    t.minterms[0] = term;

	t.varCount = varCount;

    // Add states
    t.states = new ternary[varCount];
    for (int i = 0; i < varCount; i++)
    {
        t.states[i] = 0;
    }

    for (int i = 0; i < varCount; i++)
    {
        t.states[i] = term % 2;
        term /= 2;
    }
    t.combined = 0;

    return t;
}

Term* Optimizer::combine(Term k1, Term k2, int columnNumber)
{
    //Hamming Distance
    uint8 distance = 0;
    uint8 location = -1;
    for (int i = 0; i < varCount; i++) {
        if (k1.states[i] != k2.states[i])
        {
            if (++distance > 1) {
                return NULL;
            } else {
                location = i;
            }
        }
    }
    if (!distance) return NULL;

    //Creating minterm
    int termCount = pow(2, columnNumber);
    Term *k = new Term();
    k->states = new ternary[varCount];
    k->minterms = new uint16[termCount * 2];
    k->combined = false;

    for (int i = 0; i < varCount; i++) {
        k->states[i] = k1.states[i];
    }
    k->states[location] = -1;

    for (int i = 0; i < termCount; i++) { //Checking for duplicates here is simply too tedious and it really doesn't matter.
        k->minterms[i] = k1.minterms[i];
        k->minterms[i + termCount] = k2.minterms[i];
    }

    return k;
}

void Optimizer::print(Term k, int columnNumber)
{ 
    int numChar = 0;
    int termNo = pow(2, columnNumber);
	std::cout << "(";
    for (int i = 0; i < termNo; i++) {
        std::string tempStr = std::to_string(k.minterms[i]);
        std::cout << tempStr;
        numChar += tempStr.size();

        if (i != termNo - 1) {
            std::cout << ", ";
            numChar += 2;
        }
    }
	std::cout << ")" << ((k.combined)? "" : "*");

    std::cout << std::setw(PRINT_WIDTH - varCount - numChar - ((k.combined)? 2 : 3)) << std::setfill(' ') << "";
    
	for (int i = varCount - 1; i >= 0; i--) {
		if (k.states[i] == -1) {
            std::cout << 'X';
        } else {
            std::cout << int(k.states[i]);
        }
	}

	std::cout << std::endl;
}


void Optimizer::addMinTerm(uint16 term) {
	addDontCareTerm(term); // This is the same minus the minterms push
	minterms.push_back(term);
}

void Optimizer::addDontCareTerm(uint16 term) {
    for (int i = 0; i < columns[0].groups[bitCount(term)].terms.size(); i++)
    {
        if (columns[0].groups[bitCount(term)].terms[i].minterms[0] == term)
        {
            std::cout << "Duplicate ignored.";
            return;
        }
    }
	columns[0].groups[bitCount(term)].terms.push_back(encode(term));
}

void Optimizer::combine() {
    int bitCounts = getBitCounts();

    bool combined = true;
    int columnNumber = 0;
    while (combined) {
        combined = false;
        Column column;
        column.groups.resize(bitCounts);

        for (int i = 0; i < columns[columnNumber].groups.size(); i++) {
            if (i + 1 != columns[columnNumber].groups.size()) {
                for (int j = 0; j < columns[columnNumber].groups[i].terms.size(); j++) {
                    for (int k = 0; k < columns[columnNumber].groups[i + 1].terms.size(); k++) {
                        if (Term *t = combine(columns[columnNumber].groups[i].terms[j], columns[columnNumber].groups[i + 1].terms[k], columnNumber)) {
                            column.groups[i].terms.push_back(*t);
                            columns[columnNumber].groups[i].terms[j].combined = true;
                            columns[columnNumber].groups[i + 1].terms[k].combined = true;
                            combined = true;
                        }
                    }
                }

				//Check Duplicates
				for (int j = 0; j < column.groups[i].terms.size(); j++) {
					for (int k = j + 1; k < column.groups[i].terms.size(); k++) {
						int matching = 0;
						for (int l = 0; l < varCount; l++) {
							if (column.groups[i].terms[j].states[l] == column.groups[i].terms[k].states[l]) {
								matching++;
							}
						}
						if (matching == varCount) {
							column.groups[i].terms.erase(column.groups[i].terms.begin() + k);
							k--;
						}
					}
				}
            }             
        }

        if (combined) {
            columns.push_back(column);
            columnNumber++;
        }
    }
	
	// Push uncombined terms to vector
	for (size_t i = 0; i < columns.size(); i++) {
		Column *col = &columns[i];      
		for (size_t j = 0; j < col->groups.size(); j++) {
			Group *grp = &col->groups[j];
			for (size_t k = 0; k < grp->terms.size(); k++) {
				Term *term = &grp->terms[k];
				if (!term->combined)
					finalTerms.push_back(term);
			}
		}
	}
}

void Optimizer::printImplication() {
	for (size_t i = 0; i < columns.size(); i++) {
		Column *col = &columns[i];      

		if (col->groups.size() > 0) {
            std::cout << std::setw(PRINT_WIDTH) << std::setfill('=') << "" << std::endl;
			std::cout << "  Column " << i << "  " << std::endl;
			std::cout << std::setw(PRINT_WIDTH) << std::setfill('-') << "" << std::endl;

			for (size_t j = 0; j < col->groups.size(); j++) {
				Group *grp = &col->groups[j];
                
				if (grp->terms.size() > 0) {
					for (size_t k = 0; k < grp->terms.size(); k++) {
						Term *term = &grp->terms[k];
						print(*term, i);
				    }
                    std::cout << std::setw(PRINT_WIDTH) << std::setfill('-') << "" << std::endl;
			    }
            }
			std::cout << std::setw(PRINT_WIDTH) << std::setfill('=') << "" << std::endl << std::endl << std::endl;
		}
	}
}

char Optimizer::alphabetizeTernary(int pos, ternary value) {
	if (value == 1 || value == 0)
		return char(65 + pos); // Capitals for Truth
	else
		return ' ';
}

const char *Optimizer::alphabetizeTerm(Term term) {
	char *charArr = new char[2 * varCount];
	int j = 0, dontCare = 0;
	for (size_t i = 0; i < varCount; i++) {
		char translated = alphabetizeTernary(i, term.states[varCount - 1 - i]);
		if (translated != ' ') {
			charArr[j] = translated;
			j++;
			if (term.states[varCount - 1 - i] == 0)
			{
				charArr[j] = '\'';
				j++;
			}
		}
		else
		{
			dontCare++;
		}
	}
	if (dontCare == varCount)
	{
		return "1";
	}

	charArr[j] = 0;
	return charArr;
}

void Optimizer::printPI()
{
	std::cout << std::setw(6 * varCount) << std::setfill(' ') << "" << "|";
	for (size_t i = 0; i < minterms.size(); i++)
		std::cout << std::setw(6) << std::setfill(' ') << minterms[i];

	std::cout << std::endl << std::setw(6 * varCount + 1 + 6 * minterms.size()) << std::setfill('-') << ""  << std::endl << std::setfill(' ');

	for (size_t k = 0; k < finalTerms.size(); k++) {
		Term *term = finalTerms[k];
		std::string output = std::string(alphabetizeTerm(*term)) + " (";
		for (int i = varCount - 1; i >= 0; i--) {
			if (term->states[i] == -1) {
				output += 'X';
			} else {
				output += std::to_string(int(term->states[i]));
			}
		}
		output += ") ";
		std::cout << std::setw(6 * varCount) << output << "|";

		for (size_t l = 0; l < minterms.size(); l++)
			std::cout << std::setw(6) << ((TermsEquivalent(*term, minterms[l]))? "x": " ");
			
		std::cout << std::endl;
	}


	std::cout << std::endl << std::setw(6*varCount+1+6*minterms.size()) << std::setfill('-') << "" << std::endl << std::setfill(' ');
}

void Optimizer::extract() {
	std::vector<Term*> primes;
	int *mintermCovered = new int[minterms.size()];
	for (size_t m = 0; m < minterms.size(); m++)
		mintermCovered[m] = -1;
	for (size_t m = 0; m < minterms.size(); m++) {
		int essentialCount = 0;
		int lastMinterm = 0;
		
		for (size_t i = 0; i < finalTerms.size(); i++) {
			Term *term = finalTerms[i];
			if (term->combined)
				continue;
			if (TermsEquivalent(*term, minterms[m])) {
				essentialCount++;
				lastMinterm = i;
			}
		}
		
		if (essentialCount == 1) {
			primes.push_back(finalTerms[lastMinterm]);
			for (size_t j = 0; j < minterms.size(); j++) {
				if (mintermCovered[j] == -1 && TermsEquivalent(*finalTerms[lastMinterm], minterms[j]))
					mintermCovered[j] = lastMinterm;
			}
		}
	}

	//Check essential prime duplicates (usually happens in case of a tautology)
	for (int j = 0; j < primes.size(); j++) {
			for (int k = j + 1; k < primes.size(); k++) {
				int matching = 0;
				for (int l = 0; l < varCount; l++) {
					Term *one = primes[j];
					Term *two = primes[k];
					if (one->states[l] == primes[k]->states[l]) {
						matching++;
					}
				}
				if (matching == varCount) {
					primes.erase(primes.begin() + k);
					k--;
				}
			}
		}        

	// By this point we have the essential prime implicants
	std::cout << "Essential Prime Implicants: ";
	std::string output = "";	
	for (int i = 0; i < primes.size(); i++)
	{
		output += alphabetizeTerm(*primes[i]);
		output += ", ";
	}
	output[output.length() - 2] = '\0';
	std::cout << output << std::endl;
	
	bool uncovered = true;
	while (uncovered) {
		int maxPrimeCount = -1;
		int maxPrimeID = -1;
		for (size_t i = 0; i < finalTerms.size(); i++) {
			int primeCount=0;
			for (size_t m = 0; m < minterms.size(); m++) {
				if (mintermCovered[m] == -1 && TermsEquivalent(*finalTerms[i], minterms[m]))
					primeCount++;
			}
			
			if (primeCount > maxPrimeCount) {
				maxPrimeID = i;
				maxPrimeCount = primeCount;
			}
		}
		
		if (maxPrimeCount <= 0)
			uncovered = false;
		else {
			primes.push_back(finalTerms[maxPrimeID]);
			for (size_t m = 0; m < minterms.size(); m++) {
				if (mintermCovered[m] == -1 && TermsEquivalent(*finalTerms[maxPrimeID], minterms[m]))
					mintermCovered[m] = maxPrimeID;
			}
		}
	}
	
	std::cout << "Minimized Function: F = ";
	
	for (size_t i = 0; i < primes.size(); i++) {
		std::cout << alphabetizeTerm(*primes[i]);
		if (i != primes.size() - 1)
			std::cout << " + ";
	}
	if (primes.size() == 0)
	{
		std::cout << 0;
	}
	std::cout << std::endl;
}

/*
    Initializer
*/
Optimizer::Optimizer(uint8 variableCount)
{
    varCount = variableCount;
	uint8 bitCounts = getBitCounts();	

	columns.resize(1);
	columns[0].groups.resize(bitCounts);
}

bool Optimizer::TermsEquivalent(Term term, int minVal) {
	Term t;

	// Add terms
	t.minterms = new uint16[1];
	t.minterms[0] = minVal;

	t.varCount = varCount;

	// Add states
	t.states = new ternary[varCount];
	for (int i = 0; i < varCount; i++)
	{
		t.states[i] = 0;
	}

	for (int i = 0; i < varCount; i++)
	{
		t.states[i] = minVal % 2;
		minVal /= 2;
	}
	t.combined = 0;

	/*for (int i = varCount - 1; i >= 0; i--) {
		if (term.states[i] == -1) {
            std::cout << '_';
        } else {
            std::cout << int(term.states[i]);
        }
	}

	std::cout << " = ";

	for (int i = varCount - 1; i >= 0; i--) {
		if (t.states[i] == -1) {
            std::cout << '_';
        } else {
            std::cout << int(t.states[i]);
        }
	}*/
	//std::cout << " (" << int(minVal) << ")" << std::endl;


	return TermsEquivalent(term, t);
}

bool Optimizer::TermsEquivalent(Term term, Term term2) {
	for (size_t i = 0; i < varCount; i++) {
		if ((term.states[i] != -1) && (term2.states[i] != -1) && (term.states[i] != term2.states[i]))
			return false;
	}

	return true;
}
