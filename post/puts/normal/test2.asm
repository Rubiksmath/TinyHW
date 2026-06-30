BITS 32

IMAGE_BASE equ 0x690000
org 0

%define align(n, r) (((n+(r-1))/r)*r)

; DOS header
DOS_HEADER:
    dw "MZ"                 ; DOS Magic number
    dw 0                    ; [UNUSED/FREE] Bytes on last page

; Start of PE header
PE_HEADER:
    dw "PE"                 ; [UNUSED/FREE] Pages in File                           ; PE signature part 1 "PE"    
    dw 0                    ; [UNUSED/FREE] Relocations                             ; PE signature part 2 "\0\0"

; Mandatory COFF/Image file header
COFF_FILE_HEADER:
    dw 0x14C                ; [UNUSED/FREE] Size of header (paragraphs)             ; Machine (Intel 386)
    dw 1                    ; [UNUSED/FREE] Minimum memory (paragraphs?)            ; Number of sections (1)

; Entry point
ENTRY_POINT:
    lea eax, [ecx - ENTRY_POINT + DATA];
                            ; [UNUSED/FREE] Maximum memory (paragraphs?)            ; [UNUSED/FREE] TimeDateStamp part 1 
                            ; [UNUSED/FREE] Initial stack segment value (relative) part 1
                                                                                    ; [UNUSED/FREE] TimeDateStamp part 2        ; Calculate address of string to print from ecx holding entry point
    push eax                ; [UNUSED/FREE] Initial stack segment value (relative) part 2
                                                                                    ; [UNUSED/FREE] TimeDateStamp part 3
                                                                                                                                ; Push address of string to print
    call [ecx - ENTRY_POINT + IMPORT_ADDRESS_TABLE]          
                            ; [UNUSED/FREE] Initial stack pointer value (relative)  ; [UNUSED/FREE] PointerToSymbolTable part 1
                            ; [UNUSED/FREE] Checksum part 1                         ; [UNUSED/FREE] PointerToSymbolTable part 2                                                                                  
                            ; [UNUSED/FREE] Initial instruction pointer value       ; [UNUSED/FREE] NumberOfSymbols part 1      ; Call puts
    pop ecx                 ; [UNUSED/FREE] Initial code segment value (relative) part 1
                                                                                    ; [UNUSED/FREE] NumberOfSymbols part 2      ; Fix stack
    ret                     ; [UNUSED/FREE] Initial code segment value (relative) part 2
                                                                                    ; [UNUSED/FREE] NumberOfSymbols part 3      ; Done
    dw OPTIONAL_HEADER_SIZE ; [UNUSED/FREE] Address of DOS reloation table          ; SizeOfOptionalHeader 
    dw 0x2                  ; [UNUSED/FREE] Overlay number                          ; [RESTRICTED BUT MODIFIABLE] Characteristics (need second least significant bit set)

; Mandatory image file "optional header"
IMAGE_OPTIONAL_HEADER:
    ; Mandatory "optional header" standard fields
    dw 0x10B                ; [UNUSED/FREE] Reserved words list 1 (4) part 1        ; Magic number (indicates PE32)

    ; Initialised data store
DATA:
    db "H"                  ; [UNUSED/FREE] Reserved words list 1 (4) part 2        ; [UNUSED/FREE] MajorLinkerVersion          ; String to print, part 1
    db "e"                  ; [UNUSED/FREE] Reserved words list 1 (4) part 3        ; [UNUSED/FREE] MinorLinkerVersion          ; String to print, part 2
    db "llo,"               ; [UNUSED/FREE] Reserved words list 1 (4) part 4        ; [UNUSED/FREE] Total size of code sections ; String to print, part 3
    db " W"                 ; [UNUSED/FREE] OEM identifier                          ; [UNUSED/FREE] Total size of initialised data sections part 1      
                                                                                                                                ; String to print part 4
    db "or"                 ; [UNUSED/FREE] OEM information                         ; [UNUSED/FREE] Total size of initialised data sections part 2      
                                                                                                                                ; String to print part 5
    db "ld!"                ; [UNUSED/FREE] Reserved words list 2 (10) part 1       ; [UNUSED/FREE] Total size of uninitialised sections part 1               
                                                                                                                                ; String to print part 6
    db 0                    ; [UNUSED/FREE] Reserved words list 2 (10) part 2       ; [UNUSED/FREE] Total size of uninitialised sections part 2
                                                                                                                                ; Null terminator for puts
    dd ENTRY_POINT          ; [UNUSED/FREE] Reserved words list 2 (10) part 3       ; RVA of entry point (Note: needs to be calculated carefully with respect to what is in the section headers. Address in file = RVA - VA + pointer to raw data in section header.)

; Name of DLL 1
DLL_NAME_1:
    dd "ucrt"               ; [UNUSED/FREE] Reserved words list 2 (10) part 4       ; [UNUSED/FREE] RVA of beginning of code section when loaded        
                                                                                                                                ; Name of DLL 1 from the import directory/table, with .dll omitted because it's not needed! part 1
    dd "base"               ; [UNUSED/FREE] Reserved words list 2 (10) part 5       ; [UNUSED/FREE] RVA of beginning of data section when loaded        
                                                                                                                                ; Name of DLL 1 from the import directory/table, with .dll omitted because it's not needed! part 2
    
    ; Mandatory Windows-specific "optional header" fields
    dd IMAGE_BASE           ; [UNUSED/FREE] Reserved words list 2 (10) part 6       ; My funny preferred base of image
    dd 0x4                  ; File offset of PE header                              ; Alignment of sections when loaded into memory (0x04, dual purpose field)

    ; End of DOS header

    dd 0x4                  ; Alignment of raw data of sections

    ; Hint/name table
HINT_NAME_TABLE:
                            ; Entry 1 (puts)
    dw 0                    ; [UNUSED/FREE] Major operating system version          ; [UNUSED/FREE] Function ordinal (loader attempts to match this first)
    db "pu"                 ; [UNUSED/FREE] Minor operating system version          ; Function name (loader only uses if match fails) part 1
    db "ts"                 ; [UNUSED/FREE] Major image version                     ; Function name (loader only uses if match fails) part 2
    db 0                    ; [UNUSED/FREE] Minor image version part 1              ; End of function name (null terminator)

    db 0                    ; [UNUSED/FREE] Minor image version part 2
    dw 4                    ; [RESTRICTED BUT MODIFIABLE] Major subsystem version
    dw 0                    ; [RESTRICTED BUT MODIFIABLE] Minor subsystem version, free if major version is 4
    dd 0                    ; [UNUSED/FREE] Win32 version value
    dd 0xB4                 ; [RESTRICTED BUT MODIFIABLE] Size of image total when loaded into memory. Claimed that this must be a multiple of section alignment. 
                            ; In reality it seems that it can be whatever you want provided it's larger than perhaps size of code or something?
    dd 0                    ; [UNUSED/FREE] Size of headers total in the file, rounded up to a multiple of FileAlignment
    dd 0                    ; [UNUSED/FREE] Checksum
    dw 3                    ; Subsystem, 3 indicates Windows CUI
    dw 0                    ; [RESTRICTED BUT MODIFIABLE] DLL Characterstics (unsure on restrictions)
    dd 0                    ; [RESTRICTED BUT MODIFIABLE] Size of stack reserve (don't go too big)
    dd 0                    ; [RESTRICTED BUT MODIFIABLE] Size of stack commit (don't go too big)
    dd 0                    ; [RESTRICTED BUT MODIFIABLE] Size of heap reserve (don't go too big)
    dd 0                    ; [RESTRICTED BUT MODIFIABLE] Size of heap commit (don't go too big)
    dd 0                    ; [UNUSED/FREE] Loader flags
    dd 0x2                  ; Number of entries in the data directory table (2)

    ; Optional header data directories

    dd 0                    ; [UNUSED/FREE] Export table RVA

; Import directory/table
IMPORT_DIRECTORY:
    dd 0                    ; [UNUSED/FREE] Export table size                       ; [RESTRICTED BUT MODIFIABLE] RVA of import lookup table for entry 1 (needs to be either 0 or too big to fit in the file or equal to address of import address table or else it looks for it and errors)
    dd IMPORT_DIRECTORY     ; Import table RVA                                      ; [UNUSED/FREE] Zeroed Time/Date stamp for use as loader patches it
    dd 0                    ; [UNUSED/FREE] Import table size                       ; [UNUSED/FREE] Forwarder chain, whatever that means
                            

    ; End of PE header

OPTIONAL_HEADER_SIZE equ $ - IMAGE_OPTIONAL_HEADER

; Section table
SECTION_TABLE:
    dd DLL_NAME_1           ; [UNUSED/FREE] Name of first section, padded to 8 bytes part 1       
                                                                                    ; RVA of a string containing the DLL name for this import
    dd IMPORT_ADDRESS_TABLE ; [UNUSED/FREE] Name of first section, padded to 8 bytes part 2       
                                                                                    ; RVA of import address table for entry 1 (place to write the results to)

IMPORT_ADDRESS_TABLE:
    dd HINT_NAME_TABLE      ; [RESTRICTED BUT MODIFIABLE] Virtual size of section when loaded into memory (don't go too big or something)
                                                                                    ; Pad with null entry to signify end of table part 1 (0 not enforced)
                                                                                                                                ; RVA of the entry into the hint/name table for this import
    dd 0                    ; Virtual address of section when loaded into memory, i.e. the offset from image base when loaded
                                                                                    ; Pad with null entry to signify end of table part 2 (0 not enforced)
                                                                                                                                ; Null terminator entry (enforced 0)
    dd 129                  ; [RESTRICTED BUT MODIFIABLE] Size of the initialised data on disk for this section (can't go too small)
                            ; Looks like it just has to be at least address of import address table + 1
                                                                                    ; Pad with null entry to signify end of table part 3 (0 not enforced)

times align ($ - $$, 268) - ($ - $$) db 0;
                            ; Pad to minimum of 268 part 1                          ; File pointer to the first page of the section         
                                                                                                                                ; Pad with null entry to signify end of table part 4 (enforced 0)
                            ; Pad to minimum of 268 part 2                          ; [UNUSED/FREE] Pointer to relocations      ; Pad with null entry to signify end of table part 5 (enforced 0)
                            ; Pad to minimum of 268 part 3                          ; [UNUSED/FREE] Pointer to line numbers
                            ; Pad to minimum of 268 part 4                          ; [UNUSED/FREE] Number of relocations
                            ; Pad to minimum of 268 part 5                          ; [UNUSED/FREE] Number of line numbers
                            ; Pad to minimum of 268 part 6                          ; [UNUSED/FREE] Section characteristics
