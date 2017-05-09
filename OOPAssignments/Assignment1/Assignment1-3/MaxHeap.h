#pragma once
#include <iostream>
#include <climits>

class MaxHeap
{
    int* array;
    int MaxSize, Nel;
    void Adjust(int);

public: 
    MaxHeap(int size);
    MaxHeap(const MaxHeap &original);
    ~MaxHeap();


    friend std::ostream& operator<<(std::ostream& o, const MaxHeap& heap);
        
    bool Insert(int item);
    bool DelMax(int& item);
    MaxHeap operator+(const MaxHeap& right);
    MaxHeap operator+(const int& right);
    MaxHeap& operator=(const MaxHeap& original);
    void operator+=(const MaxHeap& right);
    void operator+=(const int& right);
    int operator[](const int index);
};