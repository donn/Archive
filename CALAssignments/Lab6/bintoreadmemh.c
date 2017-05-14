#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sysexits.h>

#define string const char *
#define uint unsigned in
#define u8 uint8_t
#define u32 uint32_t

int main(int argc, char** argv)
{
    if (argc != 2)
    {
        printf("Too many arguments. (%i/1)", argc - 1);
        return EX_USAGE;
    }
    
    string path = argv[1];   

    FILE *in = fopen(path, "r");
    FILE *out = fopen("rom.txt", "w");

    while (1)
    {
        u32 machineCode = fgetc(in);
        if (feof(in))
        {
            goto exit;
        }
        machineCode |= fgetc(in) << 8;
        machineCode |= fgetc(in) << 16;
        machineCode |= fgetc(in) << 24;
        fprintf(out, "%08x\n", machineCode);
        printf("%08x\n", machineCode);
    }
    exit:
    
    fclose(in);
    fclose(out);

    return 0;    
}