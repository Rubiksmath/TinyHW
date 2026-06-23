#include <windows.h>
_(){
    DWORD written;
    WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), "Hello, World!\r\n", 0x0F, &written, NULL);
}