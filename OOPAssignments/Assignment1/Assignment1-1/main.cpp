//This main function is only for testing, thus I have liberally used the C++ STL.

//CPP STL/CSTD
#include <iostream>
#include <cstdlib>
#include <ctime>

//Project Headers
#include "Set.h"

int main(int argc, char** argv)
{
    srand(time(NULL));

    std::cout << "Testing unsigned 8 bit integers." << std::endl;
    Set a;
    for (int i = 0; i < 8; i++)
    {
        u8 number = rand() & 0xFF;
        std::cout << "Inserting " << int(number) << "... ";
        a.insert(number);
        std::cout << "Checking " << int(number) << "... " << (a.check(number)? "Success! ": "Failure. ");
        std::cout << "Checking " << int(number + 1) << "... " << (a.check(number + 1)? "Success! ": "Failure. ");
        std::cout << "Removing " << int(number) << "... ";
        a.remove(number);
        std::cout << "Rechecking " << int(number) << "... " << (a.check(number)? "Success! ": "Failure. ");
        std::cout << std::endl;
    }
    std::cout << std::endl;

    std::cout << "Testing compiler-defined ints." << std::endl;
    Set b;
    for (int i = 0; i < 8; i++)
    {
        int number = rand() & ((rand() & 1)? 0xFFFFFFFF: 0xFF);
        std::cout << "Inserting " << int(number) << "... ";
        try
        {
            b.insert(number);
            std::cout << "Checking " << int(number) << "... " << (b.check(number)? "Success! ": "Failure. ");
            std::cout << "Checking " << int(number + 1) << "... " << (b.check(number + 1)? "Success! ": "Failure. ");
            std::cout << "Removing " << int(number) << "... ";
            b.remove(number);
            std::cout << "Rechecking " << int(number) << "... " << (b.check(number)? "Success! ": "Failure. ");
        } catch (const char* e) {
            std::cout << e;
        }
        std::cout << std::endl;
    }

    #ifdef _MSC_VER
    system("pause");
    #endif

    return 0;
}