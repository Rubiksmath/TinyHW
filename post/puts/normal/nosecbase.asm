BITS 32

IMAGE_BASE equ 0x400000
org 0

%define align(n, r) (((n+(r-1))/r)*r)

; DOS header
DOS_HEADER:
    dw "MZ"                 ; DOS Magic number
    dw 0x90                 ; Bytes on last page
    dw 0x03                 ; Pages in File
    dw 0                    ; Relocations
    dw 0x04                 ; Size of header (paragraphs)
    dw 0                    ; Minimum memory (paragraphs?)
    dw 0xFFFF               ; Maximum memory (paragraphs?)
    dw 0                    ; Initial stack segment value (relative)
    dw 0xB8                 ; Initial stack pointer value
    dw 0                    ; Checksum
    dw 0                    ; Initial instruction pointer value
    dw 0                    ; Initial code segment value (relative)
    dw 0x40                 ; Address of DOS reloation table
    dw 0                    ; Overlay number
    times 4 dw 0            ; Reserved words (4)
    dw 0                    ; OEM identifier
    dw 0                    ; OEM information
    times 10 dw 0           ; Reserved words part 2 (10)
    dd PE_HEADER            ; Address of beginning of PE header

DOS_STUB:
    db 0x0E                 ; x86_16 push cs
    db 0x1F                 ; x86_16 pop ds
    db 0xBA, 0x0E, 0x00     ; x86_16 mov dx, 0x0E
    db 0xB4, 0x09           ; x86_16 mov ah, 0x09
    db 0xCD, 0x21           ; x86_16 int 0x21 // This whole segment basically says print to screen the string at ds:dx until reaching a $. 
    db 0xB8, 0x01, 0x4C     ; x86_16 mov ax, 0x4C01
    db 0xCD, 0x21           ; x86_16 int 0x21
    db "This program "      ; DOS stub message
    db "cannot be run "     ; DOS stub message (cont.)
    db "in DOS mode."       ; DOS stub message (cont.)
    db `\r\r\n$`            ; End of DOS stub message
    times 7 db 0            ; Align to specific boundary (no idea if 8 or 16 or 32 or 64 or 128 byte boundary)

RICH_HEADER:
    dd 0xC39483D9           ; Masked signature, unmasked this reads "DanS"
    times 3 dd 0x90FAE29D   ; 3 masked DWORDs of 0 for padding
    dd 0x90699A94           ; Masked words for product ID and build ID, unmasked this says product ID = 147 (Implib1400), build ID = 30729 (Visual Studio 2008 9.00)
    dd 0x90FAE29E           ; Masked use count, unmasked this reads 3
    dd 0x90FBE29D           ; Masked words for product ID and build ID, unmasked this says product ID = 1 (Import0), build ID = 0 (Visual Studio)
    dd 0x90FAE29C           ; Masked use count, unmasked this reads 1
    dd 0x91FE9910           ; Masked words for product ID and build ID, unmasked this says product ID = 260 (Utc1900_C), build ID = 31629 (Visual Studio 2015 14.00)
    dd 0x90FAE29C           ; Masked use count, unmasked this reads 1
    dd 0x91F89910           ; Masked words for product ID and build ID, unmasked this says product ID = 258 (Linker1400), build ID = 31629 (Visual Studio 2015 14.00)
    dd 0x90FAE29C           ; Masked use count, unmasked this reads 1
    dd "Rich"               ; Rich header signature
    dd 0x90FAE29D           ; XOR key for unmasking the rich header


    times 6 dd 0                ; Spacing

; End of DOS header

; Start of PE header
PE_HEADER:
    dw "PE", 0              ; PE signature "PE\0\0"

; Mandatory COFF/Image file header
COFF_FILE_HEADER:
    dw 0x14C                ; Machine (Intel 386)
    dw 1                    ; NumberOfSections (1)
    dd 0x6A40E009           ; TimeDateStamp (Sunday, 28.06.2026 08:49:13 UTC)
    dd 0                    ; PointerToSymbolTable [0 for images]
    dd 0                    ; NumberOfSymbols [0 for images]
    dw OPTIONAL_HEADER_SIZE ; SizeOfOptionalHeader (usually 0xE0 for this type of app cause 32 bit)
    dw 0x103                ; Characteristics (0x01 -> No relocation info present; 0x02 -> executable file; 0x100 -> 32 bit machine)

; Mandatory image file "optional header"
IMAGE_OPTIONAL_HEADER:
    ; Mandatory "optional header" standard fields
    dw 0x10B                ; Magic number (indicates PE32)
    db 0xE                  ; MajorLinkerVersion (14)
    db 0x21                 ; MinorLinkerVersion (33)
    dd CODE_SIZE            ; Total size of code sections (176 bytes)
    dd 0                    ; Total size of initialised data sections (16 bytes)
    dd 0                    ; Total size of uninitialised data sections (0 bytes)
    dd ENTRY_POINT          ; RVA of entry point (Note: needs to be calculated carefully with respect to what is in the section headers. Address in file = RVA - VA + pointer to raw data in section header.)
    dd CODE                 ; RVA of beginning of code section when loaded
    dd 0                    ; RVA of beginning of data section when loaded

    ; Mandatory Windows-specific "optional header" fields

    dd IMAGE_BASE           ; My funny preferred base of image
    dd 0x4                  ; Alignment of sections when loaded into memory
    dd 0x4                  ; Alignment of raw data of sections when loaded into memory (honestly not sure on the difference)
                            ; Listed requirements for these two fields are: SectionAlignment >= FileAlignment, FileAlignment must be power of 2, and if SectionAlignment is < page size, then FileAlignment == SectionAlignment.
                            ; To be honest, if the loader patches something in to fix these fields when I go to overlap these stuff that would be funny.
    dw 6                    ; Major operating system version (indicates Windows Vista/Server 2008)
    dw 0                    ; Minor operating system version
    dw 0                    ; Major image version
    dw 0                    ; Minor image version
    dw 6                    ; Major subsystem version
    dw 0                    ; Minor subsystem version
    dd 0                    ; Reserved field for Win32 version value, though it is claimed this must be 0.
    dd FILE_SIZE            ; Size of image total when loaded into memory. Claimed that this must be a multiple of section alignment. 
                            ; In reality it seems that it can be whatever you want provided it's larger than perhaps size of code or something?
    dd HEADER_SIZE          ; Size of headers total in the file, rounded up to a multiple of FileAlignment
    dd 0                    ; Checksum, seemingly unused
    dw 3                    ; Subsystem, 3 indicates Windows CUI
    dw 0x8500               ; DLL Characterstics, (0x8000 -> TerminalServer aware, 0x400 -> Image does not use SEH, 0x100 -> Image is NX compatible)
    dd 0x100000             ; Size of stack reserve, some sort of something idk
    dd 0x1000               ; Size of stack commit
    dd 0x100000             ; Size of heap reserve
    dd 0x1000               ; Size of heap commit
    dd 0                    ; Loader flags, apparently must be 0
    dd 0x10                 ; Number of entries in the data directory table, here 16 as per default.

    ; Optional header data directories

    dd 0                    ; Export table RVA
    dd 0                    ; Export table size
                            ; .edata section apparently
    dd IMPORT_DIRECTORY     ; Import table RVA
    dd IMPORT_DIRECTORY_SIZE; Import table size
                            ; .idata section apparently
    dd 0                    ; Resource directory RVA
    dd 0                    ; Resource directory size
                            ; .rsrc section apparently
    dd 0                    ; Exception table RVA
    dd 0                    ; Exception table size
                            ; .pdata section apparently
    dd 0                    ; Certificate table RVA
    dd 0                    ; Certificate table size
                            ; Attribute Certificate Table apparently
    dd 0                    ; Relocation table RVA
    dd 0                    ; Relocation table size
                            ; .reloc section apparently
    dd 0                    ; Debug data RVA
    dd 0                    ; Debug data size
                            ; .debug section apparently
    dd 0                    ; Architecture specific data RVA
    dd 0                    ; Architecture specific data size
                            ; Reserved and apparently must be 0, though it still worked but meh whatever.
    dd 0                    ; Global pointer register value RVA
    dd 0                    ; Global pointer register value size, must be 0

    dd 0                    ; Thread local storage table RVA
    dd 0                    ; Thread local storage table size
                            ; .tls section apparently
    dd 0                    ; Load configuration table RVA
    dd 0                    ; Load configuration table size
                            ; Load configuration structure apparently
    dd 0                    ; Bound import table RVA
    dd 0                    ; Bound import table size

    dd IMPORT_ADDRESS_TABLE ; Import address table RVA
    dd IATBL_SIZE           ; Import address table size
                            ; Note that the import address table is the region that gets patched by the loader for if function calls are straight jumps or something.
    dd 0                    ; Delay import descriptor RVA
    dd 0                    ; Delay import descriptor size
                            ; Delay-Load Import Tables apparently
    dd 0                    ; CLR runtime header RVA
    dd 0                    ; CLR runtime header size
                            ; .cormeta section apparently
    dq 0                    ; Reserved, apparently

    ; End of PE header

OPTIONAL_HEADER_SIZE equ $ - IMAGE_OPTIONAL_HEADER

; Section table
SECTION_TABLE:
    db ".main", 0, 0, 0     ; Name of first section, padded to 8 bytes
    dd MAIN_SIZE            ; Virtual size of section when loaded into memory. If this is larger than the size of the raw data of the section, this gets zero padded.
    dd IMPORT_ADDRESS_TABLE ; Virtual address of section when loaded into memory, i.e. the offset from image base when loaded
    dd CODE_SIZE            ; Size of the initialised data on disk for this section. Must be a multiple of file alignment from the optional header (wut), and this parameter is rounded, while virtual size is not.
                            ; Looks like it just has to be at least virtual size idk
    dd IMPORT_ADDRESS_TABLE ; File pointer to the first page of the section
    dd 0                    ; Pointer to relocations
    dd 0                    ; Pointer to line numbers
    dw 0                    ; Number of relocations
    dw 0                    ; Number of line numbers
    dd 0x60000020           ; Section characteristics (0x20 -> contains executable code; 0x20000000 -> can be executed as code; 0x40000000 -> can be read)


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
    db "Hello, World!", 0   ; String to print

    dw 0                    ; Padding?

    ; Weird data that I don't know what it is doing
    dd 0x18                 ;
    dd 0x80028002           ;
    dd 0                    ;
    dd 0                    ;
    dd 0x20030              ;
    dd 8                    ;
    dd 0x20008              ;
    dd 0x3C                 ;

; Entry point
ENTRY_POINT:
    push IMAGE_BASE + DATA  ; Push address of string to print
    call FORWARDER          ; Dunno why, but it's doing this weird call to an address that then jumps
    pop ecx                 ; Align stack?
    ret                     ; Done

FORWARDER:

    jmp [IMAGE_BASE + IMPORT_ADDRESS_TABLE]          ; Jump to puts
    times 2 int3            ; Debugger padding

; Import directory/table
IMPORT_DIRECTORY:
                            ; Entry 1 (api-ms-win-crt-stdio-l1-1-0.dll)
    dd IMPORT_LOOKUP_TABLE_1; RVA of import lookup table for entry 1 (place to look for data)
    dd 0                    ; Zeroed Time/Date stamp for use as loader patches it
    dd 0                    ; Forwarder chain, whatever that means
    dd DLL_NAME_1           ; RVA of a string containing the DLL name for this import
    dd IMPORT_ADDRESS_TABLE ; RVA of import address table for entry 1 (place to write the results to)
    times 5 dd 0            ; Pad with null entry to signify end of table

IMPORT_DIRECTORY_SIZE equ $ - IMPORT_DIRECTORY

; Import lookup table for the first DLL
IMPORT_LOOKUP_TABLE_1:
    dd HINT_NAME_TABLE      ; RVA of the hint/name table entry for this import, with MSB set to 0 to indicate import by name
    dd 0                    ; Null terminator entry

; Hint/name table
HINT_NAME_TABLE:
                            ; Entry 1 (puts)
    dw 0x93                 ; Function ordinal (loader attempts to match this first)
    db "puts", 0, 0         ; Function name (loader only uses if match fails)

; Name of DLL 1

DLL_NAME_1:
    db "api-ms-win-crt-stdio-l1-1-0.dll", 0    ; Name of DLL 1 from the import directory/table

MAIN_SIZE equ $ - CODE

times align($ - $$, 16) - ($ - $$) db 0; Pad to 16 cause I'm nice.

CODE_SIZE equ $ - CODE

FILE_SIZE equ $ - $$

    

    
