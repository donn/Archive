#include "MaxHeap.h"

int main(int argc, char** argv)
{
    int a[] = {0, 5, 401, 6, 1, 2, 40, 59};
    int b[] = {159, 2, 35, 63, 21, 45, 12, 999};

    MaxHeap A(20);
    MaxHeap B(20);
    for (int i = 0; i < 8; i ++)
    {
        A.Insert(a[i]);
        B.Insert(b[i]);
    }

    std::cout << A << std::endl << B << std::endl;

    auto sum = A + B;
    std::cout << sum << std::endl << sum[3] << ", " << sum[3] << std::endl;

    B = A;
    A.Insert(400);

    auto sum2 = B + B;
    std::cout << sum2 << std::endl;

    int garbage;

    A.DelMax(garbage);
    std::cout << A << std::endl;

    try
    {
        A += B;
    }
    catch (const char *e)
    {
        std::cout << e;
    }

    std::cout << " A and most of B: " << A << std::endl;

    try
    {
        A[21];
    }
    catch (const char *e)
    {
        std::cout << e;
    }

    std::cout << std::endl;

#ifdef _MSC_VCR
    system("pause");
#endif

    return 0;
}