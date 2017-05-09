//This main function is only for testing, thus I have liberally used the C++ STL.

//CPP STL/CSTD
#include <iostream>
#include <cstdlib>
#include <ctime>

//Project Headers
#include "Bag.h"

int main(int argc, char** argv)
{
    srand(time(NULL));

    std::cout << "Testing unsigned 8 bit integers." << std::endl;
    Bag a;
    for (int i = 0; i < 0xFFFFF; i++)
    {
        try
        {
            u8 number = rand() & 0xFF;
            std::cout << "Inserting " << int(number) << "..." << std::endl;
            a.insert(number);
            number = rand() & 0xFF;
            std::cout << "Removing " << int(number) << "..." << std::endl;
            a.remove(number);
        }
        catch (const char* e)
        {
            std::cout << e << std::endl;
        }
    }
    std::cout << std::endl;

    std::cout << "[" << int(a.check(0)) << ", ";
    for (int i = 1; i < 255; i++)
    {
        if ((i & 15) == 0)
        {
            std::cout << std::endl;
        }
        std::cout << int(a.check(i)) << ", ";
    }
    std::cout << int(a.check(255)) << "]" << std::endl;

    #ifdef _MSC_VER
    system("pause");
    #endif

    return 0;
}