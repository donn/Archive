#include <cmath>
#include <stdexcept>
#include <iostream>
#include "Caches.h"
using namespace std;

bool Cache::checkSize(uint size)
{
    float power = log2(size);
    if (power < 0)
        return false;
    return (power - floor(power)) == 0.0;
}

dmcBlock::dmcBlock()
{
    v = false;
    tag = 0xC01D; //cold start
}

DirectMappedCache::DirectMappedCache(uint sizeR, uint blockSizeR)
{
    size = sizeR;
    blockSize = blockSizeR;
    blockCount = size / blockSize;
    for (uint i = 0; i < blockCount; i++)
    {
        blocks.push_back(dmcBlock());
    }
    offsetBits = log2(blockSize);
    indexBits = log2(blockCount);
    indexMask = (1 << indexBits) - 1;
}

cacheResType DirectMappedCache::access(uint iteration, uint address)
{
    uint index = (address >> offsetBits) & indexMask;
    uint tag = address >> (offsetBits + indexBits);
    if(blocks[index].v && (blocks[index].tag == tag))
    {
        return HIT;
    }
    else
    {
        blocks[index].v = true;
        blocks[index].tag = tag;
        return MISS;
    }
    
}

sacBlock::sacBlock()
{
    v = false;
    tag = 0xC01D;
}

SetAssociativeCache::SetAssociativeCache(uint sizeR, uint numWays, replacementPolicy policyR)
{
    size = sizeR;
    blockSize = SET_ASSOCIATIVE_BLOCKSIZE;
    policy = policyR;
    blockCount = size / blockSize;
    ways = numWays;
    uint setCount = blockCount / ways;

    usedBlocks = new uint[setCount];
    for (uint i = 0; i < setCount; i++)
    {
        sets.push_back(vector<sacBlock>());
        for (uint j = 0; j < ways; j++)
        {
            sets[i].push_back(sacBlock());
        }
        usedBlocks[i] = 0;
    }

    offsetBits = log2(blockSize);
    indexBits = log2(setCount);
    indexMask = (1 << indexBits) - 1;
    srand(0x11037);
/*

    size = sizeR;
    policy = policyR;
    blockCount = size / FULLY_ASSOCIATIVE_BLOCKSIZE;
    for (uint i = 0; i < blockCount; i++)
    {
        blocks.push_back(facBlock());
    }
    offsetBits = log2(FULLY_ASSOCIATIVE_BLOCKSIZE);
    usedBlocks = 0;
    srand(0x11037);
    */
}

cacheResType SetAssociativeCache::access(uint iteration, uint address)
{
    
    uint index = (address >> offsetBits) & indexMask;
    uint tag = address >> (offsetBits + indexBits);
    
   /* for (int i = 0; i < ways; i++)
    {
        if (sets[index][i].v && (sets[index][i].tag == tag))
        {
            return HIT;
        }
    }

    //MISS
    uint target = rand() % ways;
    sets[index][target].tag = tag;
    sets[index][target].v = true;
    return MISS;*/

    // uint tag = iteration >> offsetBits;
    
    if (usedBlocks[index] != 0)
    {        
        for (int i = 0; i < ways; i++)
        {
            if (sets[index][i].v && sets[index][i].tag == tag)
            {
                switch (policy)
                {
                    case LRU:
                        sets[index][i].criteria = iteration;
                        break;
                    case LFU:
                        sets[index][i].criteria++;
                        break;
                    default:
                        break;
                }

                return HIT;
            }
        }
    }
    

    //MISS
    uint target = 0xC01D;
    uint min;
    switch (policy)
    {
        
        case FIFO:
        case LRU:
            min = 0xFFFFFFFF;
            if (usedBlocks[index] < ways)
            {
                sets[index][usedBlocks[index]].v = true;
                sets[index][usedBlocks[index]].tag = tag;
                sets[index][usedBlocks[index]].criteria = iteration;
                usedBlocks[index] += 1;
                return MISS;
            }
            for (uint i = 0; i < usedBlocks[index]; i++)
            {
                if (sets[index][i].criteria < min)
                {
                    min = sets[index][i].criteria;
                    target = i;
                }
            }

            sets[index][target].tag = tag;
            sets[index][target].criteria = iteration;

            break;
        case LFU:
            min = 0xFFFFFFFF;
            if (usedBlocks[index] < ways)
            {
                sets[index][usedBlocks[index]].v = true;
                sets[index][usedBlocks[index]].tag = tag;
                sets[index][usedBlocks[index]].criteria = 0;
                usedBlocks[index] += 1;
                return MISS;
            }
            for (uint i = 0; i < usedBlocks[index]; i++)
            {
                if (sets[index][i].criteria < min)
                {
                    min = sets[index][i].criteria;
                    target = i;
                }
            }

            sets[index][target].tag = tag;
            sets[index][target].criteria = 0;
            
            break;

        default: //random
    
            usedBlocks[index] += 1;
            target = rand() % ways;
            sets[index][target].tag = tag;
            sets[index][target].v = true;
    
    }
    return MISS;
}