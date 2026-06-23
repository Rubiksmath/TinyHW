BITS 32

IMAGE_BASE equ 0x690000
org 0

%define align(n, r) (((n+(r-1))/r)*r)

; DOS header
DOS_HEADER:
    dw "MZ"                 ; DOS Magic number
    dw 0                    ; [UNUSED/FREE] Bytes on last page
    dw 0                    ; [UNUSED/FREE] Pages in File
    dw 0                    ; [UNUSED/FREE] Relocations
    dw 0                    ; [UNUSED/FREE] Size of header (paragraphs)
    dw 0                    ; [UNUSED/FREE] Minimum memory (paragraphs?)
    dw 0                    ; [UNUSED/FREE] Maximum memory (paragraphs?)
    dw 0                    ; [UNUSED/FREE] Initial stack segment value (relative)
    dw 0                    ; [UNUSED/FREE] Initial stack pointer value
    dw 0                    ; [UNUSED/FREE] Checksum
    dw 0                    ; [UNUSED/FREE] Initial instruction pointer value
    dw 0                    ; [UNUSED/FREE] Initial code segment value (relative)
    dw 0                    ; [UNUSED/FREE] Address of DOS reloation table
    dw 0                    ; [UNUSED/FREE] Overlay number
    times 4 dw 0            ; [UNUSED/FREE] Reserved words (4)
    dw 0                    ; [UNUSED/FREE] OEM identifier
    dw 0                    ; [UNUSED/FREE] OEM information
    times 10 dw 0           ; [UNUSED/FREE] Reserved words part 2 (10)
    dd PE_HEADER            ; Address of beginning of PE header

; End of DOS header

; Start of PE header
PE_HEADER:
    dw "PE", 0              ; PE signature "PE\0\0"

; Mandatory COFF/Image file header
COFF_FILE_HEADER:
    dw 0x14C                ; Machine (Intel 386)
    dw 1                    ; NumberOfSections (1)
    dd 0                    ; [UNUSED/FREE] TimeDateStamp
    dd 0                    ; [UNUSED/FREE] PointerToSymbolTable
    dd 0                    ; [UNUSED/FREE] NumberOfSymbols
    dw OPTIONAL_HEADER_SIZE ; SizeOfOptionalHeader
    dw 2                    ; [RESTRICTED BUT MODIFIABLE] Characteristics (only need the 2nd least significant bit set)

; Mandatory image file "optional header"
IMAGE_OPTIONAL_HEADER:
    ; Mandatory "optional header" standard fields
    dw 0x10B                ; Magic number (indicates PE32)
    db 0                    ; [UNUSED/FREE] MajorLinkerVersion
    db 0                    ; [UNUSED/FREE] MinorLinkerVersion
    dd 0                    ; [UNUSED/FREE] Total size of code sections
    dd 0                    ; [UNUSED/FREE] Total size of initialised data sections
    dd 0                    ; [UNUSED/FREE] Total size of uninitialised data sections
    dd ENTRY_POINT          ; RVA of entry point (Note: needs to be calculated carefully with respect to what is in the section headers. Address in file = RVA - VA + pointer to raw data in section header.)
    dd 0                    ; [UNUSED/FREE] RVA of beginning of code section when loaded
    dd 0                    ; [UNUSED/FREE] RVA of beginning of data section when loaded

    ; Mandatory Windows-specific "optional header" fields

    dd IMAGE_BASE           ; My funny preferred base of image
    dd 0x10                 ; Alignment of sections when loaded into memory
    dd 0x10                 ; Alignment of raw data of sections when loaded into memory (honestly not sure on the difference)
                            ; Listed requirements for these two fields are: 
                            ; SectionAlignment >= FileAlignment
                            ; FileAlignment must be power of 2
                            ; If SectionAlignment is < page size, then FileAlignment == SectionAlignment.
                            ; To be honest, if the loader patches something in to fix these fields when I go to overlap these stuff that would be funny.
    dw 0                    ; [UNUSED/FREE] Major operating system version
    dw 0                    ; [UNUSED/FREE] Minor operating system version
    dw 0                    ; [UNUSED/FREE] Major image version
    dw 0                    ; [UNUSED/FREE] Minor image version
    dw 4                    ; [RESTRICTED BUT MODIFIABLE] Major subsystem version (4, 5, or 6) 
    dw 0                    ; [RESTRICTED BUT MODIFIABLE] Minor subsystem version (free if previous field 4) 
    dd 0                    ; [UNUSED/FREE] Win32 version field
    dd FILE_SIZE            ; [RESTRICTED BUT MODIFIABLE] Size of image total when loaded into memory (seems to let me go anything F0 or higher, also don't go higher than 0x70000000)
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

    dd 0                    ; [UNUSED/FREE] Export table RVA
    dd 0                    ; [UNUSED/FREE] Export table size
    dd IMPORT_DIRECTORY     ; Import table RVA
    dd 0                    ; [UNUSED/FREE] Import table size

    ; End of PE header

OPTIONAL_HEADER_SIZE equ $ - IMAGE_OPTIONAL_HEADER

; Section table
SECTION_TABLE:
    dq 0                    ; [UNUSED/FREE] Name of first section, padded to 8 bytes
    dd MAIN_SIZE            ; [RESTRICTED BUT MODIFIABLE] Virtual size of section when loaded into memory. 
                            ; If this is larger than the size of the raw data of the section, this gets zero padded.
                            ; (don't go too big, i.e. keep below size of raw data field)
    dd IMPORT_ADDRESS_TABLE ; [IN PRINCIPLE MODIFIABLE] Virtual address of section when loaded into memory, i.e. the offset from image base when loaded
    dd CODE_SIZE            ; [RESTRICTED BUT MODIFIABLE] Size of the initialised data on disk for this section. Must be a multiple of file alignment from the optional header (wut), and this parameter is rounded, while virtual size is not.
                            ; Looks like it just has to be at least virtual size idk (It let me go as low as 0x41, and also up very high up to 0xFFFFFF0F)
    dd IMPORT_ADDRESS_TABLE ; [IN PRINCIPLE MODIFIABLE] File pointer to the first page of the section (try to modify in conjunction with virtual address)
    dd 0                    ; [UNUSED/FREE] Pointer to relocations
    dd 0                    ; [UNUSED/FREE] Pointer to line numbers
    dw 0                    ; [UNUSED/FREE] Number of relocations
    dw 0                    ; [UNUSED/FREE] Number of line numbers
    dd 0                    ; [UNUSED/FREE] Section characteristics (Interesting that it lets me modify this freely?)

HEADER_SIZE equ $ - $$

; Start of code
CODE:

; Import address table
IMPORT_ADDRESS_TABLE:
                            ; Structure and content of import address table is identical to the import lookup table until the file is bound by the loader. 
                            ; The addresses here get patched to the memory addresses of the imported symbols.
    dd HINT_NAME_TABLE      ; RVA of the entry into the hint/name table for this import
    dd 0                    ; Null terminator entry

IATBL_SIZE equ $ - IMPORT_ADDRESS_TABLE

; Initialised data store
DATA:
    db "Hello, World!"      ; String to print
    db `\r\n`               ; Line breaks

; Entry point
ENTRY_POINT:
    push ebp;
    mov ebp, esp;
    push ecx;
    push ecx;
    mov eax, [ebx + 0x10];
    mov eax, [eax + 0x1C];
    mov [ebp - 4], eax;
    push 0;
    lea eax, [ebp - 8];
    push eax;
    push 0xF;
    push IMAGE_BASE + DATA;
    push [ebp - 4];
    call [IMAGE_BASE + IMPORT_ADDRESS_TABLE];
    leave;
    ret;
    
    times align($ - $$, 16) - ($ - $$) int3;

; Import directory/table
IMPORT_DIRECTORY:
                            ; Entry 1 (KERNEL32.DLL)
    dd 0                    ; [UNUSED/FREE] RVA of import lookup table for entry 1 (place to look for data)
    dd 0                    ; [UNUSED/FREE] Zeroed Time/Date stamp for use as loader patches it
    dd 0                    ; [UNUSED/FREE] Forwarder chain, whatever that means
    dd DLL_NAME_1           ; RVA of a string containing the DLL name for this import
    dd IMPORT_ADDRESS_TABLE ; RVA of import address table for entry 1 (place to write the results to)
    times 5 dd 0            ; Full null entry indicating end of table

IMPORT_DIRECTORY_SIZE equ $ - IMPORT_DIRECTORY

; Import lookup table for the first DLL
IMPORT_LOOKUP_TABLE_1:
    dd 0                    ; [UNUSED/FREE/USEDAFTERLOAD?] RVA of the hint/name table entry for this import, with MSB set to 0 to indicate import by name
    dd 0                    ; [UNUSED/FREE/USEDAFTERLOAD?] Null entry signifying terminator

; Hint/name table
HINT_NAME_TABLE:
                            ; Entry 1 (WriteFile)
    dw 0x616                ; Function ordinal (loader attempts to match this first)
    db "WriteFile", 0       ; Function name (loader only uses if match fails)

; Name of DLL 1

DLL_NAME_1:
    db "KERNEL32.dll", 0    ; Name of DLL 1 from the import directory/table

MAIN_SIZE equ $ - CODE

times align($ - $$, 16) - ($ - $$) db 0; Padding to end of section

CODE_SIZE equ $ - CODE

FILE_SIZE equ $ - $$

    

    
