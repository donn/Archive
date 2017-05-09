/*
    Embedded Set Class

    A set class that deals with octets.
*/


#pragma once
#ifndef _set_h
#define _set_h
//Depending on your compiler, the number of bits may change- please be sure to change those.
#define u32 unsigned int
#define u8 unsigned char

class Set
{
private:
    u32 storage[8];
    bool moved;
public:
    Set();
    //Copy, move and destructor implicit
    //Set(A&); //Copy constructor: O(n)
    //Set(Set&&); //Move constructor: O(1)
    //~Set(); //Destructor: Depending on C++'s mood.

    void insert(int); //O(1).
    void remove(int); //O(1).
    bool check(int); //O(1).

    void insert(u8); //O(1).
    void remove(u8); //O(1).
    bool check(u8); //O(1). 

};
#endif