#include <windows.h>
_(){
    DWORD written;
    HANDLE h;
    __asm {
        mov eax, [ebx + 0x10];
        mov eax, [eax + 0x1C];
        mov h, eax;
    }
    WriteFile(h, "Hello, World!\r\n", 0x0F, &written, NULL);
}