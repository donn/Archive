#include "Bag.h"

Bag::Bag()
{
    for (int i = 0; i < 256; i++)
    {
        storage[i] = 0;
    }
}

void Bag::insert(int number)
{
    if ((number >> 8) != 0)
    {
        throw "Value is too large."; 
    }

    if (number == 255)
    {
        throw "Element is already maxed out."; 
    }

    storage[number] += 1;
}

void Bag::remove(int number)
{
    if ((number >> 8) != 0)
    {
        throw "Value is too large."; 
    }

    if (storage[number] == 0)
    {
        throw "No elements to remove.";
    }

    storage[number] -= 1;
    
    storage[number] -= 1;
}

u8 Bag::check(int number)
{
    if ((number >> 8) != 0)
    {
        throw "Value is too large."; 
    }

    return storage[number];
}

void Bag::insert(u8 number)
{
    if (number == 255)
    {
        throw "Element is already maxed out."; 
    }

    storage[number] += 1;
}

void Bag::remove(u8 number)
{
    if (storage[number] == 0)
    {
        throw "No elements to remove.";
    }
    storage[number] -= 1;
}

u8 Bag::check(u8 number)
{
    return storage[number];
}
