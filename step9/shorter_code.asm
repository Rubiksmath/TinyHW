push 0;                                             ; Fifth argument, unused                
push 0;                                             ; Fourth argument, unused
push 0xE;                                           ; Third argument, number of bytes to write (14)
lea eax, [ecx + 30];                ; Calculate second argument, pointer to string
push eax;                                           ; Push it
mov eax, [ebx + 0x10];                              ; Getting address of PEB
push [eax + 0x1C];                                  ; Push offset 0x1C as this is the handle we want
call [ecx + 90];    ; Call WriteFile using relative address from ecx
ret;                                                ; Exit safely to prevent errors being thrown     