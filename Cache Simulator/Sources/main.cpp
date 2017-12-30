//CPP STL
#include <iostream>
#include <fstream>
#include <iomanip>
#include <functional>
#include <string>
#include <vector>

//C STD
#include <cmath>

//Project Files
#include "Caches.h"
using namespace std;

#define		DBG				1
#define		DRAM_SIZE		64*1024
#define     ITERATIONS      1000000 

uint m_w = 0xABABAB55;    /* must not be zero, nor 0x464fffff */
uint m_z = 0x05080902;    /* must not be zero, nor 0x9068ffff */
 
uint rand_()
{
    m_z = 36969 * (m_z & 65535) + (m_z >> 16);
    m_w = 18000 * (m_w & 65535) + (m_w >> 16);
    return (m_z << 16) + m_w;  /* 32-bit result */
}

//Sequential access.
uint memGen1()
{
	static uint addr = 0;
	return (addr++) % (DRAM_SIZE);
}

//Random access.
uint memGen2()
{
	return rand_() % (128*1024);
}

//Random access.
uint memGen3()
{
	return rand_() % (DRAM_SIZE);
}

//Looping.
uint memGen4()
{
	static uint addr = 0;
	return (addr++) % (1024);
}

//Looping over a lot of data.
uint memGen5()
{
	static uint addr = 0;
	return (addr++) % (1024*64);
}

//How to NOT take advantage of spatial locality
uint memGen6()
{
	static uint addr = 0;
	return (addr += 256) % (DRAM_SIZE);
}

//Set Associative Cache
cacheResType setAssociativeCache(uint addr, uint mays)
{	
	return MISS;
}

string msg[2] = {"Miss", "Hit"};

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

bool booleanInput()
{
	std::string choice;
	std::cin >> choice;

	while ((choice[0] != 'N') && (choice[0] != 'n') && (choice[0] != 'Y') && (choice[0] != 'y'))
	{
		std::cout << "Invalid. [Y\\n case insensitive]: ";
		std::cin >> choice;
	}

	if ((choice[0] == 'y') || (choice[0] == 'Y')) return true;
	else return false;

} //Yes/No function

int main(int argc, char** argv)
{
	cacheResType r;	
	uint addr, memgenPick, cachePick;
	uint criterion;
	string buffer;
	bool silent = false;

	function<uint()> memgen;
	Cache *cache;

	if (argc > 1)
	{
		string argument = argv[1];
		if (argument == "-s" || argument == "--SILENT")
		{
			silent = true;
		}
	}

	if (!silent)
	{
		cout << "Cache Simulator\n";
		cout << "Which memory generator to use? [1-6 incl.]: ";
	}
	cin >> buffer;
	memgenPick = verifyNumber(buffer, "Not a number. Retry: ");
	while ((memgenPick < 1) || (memgenPick > 6))
	{
		cout << "Number out of range [1-6 incl.] Retry: ";
		cin >> buffer;
		memgenPick = verifyNumber(buffer, "Not a number. Retry: ");
	}

	switch (memgenPick)
	{
		case 1:
			memgen = memGen1;
			break;
		case 2:
			memgen = memGen2;
			break;
		case 3:
			memgen = memGen3;
			break;
		case 4:
			memgen = memGen4;
			break;
		case 5:
			memgen = memGen5;
			break;
		default:
			memgen = memGen6;
			break;
	}

	if (!silent)
	{
		cout << "Which kind of cache do you want to use?\n";
		cout << "(1: Directly Mapped, 2: Set Associative, 3: Fully Associative): ";
	}
	cin >> buffer;
	cachePick = verifyNumber(buffer, "Not a number. Retry: ");
	while ((cachePick < 1) || (cachePick > 3))
	{
		cout << "Number out of range [1-3 incl.] Retry: ";
		cin >> buffer;
		cachePick = verifyNumber(buffer, "Not a number. Retry: ");
	}

	switch (cachePick)
	{
		case 1:
			if (!silent)
			{
				cout << "Cache size (in bytes, power of 2): ";
			}
			cin >> buffer;
			criterion = verifyNumber(buffer, "Not a number. Retry: ");
			while (!Cache::checkSize(criterion))
			{
				cout << "Size pick not a power of 2. Retry: ";
				cin >> buffer;
				criterion = verifyNumber(buffer, "Not a number. Retry: ");
			}

			int blockSize;
			if (!silent)
			{
				cout << "Block size (in bytes): ";
			}
			cin >> buffer;
			blockSize = verifyNumber(buffer, "Not a number. Retry: ");
			while (criterion % blockSize != 0)
			{
				cout << "Size pick not divisible by block size. Retry: ";
				cin >> buffer;
				blockSize = verifyNumber(buffer, "Not a number. Retry: ");
			}

			cache = new DirectMappedCache(criterion, blockSize);
			break;
		case 2:
			if (!silent)
			{
				cout << "Ways (power of 2): ";
				cin >> buffer;
			}
			criterion = verifyNumber(buffer, "Not a number. Retry: ");
			while (!Cache::checkSize(criterion))
			{
				cout << "Number not a power of 2. Retry: ";
				cin >> buffer;
				criterion = verifyNumber(buffer, "Not a number. Retry: ");
			}

			cache = new SetAssociativeCache(SET_ASSOCIATIVE_SIZE, criterion, RANDOM);
			break;
		
		default:
			if (!silent)
			{		
				cout << "Cache size (in bytes, power of 2, multiple of 32): ";
			}
			cin >> buffer;
			criterion = verifyNumber(buffer, "Not a number. Retry: ");
			while (!Cache::checkSize(criterion) || criterion % 32 != 0)
			{
				cout << "Size pick either indivisible by 32 or not a power of 2. Retry: ";
				cin >> buffer;
				criterion = verifyNumber(buffer, "Not a number. Retry: ");
			}

			uint replacement;
			if (!silent)
			{
				cout << "Replacement Policy [1: Least Frequently Used, 2: Least Recently Used, 3: First In First Out, 4: Random]: ";
			}
			cin >> buffer;
			replacement = verifyNumber(buffer, "Not a number. Retry: ");
			while ((replacement < 1) || (replacement > 4))
			{
				cout << "Number out of range [1-4 incl.] Retry: ";
				cin >> buffer;
				replacement = verifyNumber(buffer, "Not a number. Retry: ");
			}

			cache = new SetAssociativeCache(criterion, criterion/SET_ASSOCIATIVE_BLOCKSIZE, static_cast<replacementPolicy>(replacement));
			break;
	}

	bool show;
	if (!silent)
	{
		cout << "Show individual accesses? [Y\\n]: ";
		show = booleanInput();
	}
	else
	{
		show = false;
	}

	uint sum = 0;

	for (uint inst = 0; inst < ITERATIONS; inst++)
	{
		addr = memgen();
		r = cache->access(inst, addr);
		if (r == HIT)
		{
			sum++;
		}
		if (show)
		{
			cout << "0x" << setfill('0') << setw(8) << hex << addr << " (" << dec << addr << "): " << msg[r] << ".\n";
		}
	}
	
	float percentage = float(sum) / float(ITERATIONS);

	cout << "Hit percentage: " << setiosflags(ios::fixed) << setprecision(2) << percentage * 100.0 << "%" << endl;

	return 0;
}