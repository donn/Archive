#include "Set.h"

Set::Set()
{
    for (u8 i = 0; i < 8; i++)
    {
        storage[i] = 0;
    }
}

void Set::insert(int number)
{
    if ((number >> 8) != 0)
    {
        throw "Value is too large."; 
    }

    u8 _8bit = number & 0xFF;
    auto loc = _8bit >> 5;

    storage[loc] = storage[loc] | (1 << (_8bit & 0x1F));
}

void Set::remove(int number)
{
    if ((number >> 8) != 0)
    {
        throw "Value is too large."; 
    }

    u8 _8bit = number & 0xFF;
    auto loc = _8bit >> 5;

    storage[loc] = storage[loc] & ~(1 << (_8bit & 0x1F));
}

bool Set::check(int number)
{
    if ((number >> 8) != 0)
    {
        throw "Value is too large."; 
    }

    u8 _8bit = number & 0xFF;
    auto loc = _8bit >> 5;

    return (storage[loc] >> (_8bit & 0x1F)) & 1;
}

void Set::insert(u8 number)
{
    auto loc = number >> 5;

    storage[loc] = storage[loc] | (1 << (number & 0x1F));
}

void Set::remove(u8 number)
{
    auto loc = number >> 5;

    storage[loc] = storage[loc] & ~(1 << (number & 0x1F));
}

bool Set::check(u8 number)
{
    auto loc = number >> 5;

    return (storage[loc] >> (number & 0x1F)) & 1;
}
