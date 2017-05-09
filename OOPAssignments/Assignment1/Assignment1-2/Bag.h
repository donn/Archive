/*
    Embedded Bag Class

    A bag class that deals with octets.
*/
#pragma once
#ifndef _bag_h
#define _bag_h
#include <cstdint>
#define u8 uint8_t

//Memory footprint: 257 bytes

class Bag
{
private:
    u8 storage[256];
    bool moved;
public:
    Bag();

    void insert(int); //O(1).
    void remove(int); //O(1).
    u8 check(int); //O(1).

    void insert(u8); //O(1).
    void remove(u8); //O(1).
    u8 check(u8); //O(1). 

};
#endif