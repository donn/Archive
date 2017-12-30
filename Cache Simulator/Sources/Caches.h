#include <vector>
#include "Types.h"
using namespace std;

enum cacheResType
{
	MISS=0,
	HIT
};

enum replacementPolicy
{
	LRU = 1,
	LFU,
	FIFO,
	RANDOM
};

class Cache //Protocol
{
public:
	virtual cacheResType access(uint iteration, uint address) { return MISS; };
	static bool checkSize(uint size);
};

struct dmcBlock
{
	bool v;
	uint tag;
	dmcBlock();
};

class DirectMappedCache: public Cache
{
	vector<dmcBlock> blocks;

	uint size; //Cache size in bytes
	uint blockSize; //Block size in bytes
	uint blockCount; //Number of blocks
	uint offsetBits;
	uint indexBits;
	uint indexMask;

public:	
	DirectMappedCache(uint sizeR, uint blockSizeR);
	cacheResType access(uint iteration, uint address);
};


struct sacBlock
{	
	bool v; // valid
	uint tag;
	uint criteria;
	sacBlock();
};

#define FULLY_ASSOCIATIVE_BLOCKSIZE 32
#define SET_ASSOCIATIVE_SIZE 65536
#define SET_ASSOCIATIVE_BLOCKSIZE 32

class SetAssociativeCache: public Cache
{
	vector<vector<sacBlock>> sets;
	replacementPolicy policy;
	uint ways;
	uint size;
	uint blockSize;
	uint blockCount;
	uint offsetBits;
	uint indexBits;
	uint indexMask;
	uint *usedBlocks;

public:
	SetAssociativeCache(uint sizeR, uint numWays, replacementPolicy policyR);
	cacheResType access(uint iteration, uint address);
};