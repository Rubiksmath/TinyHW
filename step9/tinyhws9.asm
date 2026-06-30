BITS 32

IMAGE_BASE equ 0x690000
org 0

%define align(n, r) (((n+(r-1))/r)*r)

; DOS header
DOS_HEADER:
    dw "MZ"                 ; DOS Magic number
    dw 0                    ; [UNUSED/FREE] Bytes on last page

; Start of PE header, with greedy earliest placement I could get to work
PE_HEADER:
    dw "PE"                 ; [UNUSED/FREE] Pages in File                           ; PE signature part 1 "PE"    
    dw 0                    ; [UNUSED/FREE] Relocations                             ; PE signature part 2 "\0\0"

; Mandatory COFF/Image file header
COFF_FILE_HEADER:
    dw 0x14C                ; [UNUSED/FREE] Size of header (paragraphs)             ; Machine (Intel 386)
    dw 1                    ; [UNUSED/FREE] Minimum memory (paragraphs?)            ; Number of sections (1)

; 2nd code fragment (execution wise)
CODE_FRAGMENT_2:
    lea eax, [ecx + DATA - ENTRY_POINT];
                            ; [UNUSED/FREE] Maximum memory (paragraphs?)            ; [UNUSED/FREE] TimeDateStamp part 1 
                            ; [UNUSED/FREE] Initial stack segment value (relative) part 1
                                                                                    ; [UNUSED/FREE] TimeDateStamp part 2       
                                                                                                                                ; Second argument to WriteFile, long pointer to buffer, which is just at RVA of DATA
    push eax;               ; [UNUSED/FREE] Initial stack segment value (relative) part 2
                                                                                    ; [UNUSED/FREE] TimeDateStamp part 3
                                                                                                                                ; Push it
    mov eax, [ebx + 0x10];  ; [UNUSED/FREE] Initial stack pointer value (relative)  ; [UNUSED/FREE] PointerToSymbolTable part 1
                            ; [UNUSED/FREE] Checksum part 1                         ; [UNUSED/FREE] PointerToSymbolTable part 2 
                                                                                                                                ; Calculating handle by looking into PEB idk I just copied the implementation of the kernel DLL don't ask
    push [eax + 0x1C];      ; [UNUSED/FREE] Checksum part 2                         ; [UNUSED/FREE] PointerToSymbolTable part 3
                            ; [UNUSED/FREE] Initial instruction pointer value       ; [UNUSED/FREE] NumberOfSymbols part 1
                                                                                                                                ; First argument to WriteFile, the handle of the "file" or "stream" to write to

    jmp CODE_FRAGMENT_3;    ; [UNUSED/FREE] Initial code segment value (relative)   ; [UNUSED/FREE] NumberOfSymbols part 2      ; Get outta here, no more space for instructions
    dw OPTIONAL_HEADER_SIZE ; [UNUSED/FREE] Address of DOS reloation table          ; SizeOfOptionalHeader
    dw 2                    ; [UNUSED/FREE] Overlay number                          ; [RESTRICTED BUT MODIFIABLE] Characteristics (only need the 2nd least significant bit set)

; Mandatory image file "optional header"
IMAGE_OPTIONAL_HEADER:

    ; Mandatory "optional header" standard fields
    dw 0x10B                ; [UNUSED/FREE] Reserved words list 1 (4) part 1        ; Magic number (indicates PE32)

; Initialised data store
DATA:
    db "H"                  ; [UNUSED/FREE] Reserved words list 1 (4) part 2        ; [UNUSED/FREE] MajorLinkerVersion                                  ; String to print part 1
    db "e"                  ; [UNUSED/FREE] Reserved words list 1 (4) part 3        ; [UNUSED/FREE] MinorLinkerVersion                                  ; String to print part 2
    db "llo,"               ; [UNUSED/FREE] Reserved words list 1 (4) part 4        ; [UNUSED/FREE] Total size of code sections                         ; String to print part 3
    db " W"                 ; [UNUSED/FREE] OEM identifier                          ; [UNUSED/FREE] Total size of initialised data sections part 1      ; String to print part 4
    db "or"                 ; [UNUSED/FREE] OEM information                         ; [UNUSED/FREE] Total size of initialised data sections part 2      ; String to print part 5
    db `ld!\n`              ; [UNUSED/FREE] Reserved words list 2 (10) part 1       ; [UNUSED/FREE] Total size of uninitialised sections                ; String to print part 6
    dd ENTRY_POINT          ; [UNUSED/FREE] Reserved words list 2 (10) part 2       ; RVA of entry point (can be modified in theory as this is just an RVA so the section stuff can go crazy)

; Name of DLL 1
DLL_NAME_1:   
    db "KERN"               ; [UNUSED/FREE] Reserved words list 2 (10) part 3       ; [UNUSED/FREE] RVA of beginning of code section when loaded        ; Name of DLL 1 from the import directory/table, with .dll omitted because it's not needed! part 1         
    db "EL32"               ; [UNUSED/FREE] Reserved words list 2 (10) part 4       ; [UNUSED/FREE] RVA of beginning of data section when loaded        ; Name of DLL 1 from the import directory/table, with .dll omitted because it's not needed! part 2 

    ; Mandatory Windows-specific "optional header" fields
    dd IMAGE_BASE           ; [UNUSED/FREE] Reserved words list 2 (10) part 5       ; My funny preferred base of image
    dd PE_HEADER            ; Address of beginning of PE header                     ; Alignment of sections when loaded into memory (0x04, dual purpose field)

; End of DOS header

    dd 0x04                 ; Alignment of raw data of sections when loaded into memory (to match dual purpose field)
                            ; Listed requirements for these two fields are: 
                            ; SectionAlignment >= FileAlignment
                            ; FileAlignment must be power of 2
                            ; If SectionAlignment is < page size, then FileAlignment == SectionAlignment.
                            ; To be honest, if the loader patches something in to fix these fields when I go to overlap these stuff that would be funny.

; Entry point of execution / first code fragment (execution wise)
ENTRY_POINT:
    push 0;                 ; [UNUSED/FREE] Major operating system version          ; Fifth argument to WriteFile, long pointer to overlap status. Turns out this can be null and it works.
    push 0;                 ; [UNUSED/FREE] Minor operating system version          ; Fourth last argument to WriteFile, long pointer to number of bytes written. Turns out this can be null and it works.                                          
    push 0xE;               ; [UNUSED/FREE] Major image version                     ; Third argument to WriteFile, number of bytes to write, which is just 0xE (14) (sorry, I had to drop the carriage return to make it fit, so its just \n now instead of \r\n)
    jmp CODE_FRAGMENT_2;    ; [UNUSED/FREE] Minor image version                     ; Get outta here, can't write any more instructions.
    dw 4                    ; [RESTRICTED BUT MODIFIABLE] Major subsystem version (4, 5, or 6) 
    dw 0                    ; [RESTRICTED BUT MODIFIABLE] Minor subsystem version (free if previous field 4)

; Code fragment 3 (execution wise)
CODE_FRAGMENT_3:
    
    call [ecx + IMPORT_ADDRESS_TABLE - ENTRY_POINT];   
                                                ; [UNUSED/FREE] Win32 version field part 1
                                                                                    ; Call the thing
    ret;                                        ; [UNUSED/FREE] Win32 version field part 2
                                                                                    ; Only effect is to adjust stack pointer (inner function that we call actually resets the stack pointer for us which is so kind)
                                                                                    ; And to pop the top of the stack into the instruction pointer

    dd 0xB4                 ; [RESTRICTED BUT MODIFIABLE] Size of image total when loaded into memory (seems to let me go anything F0 or higher, also don't go higher than 0x70000000)
                            ; In reality it seems that it can be whatever you want provided it's larger than perhaps size of code or something?
    dd 0                    ; [RESTRICTED BUT MODIFIABLE] Size of headers total in the file, rounded up to a multiple of FileAlignment (seems to let me go anything < claimed image size in previous field) 
    dd 0                    ; [UNUSED/FREE] Checksum, seemingly unused
    dw 3                    ; Subsystem, 3 indicates Windows CUI
    dw 0                    ; [RESTRICTED BUT MODIFIABLE] DLL Characterstics (compiler generated 0x8500)                                                                                      
    dd 0                    ; [RESTRICTED BUT MODIFIABLE] Size of stack reserve (don't go too big, i.e. maybe keep below 0x70000000) 
    dd 0                    ; [RESTRICTED BUT MODIFIABLE] Size of stack commit (don't go too big, i.e. maybe keep below 0x70000000) 
    dd 0                    ; [RESTRICTED BUT MODIFIABLE] Size of heap reserve (don't go too big, i.e. maybe keep below 0x70000000)
    dd 0                    ; [RESTRICTED BUT MODIFIABLE] Size of heap commit (don't go too big, i.e. maybe keep below 0x70000000)
    dd 0                    ; [UNUSED/FREE] Loader flags
    dd 0x2                  ; Number of entries in the data directory table, here only 2 are needed

    ; Optional header data directories

; Import address table
IMPORT_ADDRESS_TABLE:
                            ; Structure and content of import address table is identical to the import lookup table until the file is bound by the loader. 
                            ; The addresses here get patched to the memory addresses of the imported symbols.
    dd HINT_NAME_TABLE      ; RVA of the entry into the hint/name table for this import
                                                                                    ; [UNUSED/FREE] Export table RVA
    dd 0                    ; Null terminator entry 
                                                                                    ; [UNUSED/FREE] Export table size               
    dd IMPORT_DIRECTORY     ; Import table RVA

; Import directory
IMPORT_DIRECTORY:
                            ; Entry 1 (KERNEL32.dll)
; Hint/name table
HINT_NAME_TABLE:
                            ; Entry 1 (WriteFile)
    dw 0                    ; [UNUSED/FREE] Import table size part 1                ; [UNUSED/FREE] Function ordinal (loader attempts to match this first)      ; [UNUSED/FREE] RVA of import lookup table for entry 1 (place to look for data) part 1
    db "Wr"                 ; [UNUSED/FREE] Import table size part 2                ; Function name (loader only uses if match fails) part 1                    ; [UNUSED/FREE] RVA of import lookup table for entry 1 (place to look for data) part 2
    
    
    ; End of PE header

OPTIONAL_HEADER_SIZE equ $ - IMAGE_OPTIONAL_HEADER

; Section table
SECTION_TABLE:
    db "iteF"               ; [UNUSED/FREE] Name of first section, padded to 8 bytes part 1
                                                                                    ; Function name (loaded only uses if match fails) part 2                    ; [UNUSED/FREE] Zeroed Time/Date stamp for use as loader patches it              
    db "ile", 0             ; [UNUSED/FREE] Name of first section, padded to 8 bytes part 2
                                                                                    ; Function name (loaded only uses if match fails) part 3                    ; [UNUSED/FREE] Forwarder chain, whatever that means                                                                                    
    dd DLL_NAME_1           ; [RESTRICTED BUT MODIFIABLE] Virtual size of section when loaded into memory.                                                      ; RVA of string containing DLL name
                            ; If this is larger than the size of the raw data of the section, this gets zero padded.
                            ; (don't go too big, i.e. seems like the limit is 0xF10, or something.)
                                                                                    
    dd IMPORT_ADDRESS_TABLE ; [IN PRINCIPLE MODIFIABLE] Virtual address of section when loaded into memory, i.e. the offset from image base when loaded         ; RVA of import address table for entry 1 (place to write the results to)
                                                                                    
    dd 0xF0                 ; [RESTRICTED BUT MODIFIABLE] Size of the initialised data on disk for this section. Must be a multiple of file alignment from the optional header (wut), and this parameter is rounded, while virtual size is not.
                            ; Looks like it just has to be at least virtual size idk (It let me go as low as 0x41, and also up very high up to 0xFFFFFF0F, provided the virtualsize was not 0. When virtual size was 0, the size of this was much more limited)
                                                                                    ; RVA of a string containing the DLL name for this import
    db IMPORT_ADDRESS_TABLE ; [IN PRINCIPLE MODIFIABLE] File pointer to the first page of the section part 1 (try to modify in conjunction with virtual address and/or entry)
                                                                                    ; RVA of import address table for entry 1 (place to write the results to) part 1               
times align($ - $$, 268) - ($ - $$) db 0
                            ; [IN PRINCIPLE MODIFIABLE] File pointer to the first page of the section part 2 (try to modify in conjunction with virtual address and/or entry)
                            ; RVA of import address table for entry 1 (place to write the results to) part 2
                            ; [UNUSED/FREE] Pointer to relocations
                            ; [UNUSED/FREE] Pointer to line numbers
                            ; [UNUSED/FREE] Number of relocations
                            ; [UNUSED/FREE] Number of line numbers
                            ; [UNUSED/FREE] Section characteristics (Interesting that it lets me modify this freely?)        
                            ; Appease loader's undocumented hard floor of 268






    

    
