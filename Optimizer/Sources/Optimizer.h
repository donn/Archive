#pragma once
//Project
#include "Types.h"
#include <vector>

struct Term {
	uint8 varCount;
    ternary* states; //Stored in little endian fashion. (0, 1, -1 in place of the ignore). Least significant bit first.
    uint16* minterms; //Technically also includes don't cares but.. don't care.
    bool combined; //Was this term combined..?
};

struct Group
{
    std::vector<Term> terms;
};

struct Column
{
    std::vector<Group> groups;
};

class Optimizer {
private:
	std::vector<Term>	primeImplicants;
	std::vector<Column> columns;
	std::vector<uint16>	minterms;
    std::vector<Term *>	finalTerms;
    uint8 varCount;

    //Utilities
    uint8 bitCount(uint16 term);
    inline uint8 getBitCounts();

	// Make alphabetized
	char alphabetizeTernary(int, ternary);
	const char *alphabetizeTerm(Term);

    //Term functions
    Term encode(uint16 term);
    Term* combine(Term k1, Term k2, int columnNumber);
    void print(Term k, int columnNumber);  

    bool TermsEquivalent(Term, int);
    bool TermsEquivalent(Term, Term);
    
public:
    //Initializer(s)
    Optimizer(uint8 variableCount);

    //Add term
    void addMinTerm(uint16 term);
    void addDontCareTerm(uint16 term);

    //Assorted public functions
    void combine();
	void printImplication();
    void printPI();
	void extract();   
    
};