BITS 32

IMAGE_BASE equ 0x400000
org 0

%define align(n, r) (((n+(r-1))/r)*r)

; DOS header
DOS_HEADER:
    dw "MZ"                 ; DOS Magic number
    push edx;
    inc ebp;
    push esp;
    pop esi;
    push ecx;
    pop eax;
    xor al, 0x66;
    push eax;
    pop esp;
    push 0x24;
    pop eax;
    sub al, 0x61;
    push eax;
    push esi;
    pop esp;
    jnz short 0x62;
    times 60 - ($ - DOS_HEADER) db 0;
    dd PE_HEADER            ; Address of beginning of PE header

; End of DOS header


; Start of PE header
PE_HEADER:
    dw "PE", 0              ; PE signature "PE\0\0"

; Mandatory COFF/Image file header
COFF_FILE_HEADER:
    dw 0x14C                ; Machine (Intel 386)
    dw 0                    ; NumberOfSections (0)
    dd 0                    ; TimeDateStamp (Wednesday, 24.06.2026 10:26:47 UTC)
    dd 0                    ; PointerToSymbolTable [0 for images]
    dd 0                    ; NumberOfSymbols [0 for images]
    dw 0x68                 ; SizeOfOptionalHeader (usually 0xE0 for this type of app cause 32 bit)
    dw 0x52                 ; Characteristics (0x01 -> No relocation info present; 0x02 -> executable file; 0x100 -> 32 bit machine)

; Mandatory image file "optional header"
IMAGE_OPTIONAL_HEADER:
    ; Mandatory "optional header" standard fields
    dw 0x10B                ; Magic number (indicates PE32)
    db 0                    ; MajorLinkerVersion
    db 0                    ; MinorLinkerVersion
    dd 0                    ; Total size of code sections (0 bytes)
    dd 0                    ; Total size of initialised data sections (0 bytes)
    dd 0                    ; Total size of uninitialised data sections (0 bytes)
    dd 0                    ; RVA of entry point (literally 0 here lol)
    dd 0                    ; RVA of beginning of code section when loaded
    dd 0                    ; RVA of beginning of data section when loaded

    ; Mandatory Windows-specific "optional header" fields

    dd IMAGE_BASE           ; My funny preferred base of image
    dd 0x40                 ; Alignment of sections when loaded into memory
    dd 0x40                 ; Alignment of raw data of sections in image file (honestly not sure on the difference)
                            ; Listed requirements for these two fields are: SectionAlignment >= FileAlignment, FileAlignment must be power of 2, and if SectionAlignment is < page size, then FileAlignment == SectionAlignment.
                            ; To be honest, if the loader patches something in to fix these fields when I go to overlap these stuff that would be funny.
    dw 0                    ; Major operating system version (indicates Windows Vista/Server 2008)
    dw 0                    ; Minor operating system version
    dw 0                    ; Major image version
    dw 0                    ; Minor image version
    dw 4                    ; Major subsystem version
    dw 0                    ; Minor subsystem version
    dd 0                    ; Reserved field for Win32 version value, though it is claimed this must be 0.
    dd 0x6a70               ; Size of image total when loaded into memory. Claimed that this must be a multiple of section alignment. 
                            ; In reality it seems that it can be whatever you want provided it's larger than perhaps size of code or something?
    dd 0                    ; Size of headers total in the file, rounded up to a multiple of FileAlignment
    dd 0                    ; Checksum, seemingly unused
    dw 3                    ; Subsystem, 3 indicates Windows CUI
    dw 0                    ; DLL Characterstics, (0x8000 -> TerminalServer aware, 0x400 -> Image does not use SEH, 0x100 -> Image is NX compatible)
    dd 0                    ; Size of stack reserve, some sort of something idk
    dd 0                    ; Size of stack commit
    dd 0                    ; Size of heap reserve
    dd 0                    ; Size of heap commit
    dd 0                    ; Loader flags, apparently must be 0
    dd 0                    ; Number of entries in the data directory table, of which there are none here.

    ; Optional header data directories (empty)

    ; End of PE header

OPTIONAL_HEADER_SIZE equ $ - IMAGE_OPTIONAL_HEADER
HEADER_SIZE equ $ - $$


times align($ - PE_HEADER, 264) - ($ - PE_HEADER) db 0
                            ; Padding to hit the minimum 
times align($ - $$, 16) - ($ - $$) db 0
                            ; Pad to 16 byte boundary cause I'm nice.
FILE_SIZE equ $ - $$