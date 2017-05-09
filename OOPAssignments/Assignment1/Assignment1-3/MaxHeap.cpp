#include "MaxHeap.h"

MaxHeap::MaxHeap(int size)
{
    MaxSize = size;
    array = new int[MaxSize + 1];
    array[0] = INT_MAX;
    Nel = 0;
}


MaxHeap::MaxHeap(const MaxHeap &original)
{
    MaxSize = original.MaxSize;
    array = new int[MaxSize + 1];

    for (int i = 0; i <= MaxSize; i++)
    {
        array[i] = original.array[i];
    }
    Nel = original.Nel;
}


MaxHeap::~MaxHeap()
{
    delete[] array;
}


bool MaxHeap::Insert(int item) 
{
    int i = ++Nel; 
    if (i == ( MaxSize + 1 )) 
    { 
        Nel--; 
        throw "Heap is full.";
    }    
    while ((i > 1) && (array[i / 2] < item)) 
    { 
        array[i] = array[i / 2]; 
        i /= 2; 
    } 
    array[i] = item; 
    return true; 
} 


bool MaxHeap::DelMax(int & item) 
{ 
    if (!Nel) 
    {
        throw "Heap is empty.";
    }
    item = array[1]; 
    array[1] = array[Nel--]; 
    Adjust(1); 
    return true; 
}


void MaxHeap::Adjust(int i) //Apparently Downheaping is "Adjusting" now.
{ 
    int j = 2 * i, item = array[i]; 
    while (j <= Nel) 
    {
        if ((j < Nel) && (array[j] < array[j+1])) 
            j++;
        if (item >= array[j]) 
            break;
         array[j / 2] = array[j]; 
         j *= 2; 
    }
    array[j / 2] = item; 
}


MaxHeap MaxHeap::operator+(const MaxHeap& right)
{
    MaxHeap result(MaxSize + right.MaxSize);

    for (int i = 1; i <= MaxSize; i++)
    {
        result.Insert(array[i]);
    }

    for (int i = 1; i <= right.MaxSize; i++)
    {
        result.Insert(right.array[i]);
    }

    return result;
}


MaxHeap MaxHeap::operator+(const int& right)
{
    MaxHeap result(MaxSize);

    for (int i = 1; i <= MaxSize; i++)
    {
        result.Insert(array[i]);
    }

    result.Insert(right);

    return result;
}


MaxHeap& MaxHeap::operator=(const MaxHeap& original)
{
    MaxSize = original.MaxSize;
    array = new int[MaxSize + 1];

    for (int i = 0; i <= MaxSize; i++)
    {
        array[i] = original.array[i];
    }
    Nel = original.Nel;

    return *this;
}


void MaxHeap::operator+=(const MaxHeap& right)
{
    for (int i = 1; i <= MaxSize; i++)
    {
        Insert(right.array[i]);
    }
}


void MaxHeap::operator+=(const int& right)
{
    Insert(right);
}


int MaxHeap::operator[](const int index)
{
    if (index > MaxSize)
    {
        throw "Element out of bounds.";
    }

    int* stack = new int[index];

    for (int i = 0; i < index; i += 1)
    {
        DelMax(stack[i]);
    }

    int value = stack[index - 1];

    for (int i = 0; i < index; i += 1)
    {
        Insert(stack[i]);
    }

    delete[] stack;

    return value;
}


std::ostream& operator<<(std::ostream& o, const MaxHeap& heap)
{
    o << '[' << heap.array[1];

    for (int i = 2; i < heap.MaxSize; i++)
    {
        o << ',' << ' ';
        o << heap.array[i];
    }

    o << ',' << ' ' << heap.array[heap.MaxSize] << ']';
    return o;
}