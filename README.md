# Tiny Hello, World! EXE File
This repository is a journey that I went on to create the smallest possible EXE file that prints Hello, World! to console that runs on my Windows machine (and hopefully most other people's Windows machines as well), which is running Windows 10.
This is heavily inspired by the repository [TinyPE-on-Win10](https://github.com/ayaka14732/TinyPE-on-Win10) by ayaka14732, which was the source of many of the ideas used here,  pointed me to many helpful resources, and also helped me with organisation of my thoughts and thought process.
## Usage
To run the "smallest" file that I was able to create, open a terminal in the `step10` directory and run:
`tinyhws10`
For example:
```cmd
root\TinyHW\step10_bonus>tinyhws10
Hello, World!

```
This should hopefully output the text `Hello, World!\n`. Or it will show some error saying that this app can't run on your PC or words to that effect. If that happens, then it means that my EXE is not as portable as I would like. I was restricted to testing on my own machine for this, so I can't guarantee that it works for everyone.
## Introduction
Sometime around 2022, I wondered what the smallest possible EXE (aka Portable Executable or PE) file that would run on Windows was. I started out by looking up where execution inside an EXE file starts. The answers I found ended up being pretty complicated and my younger self could not be bothered to invest so much time into understanding it. I had thought about revisiting this numerous times, but either forgot or didn't have the time or the courage to do it, until June 2026 when I decided to really give it a crack. 
I was already aware of the repository by ayaka14732 by then, but wanted to try doing it my own way by lifting some of their restrictions on the rules they used and seeing if this could be used to get the file any smaller. As it would turn out, I completely forgot that there is a hard minimum limit of 268 bytes on 64 bit windows that had already been found and established, so this was a "waste of time" in some sense. However, my forgetfulness is probably for the better, since I don't think I would have tried this project if I had remembered the hard limit. More on that later, though.
In the repository by ayaka14732, they listed a few key restrictions:
- The EXE file must be a 64 bit EXE
- Imports must be done by name and not ordinal
- Content of message box (which is what their program did) must be 64 bytes
To me, these restrictions were needlessly bloating file size, so I wanted to see what would happen if I removed them (Remember, I did not know about the hard limit, and I won't tell you that I didn't know again, so please keep this in mind for any remarks I make in the future of this document). 
So with that, I decided that my program should:
- Be a 32 bit EXE
- Import however it wants
- Only need to output Hello, World! to the console
So with that, I got started.
## Step 1
To begin, I started with standard C code and compiler settings. This is the code I started with (I don't really know C very well, so I just winged it here):
```c
#include <stdio.h>
int main() {
    puts("Hello, World!");
    return;
}
```
The function `puts` made the most sense to use for this to me because it only needed one argument and I recall that the C standard says that `puts` simply outputs characters until encountering a null byte. This seemed like it would have the least overhead of the common options to me, so I went ahead to compile it. I happened to already have Visual Studio Build Tools 2022 installed from back when I had no idea what I was doing (and honestly, I still don't really know!), which was convenient. I opened the x86 Native Tools Command Prompt for VS2022 application that came with the build tools, and most likely ran the following (I didn't actually note it down, but this command gives output that git diff says only differs by what appears to be a timestamp):
```cmd
root/TinyHW/step1>cl /O1 tinyhws1.c
Microsoft (R) C/C++ Optimizing Compiler Version 19.33.31629 for x86
Copyright (C) Microsoft Corporation.  All rights reserved.

tinyhws1.c
Microsoft (R) Incremental Linker Version 14.33.31629.0
Copyright (C) Microsoft Corporation.  All rights reserved.

/out:tinyhws1.exe
tinyhws1.obj
```

Then I used `certutil` from powershell to create a hexdump:
```powershell
PS root/TinyHW\step1> certutil -encodehex tinyhws1.exe tinyhws1.exe.hex
Input Length = 79360
Output Length = 367904
CertUtil: -encodehex command completed successfully.
```
This isn't exactly a great start, but I know that compilers put all sorts of fluff into EXE files which is especially noticeable when the source code is tiny. Of course, I had to test that it worked first before moving on:
```cmd
\TinyHW\step1>tinyhws1
Hello, World!

```
Note that in all these snippets, I have replaced the actual parent directory with `root` because I don't want to spill any sensitive information. That said, I wouldn't be surprised if the compiler put the full file path in the resulting EXE because of how incredibly large the EXE is. 79KB is kind of wild for such a tiny source!
## Step 2
From here to step 5 was pretty haphazard and I don't remember too much, nor did I commit often enough to save what happened, but I'll do my best to reconstruct what happened. I will further divide this step into "attempts" to better characterise what might have happened. However, some of the "attempts" that I list here almost certainly did not happen, instead these are paths that are interesting to discuss in hindsight and would have been performed if I wasn't so lazy.
### Step 2, Attempt 1
The first changes were made to the source code itself. I recalled from some kind of code golf post somewhere (but I cannot recall where) that you usually don't actually have to put imports for standard libraries, since compilers include it for you by default. This post also described that there is no need to return, nor is there a need to assign the `main` function a return type, although it still has to be called `main` or else the compiler will fail (at least in their competition environment). I thought that making these changes to the source code was worth a shot, since maybe it might cut out some fluff from whatever the compiler adds to the file. This was the resulting source file:
```c
main(){puts("Hello, World!");}
```
Here's what would have happened if I ran the same compile command as before:
```cmd
root/TinyHW/step2>cl /O1 tinyhws2attempt1.c
Microsoft (R) C/C++ Optimizing Compiler Version 19.33.31629 for x86
Copyright (C) Microsoft Corporation.  All rights reserved.

tinyhws2attempt1.c
Microsoft (R) Incremental Linker Version 14.33.31629.0
Copyright (C) Microsoft Corporation.  All rights reserved.

/out:tinyhws2attempt1.exe
tinyhws2attempt1.obj
```
Let's check the size and make a hexdump with `certutil` again:
```powershell
PS root\TinyHW\step2> certutil -encodehex tinyhws2attempt1.exe tinyhws2attempt1.exe.hex
Input Length = 79360
Output Length = 367904
CertUtil: -encodehex command completed successfully.
```
Exactly the same size. Let's check the git diff:
```diff
$ git diff HEAD:step1/tinyhws1.exe.hex HEAD:step2/tinyhws2attempt1.exe.hex
diff --git a/step1/tinyhws1.exe.hex b/step2/tinyhws2attempt1.exe.hex
index 9dfbc73..a169a15 100644
--- a/step1/tinyhws1.exe.hex
+++ b/step2/tinyhws2attempt1.exe.hex
@@ -14,7 +14,7 @@
 00d0   e2 32 dd 9d 6e 49 d9 9c  e2 32 db 9d 6e 49 d9 9c   .2..nI...2..nI..
 00e0   52 69 63 68 6f 49 d9 9c  00 00 00 00 00 00 00 00   RichoI..........
 00f0   00 00 00 00 00 00 00 00  50 45 00 00 4c 01 04 00   ........PE..L...
-0100   cc 32 36 6a 00 00 00 00  00 00 00 00 e0 00 02 01   .26j............
+0100   a2 74 3f 6a 00 00 00 00  00 00 00 00 e0 00 02 01   .t?j............
 0110   0b 01 0e 21 00 bc 00 00  00 80 00 00 00 00 00 00   ...!............
 0120   55 12 00 00 00 10 00 00  00 d0 00 00 00 00 40 00   U.............@.
 0130   00 10 00 00 00 02 00 00  06 00 00 00 00 00 00 00   ................
@@ -4301,7 +4301,7 @@ fff0      00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00   ................
 10cc0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00   ................
 10cd0  48 1d 41 00 00 00 00 00  00 00 00 00 00 00 00 00   H.A.............
 10ce0  00 00 00 00 00 00 00 00  10 d1 40 00 00 00 00 00   ..........@.....
-10cf0  00 00 00 00 cc 32 36 6a  00 00 00 00 0d 00 00 00   .....26j........
+10cf0  00 00 00 00 a2 74 3f 6a  00 00 00 00 0d 00 00 00   .....t?j........
 10d00  80 02 00 00 d0 1d 01 00  d0 0d 01 00 00 00 00 00   ................
 10d10  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00   ................
 10d20  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00   ................
```
So we can see that the files are effectively the same, with the only difference being what is likely a timestamp. It's hard to say if that is expected or not, since the compiler is compiling effectively the same thing, but I've seen plenty of examples where tiny changes to a file that seem totally equivalent produce drastically different results. So in the end this is pretty interesting, but not what I would have wanted.
### Step 2, Attempt 2
This is probably closer to what actually happened. I used the same source code as in Attempt 1, however I "borrowed" most of the compilation command from ayaka14732's documentation and hoped it would work. This is pretty bad practice, but I just had to give it a try because if it worked, then that would be awesome, and I would be able to move on to the next step. I could see that their compilation command had lots of settings applied that seemed to ask for removal of components, for example `/NOLOGO`, `/NODEFAULTLIB`, and the various `/MERGE` commands. I realised that the last argument in their command, `user32.lib`, was telling the linker what library to link against, because this library contained the export for the function MessageBoxW, which they used in their code. So I searched which .lib file the `puts` function was exported from, and I got ucrt.lib back as one of the results. So, here goes nothing:
```cmd
root\TinyHW\step2>cl /O1 /MD /GS- tinyhws2attempt2.c /link /NOLOGO /NODEFAULTLIB /SUBSYSTEM:WINDOWS /ENTRY:_ /MERGE:.rdata=. /MERGE:.pdata=. /MERGE:.text=. /SECTION:.,ER /ALIGN:16 ucrt.lib
Microsoft (R) C/C++ Optimizing Compiler Version 19.33.31629 for x86
Copyright (C) Microsoft Corporation.  All rights reserved.

tinyhws2attempt2.c
LINK : warning LNK4108: /ALIGN specified without /DRIVER; image may not run
LINK : error LNK2001: unresolved external symbol __
tinyhws2attempt2.exe : fatal error LNK1120: 1 unresolved externals
```
Oh, well that didn't quite work. It seems that there was an error with an unresolved external symbol. Some messing around later, I was continuing to get errors so I backed off the settings to try and just put an improvement on the board with what I had learned at the time, which was probably just that /MD should save me loads of space because it links the Universal C Runtime dynamically instead of the default static linking. Or, something like that happened anyway. I'm not actually sure what happened, but I know that I ended up talking to AI about it which in hindsight was a big mistake since it led me to some assumptions that appear to be wrong when looking back at it. In either case, I'm able to recreate the resulting filesize with the following (though the contents are vastly different):
```cmd
root\TinyHW\step2>cl /O1 /MD tinyhws2attempt2.c
Microsoft (R) C/C++ Optimizing Compiler Version 19.33.31629 for x86
Copyright (C) Microsoft Corporation.  All rights reserved.

tinyhws2attempt2.c
Microsoft (R) Incremental Linker Version 14.33.31629.0
Copyright (C) Microsoft Corporation.  All rights reserved.

/out:tinyhws2attempt2.exe
tinyhws2attempt2.obj
```
Checking the size with a hexdump:
```powershell
PS root\TinyHW\step2> certutil -encodehex tinyhws2attempt2.exe tinyhws2attempt2.exe.hex
Input Length = 8704
Output Length = 40256
CertUtil: -encodehex command completed successfully.
```
This is a good improvement! Purely by linking the CRT dynamically, I have saved over 70,000 bytes.
## Step 3
However, I still really wanted to get the optimised compiler command to work, since ayaka14732 was able to use it to get their size down to 896 bytes almost immediately. To achieve this, I should have gained an (albeit minimal) understanding of the techniques and the compiler options by referring at minimum to this [blog post](https://learn.microsoft.com/en-us/archive/blogs/xiangfan/minimize-the-size-of-your-program-high-level) and the [linker options](https://learn.microsoft.com/en-us/cpp/build/reference/linker-options?view=msvc-170&viewFallbackFrom=vs-2019) linked by ayaka14732. Instead, I continued to be lazy and asked AI about it. For your benefit, I have gone and read these like I should have the first time, and here is the important details from both resources summarised:
- Most of the code in a small PE compiled with default settings is not yours. It is mostly what is known as the CRT (C runtime) startup code, which is statically linked by default. Using the flag `/MD` dynamically links this instead and can save tens of KB.
- The flag `/ENTRY:_` used in ayaka14732's linking command was telling it to enter at the function _ in their code, which I didn't have. So no wonder that failed. 
- The flag `/GS-` disables buffer overrun detection.
- The `/MERGE` flags are telling the linker to combine certain sections together in the PE file which can save space. Here, they are telling the linker to merge all the sections into a single section called `.`.
- The `/ALIGN` flag tells the linker to align sections to a desired width.
This still didn't cover everything, so I consulted the other [resource](https://learn.microsoft.com/en-us/cpp/build/reference/linker-options?view=msvc-170&viewFallbackFrom=vs-2019) that they linked. 
- The `/NOLOGO` flag just stops it printing copyright information, but it seems that only the linker listens to this, as if you apply this flag to the compiler it tells you that /NOLOGO is an unknown option.
- The `/NODEFAULTLIB` flag ignores default imports.
- The `/SUBSYSTEM` flag specifies the subsystem which the file is intended to be run on, which for me is actually `CONSOLE` and not `WINDOWS` because `WINDOWS` means GUI, which I definitely don't want.
- The `/SECTION` flag overrides the attributes of a section, in this case to `ER`, which means executable and readable. 
The AI was able to tell me some of these things, which was nice, but it also seemed really concerned with the /NODEFAULTLIB option in conjunction with my use of `puts`. It told me that by skipping the CRT startup by omitting the default library, I would make the puts function unusable. And this lined up with some sort of error that I was experiencing. Again, I don't remember the details too well, but the end result is that it convinced me to switch to using the lower level API WriteFile from kernel32.dll which puts eventually calls into. This has the disadvantage of requiring 5 arguments:
- The handle of the file or stream to write to
- A pointer to the buffer to write from
- The number of bytes to write
- A pointer to a location to output the status of the write as it goes
- A pointer to an overlap status (whatever that means)
To get the handle, I would have to use the function GetStdHandle, which is also in kernel32.dll. At least the pointer to the overlap status could just be NULL, according to the AI anyway. This resulted in a significantly more complicated source file (where the function name was corrected to be `_` to prevent the error):
```c
#include <windows.h>
_(){
    DWORD written;
    WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), "Hello, World!\r\n", 0x0F, &written, NULL);
}
```
This was compiled with more aggressive options this time:
```cmd
root\TinyHW\step3>cl /O1 /MD /GS- tinyhws3.c /link /NOLOGO /NODEFAULTLIB /SUBSYSTEM:CONSOLE /ENTRY:_ /MERGE:.rdata=. /MERGE:.pdata=. /MERGE:.text=. /SECTION:.,ER /ALIGN:16 kernel32.lib
Microsoft (R) C/C++ Optimizing Compiler Version 19.33.31629 for x86
Copyright (C) Microsoft Corporation.  All rights reserved.

tinyhws3.c
LINK : warning LNK4108: /ALIGN specified without /DRIVER; image may not run
LINK : warning LNK4254: section '.text' (60000020) merged into '.' (40000040) with different attributes

```
Let's test it:
```cmd
root\TinyHW\step3>tinyhws3
Hello, World!

```
And let's check the size:
```powershell
certutil -encodehex tinyhws3.exe tinyhws3.exe.hex        
Input Length = 944
Output Length = 4366
CertUtil: -encodehex command completed successfully.
```
Much better. Now only 944 bytes. 
## Step 4
Around this time, I had started looking at the official [documentation](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format) of the PE format in anticipation of needing to understand all the fields and modify them by hand. I had actually known about and read this document many times before during the times when I was putting this project off, so I had some idea of what was happening, but definitely needed to study this much more deeply. I also downloaded the applications [PE Tools](https://petoolse.github.io/petools/) and [PE Bear](https://github.com/hasherezade/pe-bear) to help parse the data fields for me and enable me to modify fields and see their effect. One of the first things I noticed was that there is a bunch of weird strings that I couldn't classify as part of any section or header starting at offset 0x26C in tinyhws3. I don't know how, but I found that passing the linker option /NOCOFFGRPINFO should remove it.
This would be a decent improvement, but I wanted to deal with the need to import GetStdHandle, because I knew it was taking up space in the import tables. So I downloaded [x64dbg which comes with x32dbg](https://x64dbg.com/) to try and latch onto the process so that I can see how the handle is obtained. I found a few instructions that seemed to be important by stepping through the implementation of GetStdHandle:
```asm
mov eax,dword ptr fs:[30]
mov eax,dword ptr ds:[eax+10]
mov esi,dword ptr ds:[eax+1C]
```
So essentially it seems that fs:[30] is a pointer to the Process Environment Block (PEB), which contains information about the process and what is currently loaded. At offset 0x10 lies a pointer to a table where the StdHandle is contained at offset 0x1C. This might of course be dependent on which version of Windows is running, but I figured I had to make sacrifices and gambles like that to progress. With these two improvements, I compiled and linked the updated source file:
```c
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
```
For easier identification in hexdumps, I decided to rename the section from `.` to `.main`. Combined with the /NOCOFFGRPINFO, the updated compile command was run:
```cmd
root\TinyHW\step4>cl /O1 /MD /GS- tinyhws4.c /link /NOLOGO /NODEFAULTLIB /NOCOFFGRPINFO /SUBSYSTEM:CONSOLE /ENTRY:_ /MERGE:.rdata=.main /MERGE:.pdata=.main /MERGE:.text=.main /SECTION:.main,ER /ALIGN:16 kernel32.lib
Microsoft (R) C/C++ Optimizing Compiler Version 19.33.31629 for x86
Copyright (C) Microsoft Corporation.  All rights reserved.

tinyhws4.c
LINK : warning LNK4108: /ALIGN specified without /DRIVER; image may not run
LINK : warning LNK4254: section '.text' (60000020) merged into '.main' (40000040) with different attributes

```
Checking the size:
```powershell
root\TinyHW\step4> certutil -encodehex tinyhws4.exe tinyhws4.exe.hex        
Input Length = 704
Output Length = 3256
CertUtil: -encodehex command completed successfully.
```
A good improvement! Down to only 704 bytes and I was still using compiler options rather than needing to manually write the PE file. Let's not get ahead of ourselves and ensure that it still works:
```cmd
root\TinyHW\step4>tinyhws4
Hello, World!

```
## Step 5
At this point, I knew that the best thing for me to do would be to reconstruct the entire PE from Step 4 using assembly language so that I could perform edits manually far easier than if I just used a hex editor. This is because an assembler can calculate expressions and offsets for me, which significantly reduces the required workload of manually crafting the file and eliminates the possibility of making a mistake in the offset calculation. Using the official documentation as reference, I reconstructed every part of the file. This included:
- The DOS header
- The DOS stub
- The Rich Header
- The PE Header
    - The COFF header
    - The optional header
    - The data directories
- The section table
- The data store
- Weird data that didn't seem to fit anything 
- The code
- The import tables
- The relocations section
Interpretation of these fields was done in large part with PE Tools and PE Bear, which made it a lot faster than reading manually. The following assembly code was written in order to reconstruct the file emitted by MSVC in step 4:
```asm
BITS 32

IMAGE_BASE equ 0x690000
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
    dd 0xC7041BB1           ; Masked signature, unmasked this reads "DanS"
    times 3 dd 0x946A7AF5   ; 3 masked DWORDs of 0 for padding
    dd 0x956B11E1           ; Masked words for product ID and build ID, unmasked this says product ID = 257 (Implib1400), build ID = 27412 (Visual Studio 2015 14.00)
    dd 0x946A7AF6           ; Masked use count, unmasked this reads 3
    dd 0x946B7AF5           ; Masked words for product ID and build ID, unmasked this says product ID = 1 (Import0), build ID = 0 (Visual Studio)
    dd 0x946A7AF4           ; Masked use count, unmasked this reads 1
    dd 0x956E0178           ; Masked words for product ID and build ID, unmasked this says product ID = 260 (Utc1900_C), build ID = 31629 (Visual Studio 2015 14.00)
    dd 0x946A7AF4           ; Masked use count, unmasked this reads 1
    dd 0x95680178           ; Masked words for product ID and build ID, unmasked this says product ID = 258 (Linker1400), build ID = 31629 (Visual Studio 2015 14.00)
    dd 0x946A7AF4           ; Masked use count, unmasked this reads 1
    dd "Rich"               ; Rich header signature
    dd 0x946A7AF5           ; XOR key for unmasking the rich header

; End of DOS header

; Start of PE header
PE_HEADER:
    dw "PE", 0              ; PE signature "PE\0\0"

; Mandatory COFF/Image file header
COFF_FILE_HEADER:
    dw 0x14C                ; Machine (Intel 386)
    dw 2                    ; NumberOfSections (2)
    dd 0x6A37B388           ; TimeDateStamp (Sunday, 21.06.2026 09:48:56 UTC)
    dd 0                    ; PointerToSymbolTable [0 for images]
    dd 0                    ; NumberOfSymbols [0 for images]
    dw OPTIONAL_HEADER_SIZE ; SizeOfOptionalHeader (usually 0xE0 for this type of app cause 32 bit)
    dw 0x102                ; Characteristics (0x02 -> executable file; 0x100 -> 32 bit machine)

; Mandatory image file "optional header"
IMAGE_OPTIONAL_HEADER:
    ; Mandatory "optional header" standard fields
    dw 0x10B                ; Magic number (indicates PE32)
    db 0xE                  ; MajorLinkerVersion (14)
    db 0x21                 ; MinorLinkerVersion (33)
    dd CODE_SIZE            ; Total size of code sections (176 bytes)
    dd INTDATA_SIZE         ; Total size of initialised data sections (16 bytes)
    dd 0                    ; Total size of uninitialised data sections (0 bytes)
    dd ENTRY_POINT          ; RVA of entry point (Note: needs to be calculated carefully with respect to what is in the section headers. Address in file = RVA - VA + pointer to raw data in section header.)
    dd IMPORT_ADDRESS_TABLE ; RVA of beginning of code section when loaded
    dd INTDATA              ; RVA of beginning of data section when loaded

    ; Mandatory Windows-specific "optional header" fields

    dd IMAGE_BASE           ; My funny preferred base of image
    dd 0x10                 ; Alignment of sections when loaded into memory
    dd 0x10                 ; Alignment of raw data of sections when loaded into memory (honestly not sure on the difference)
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
    dw 0x8540               ; DLL Characterstics, (0x8000 -> TerminalServer aware, 0x400 -> Image does not use SEH, 0x100 -> Image is NX compatible, 0x40 -> DLL can move)
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
    dd RELOC_TABLE          ; Relocation table RVA
    dd RELOC_BLOCK_SIZE     ; Relocation table size
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
    dd 0x60000020           ; Section characteristics (0x20 -> contains executable code, 0x20000000 -> can be executed as code, 0x40000000 -> can be read)

    db ".reloc", 0, 0       ; Name of second section, padded to 8 bytes
    dd RELOC_BLOCK_SIZE     ; Virtual size of section when loaded into memory
    dd RELOC_TABLE          ; Virtual address of section
    dd INTDATA_SIZE         ; Size of initialised data on disk for this section
    dd RELOC_TABLE          ; File pointer to the first page of the section
    dd 0                    ; Pointer to relocations
    dd 0                    ; Pointer to line numbers
    dw 0                    ; Number of relocations
    dw 0                    ; Number of line numbers
    dd 0x42000040           ; Section characteristics (0x40 -> contains initialised data, 0x02000000 -> can be discarded as needed, 0x40000000 -> can be read)

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
    db `\r\n`, 0            ; Line breaks and null terminator of string to print

    ; Weird data that I don't know what it is doing
    dd 0x18                 ;
    dd 0x80028002           ;
    dd 0                    ;
    dd 0                    ;
    dd 0x230                ;
    dd 8                    ;
    dd 0x208                ;
    dd 0x58                 ;

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
    dd IMPORT_LOOKUP_TABLE_1; RVA of import lookup table for entry 1 (place to look for data)
    dd 0                    ; Zeroed Time/Date stamp for use as loader patches it
    dd 0                    ; Forwarder chain, whatever that means
    dd DLL_NAME_1           ; RVA of a string containing the DLL name for this import
    dd IMPORT_ADDRESS_TABLE ; RVA of import address table for entry 1 (place to write the results to)
    times 5 dd 0            ; No idea, some sort of padding?

IMPORT_DIRECTORY_SIZE equ $ - IMPORT_DIRECTORY

; Import lookup table for the first DLL
IMPORT_LOOKUP_TABLE_1:
    dd HINT_NAME_TABLE      ; RVA of the hint/name table entry for this import, with MSB set to 0 to indicate import by name
    dd 0                    ; Null terminator entry

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

; .reloc section, which is the initialised data, I think.
INTDATA:

; Relocation table
RELOC_TABLE:
    dd 0                    ; Page RVA
    dd RELOC_BLOCK_SIZE     ; Block Size

    dw 0x324F               ; Block 1, indicates type of 32 bit field and relocation RVA of 0x24F
    dw 0x3258               ; Block 2, indicates type of 32 bit field and relocation RVA of 0x258

RELOC_BLOCK_SIZE equ $ - RELOC_TABLE

times align ($ - $$, 16) - ($ - $$) db 0

INTDATA_SIZE equ $ - INTDATA

FILE_SIZE equ $ - $$
```
I also ran many tests and inspected compiled versions of the program by ayaka14732 in both x64 and x86 mode under various compiler settings, as well as modified versions of the settings from step 4. 
The assembly file was assembled using `nasm`:
```powershell
PS root\TinyHW\step5\tests>nasm -f bin -o tinyhws5test.exe -l tinyhws5test.lst tinyhws5test.asm
```
This was identical to the file generated by the MSVC compiler save for only a few differences:
```diff
$ git diff HEAD:step4/tinyhws4.exe.hex step5/tests/tinyhws5test.exe.hex
diff --git a/step4/tinyhws4.exe.hex b/step5/tests/tinyhws5test.exe.hex
index 315deac..52dfbc0 100644
--- a/step4/tinyhws4.exe.hex
+++ b/step5/tests/tinyhws5test.exe.hex
@@ -12,7 +12,7 @@
 00b0   52 69 63 68 f5 7a 6a 94  50 45 00 00 4c 01 02 00   Rich.zj.PE..L...
 00c0   88 b3 37 6a 00 00 00 00  00 00 00 00 e0 00 02 01   ..7j............
 00d0   0b 01 0e 21 b0 00 00 00  10 00 00 00 00 00 00 00   ...!............
-00e0   38 02 00 00 00 02 00 00  b0 02 00 00 00 00 40 00   8.............@.
+00e0   38 02 00 00 00 02 00 00  b0 02 00 00 00 00 69 00   8.............i.
 00f0   10 00 00 00 10 00 00 00  06 00 00 00 00 00 00 00   ................
 0100   06 00 00 00 00 00 00 00  c0 02 00 00 00 02 00 00   ................
 0110   00 00 00 00 03 00 40 85  00 00 10 00 00 10 00 00   ......@.........
@@ -25,7 +25,7 @@
 0180   00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00   ................
 0190   00 02 00 00 08 00 00 00  00 00 00 00 00 00 00 00   ................
 01a0   00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00   ................
-01b0   2e 6d 61 69 6e 00 00 00  aa 00 00 00 00 02 00 00   .main...........
+01b0   2e 6d 61 69 6e 00 00 00  a9 00 00 00 00 02 00 00   .main...........
 01c0   b0 00 00 00 00 02 00 00  00 00 00 00 00 00 00 00   ................
 01d0   00 00 00 00 20 00 00 60  2e 72 65 6c 6f 63 00 00   .... ..`.reloc..
 01e0   0c 00 00 00 b0 02 00 00  10 00 00 00 b0 02 00 00   ................
@@ -33,9 +33,9 @@
 0200   90 02 00 00 00 00 00 00  48 65 6c 6c 6f 2c 20 57   ........Hello, W
 0210   6f 72 6c 64 21 0d 0a 00  18 00 00 00 02 80 02 80   orld!...........
 0220   00 00 00 00 00 00 00 00  30 02 00 00 08 00 00 00   ........0.......
-0230   08 02 00 00 58 00 00 00  55 8b ec 51 51 8b 43 10   ....X...U..QQ.C.
+0230   08 02 00 00 58 00 00 00  55 89 e5 51 51 8b 43 10   ....X...U..QQ.C.
 0240   8b 40 1c 89 45 fc 6a 00  8d 45 f8 50 6a 0f 68 08   .@..E.j..E.Pj.h.
-0250   02 40 00 ff 75 fc ff 15  00 02 40 00 c9 c3 cc cc   .@..u.....@.....
+0250   02 69 00 ff 75 fc ff 15  00 02 69 00 c9 c3 cc cc   .i..u.....i.....
 0260   88 02 00 00 00 00 00 00  00 00 00 00 9c 02 00 00   ................
 0270   00 02 00 00 00 00 00 00  00 00 00 00 00 00 00 00   ................
 0280   00 00 00 00 00 00 00 00  90 02 00 00 00 00 00 00   ................
 ```
 The first difference is simply that I changed the image base field to 0x690000, which causes the address in the code to change and explains the last difference. The second difference seems to be that the VirtualSize field was calculated by the MSVC compiler slightly differently to how I did it in my .asm file. Lastly, the third difference is simply a different instruction encoding of the instruction mov ebp, esp, and has no impact on the behaviour of the PE file.
 While doing this, I of course noticed that the relocation section was present, which was unneeded. I found that the linker option /FIXED could remove the ability for the file to be relocated and this will remove both the relocations section itself, as well as the relocations section entry in the section table. I decided to make step 5 be this final save with compiler flags, as I couldn't find any way to remove any of the other unneeded sections with compiler options. Using the same source as in step 4, I updated the compiler flags to save this last bit of space:
 ```cmd
 root\TinyHW\step5>cl /O1 /MD /GS- tinyhws5.c /link /NOLOGO /NODEFAULTLIB /NOCOFFGRPINFO /FIXED /SUBSYSTEM:CONSOLE /ENTRY:_ /MERGE:.rdata=.main /MERGE:.pdata=.main /MERGE:.text=.main /SECTION:.main,ER /ALIGN:16 kernel32.lib
Microsoft (R) C/C++ Optimizing Compiler Version 19.33.31629 for x86
Copyright (C) Microsoft Corporation.  All rights reserved.

tinyhws5.c
LINK : warning LNK4108: /ALIGN specified without /DRIVER; image may not run
LINK : warning LNK4254: section '.text' (60000020) merged into '.main' (40000040) with different attributes

```
Let's see how much space this has saved:
```powershell
PS root\TinyHW\step5> certutil -encodehex tinyhws5.exe tinyhws5.exe.hex
Input Length = 656
Output Length = 3034
CertUtil: -encodehex command completed successfully.
```
This is as far as I could take it with compiler options alone. In the post linked previously that ayaka17432 also referred to, they were able to get a stub down to only 486 bytes, but this was in 2008. I can only guess that in 2008, the compiler could remove the rich header and also some of the weird data that didn't seem to fall into any specific section, though that doesn't seem to be enough to get down to 486.
Fair warning about this file though: For whatever reason, it sends Windows Defender absolutely nuts. It quarantines it repeatedly every time you so much as look at it, and then eventually it deletes it as it claims it has detected a virus, however all it does is specify a generic trojan label and that it was detected by machine learning. So it's just a nuisance, really.
I can't even test that this file works, because Windows Defender decided that this file is too dangerous:
```cmd
root\TinyHW\step5>tinyhws5
The system cannot execute the specified program.

```
That's the message it gives when the file has been quarantined, which causes many of the API calls regarding this file to get intercepted and rejected. I also find it quite funny that every time I bring the file back, it gets quarantined but under a different codename, and every time it's a machine learning detection. I think the AI is just out to get this file for some reason, like it has a personal vengeance on it and will do everything it can to kill it even though it is completely harmless.
## Step 6
This is the first step where the file is going to be manually built and assembled (it would have been step 5 had I not found data that could be removed by compiler flags). The test assembly from step 5 was copied but the data related to the relocations section was removed:
```asm
BITS 32

IMAGE_BASE equ 0x690000
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
    dd 0xC7041BB1           ; Masked signature, unmasked this reads "DanS"
    times 3 dd 0x946A7AF5   ; 3 masked DWORDs of 0 for padding
    dd 0x956B11E1           ; Masked words for product ID and build ID, unmasked this says product ID = 257 (Implib1400), build ID = 27412 (Visual Studio 2015 14.00)
    dd 0x946A7AF6           ; Masked use count, unmasked this reads 3
    dd 0x946B7AF5           ; Masked words for product ID and build ID, unmasked this says product ID = 1 (Import0), build ID = 0 (Visual Studio)
    dd 0x946A7AF4           ; Masked use count, unmasked this reads 1
    dd 0x956E0178           ; Masked words for product ID and build ID, unmasked this says product ID = 260 (Utc1900_C), build ID = 31629 (Visual Studio 2015 14.00)
    dd 0x946A7AF4           ; Masked use count, unmasked this reads 1
    dd 0x95680178           ; Masked words for product ID and build ID, unmasked this says product ID = 258 (Linker1400), build ID = 31629 (Visual Studio 2015 14.00)
    dd 0x946A7AF4           ; Masked use count, unmasked this reads 1
    dd "Rich"               ; Rich header signature
    dd 0x946A7AF5           ; XOR key for unmasking the rich header

; End of DOS header

; Start of PE header
PE_HEADER:
    dw "PE", 0              ; PE signature "PE\0\0"

; Mandatory COFF/Image file header
COFF_FILE_HEADER:
    dw 0x14C                ; Machine (Intel 386)
    dw 1                    ; NumberOfSections (1)
    dd 0x6A3A1004           ; TimeDateStamp (Tuesday, 23.06.2026 04:48:04 UTC)
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
    dd IMPORT_ADDRESS_TABLE ; RVA of beginning of code section when loaded
    dd 0                    ; RVA of beginning of data section when loaded

    ; Mandatory Windows-specific "optional header" fields

    dd IMAGE_BASE           ; My funny preferred base of image
    dd 0x10                 ; Alignment of sections when loaded into memory
    dd 0x10                 ; Alignment of raw data of sections when loaded into memory (honestly not sure on the difference)
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
    db "Hello, World!"      ; String to print
    db `\r\n`, 0            ; Line breaks and null terminator of string to print

    ; Weird data that I don't know what it is doing
    dd 0x18                 ;
    dd 0x80028002           ;
    dd 0                    ;
    dd 0                    ;
    dd 0x230                ;
    dd 8                    ;
    dd 0x208                ;
    dd 0x58                 ;

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
    dd IMPORT_LOOKUP_TABLE_1; RVA of import lookup table for entry 1 (place to look for data)
    dd 0                    ; Zeroed Time/Date stamp for use as loader patches it
    dd 0                    ; Forwarder chain, whatever that means
    dd DLL_NAME_1           ; RVA of a string containing the DLL name for this import
    dd IMPORT_ADDRESS_TABLE ; RVA of import address table for entry 1 (place to write the results to)
    times 5 dd 0            ; No idea, some sort of padding?

IMPORT_DIRECTORY_SIZE equ $ - IMPORT_DIRECTORY

; Import lookup table for the first DLL
IMPORT_LOOKUP_TABLE_1:
    dd HINT_NAME_TABLE      ; RVA of the hint/name table entry for this import, with MSB set to 0 to indicate import by name
    dd 0                    ; Null terminator entry

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
```
This was then assembled:
```powershell
PS root\TinyHW\step6> nasm -f bin -o tinyhws6.exe -l tinyhws6.lst tinyhws6.asm
```
Even though this is almost byte for byte identical to the previous one, Windows Defender is completely fine with it. Let's verify the size:
```powershell
PS root\TinyHW\step6> certutil -encodehex tinyhws6.exe tinyhws6.exe.hex        
Input Length = 656
Output Length = 3034
CertUtil: -encodehex command completed successfully.
```
Same as before, which is a good sign. Let's test that it works:
```cmd
root\TinyHW\step6>tinyhws6
Hello, World!

```
Now we can really start to bring the size down.
## Step 7
There are a lot of unneeded sections present in the file emitted by MSVC. 
First is the DOS stub. This part of the file is only used if you try to execute the program on DOS or similar systems. Obviously, we aren't going to be doing that, so we can safely remove these 64 bytes.
Second is the Rich Header. This is not described in the official documentation and is only present in some PE files that are compiled by MSVC tools, as far as I know anyway. This can also be safely removed, saving 56 bytes.
Third is the many useless entries in the optional header data directories. Most of these are unused, and there's even a field that tells the loader how many entries are in this table. By changing this from the default 16 down to 2, we can remove 14 unneeded entries which saves a further 112 bytes. 
Finally, the section that I can't figure out the purpose of can also be removed. This saves another 32 bytes. 
In total, the savings from cutting out these sections add up to 264 bytes. 
In addition to cutting out unneeded sections, I also tested every single field to see which fields of the headers could be zeroed out or set to whatever value that I want. This turned out to be much more than I expected. The annotations in the assembly file indicate which fields could be set to anything and which fields had restrictions on what they were allowed to be set to. Here are some particularly interesting examples of fields that could be set to whatever I want and still run fine:
- The entire DOS header apart from e_magic ("MZ") and e_lfanew (pointer to PE header)
- Most of the PE header, including data to do with linker and operating system version, and even some size fields
- Much of the section table
- The entire import lookup table, which was very surprising because it was of crucial importance in ayaka14732's code
- Most fields, actually. 
The full breakdown about what could be freely set and other restrictions are contained in the assembly file as comments:
```asm
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
```
The annotation [UNUSED/FREE] means that this field can be set to literally anything and the loader doesn't care (at least in this situation as far as I was able to test). Other annotations should be understandable as a breakdown beside each is given in the comments. The file was then assembled:
```powershell
PS root\TinyHW\step7> nasm -f bin -o tinyhws7.exe -l tinyhws7.lst tinyhws7.asm
```
Let's check the size now with these savings:
```powershell
PS root \TinyHW\step7> certutil -encodehex tinyhws7.exe tinyhws7.exe.hex
Input Length = 384
Output Length = 1776
CertUtil: -encodehex command completed successfully.
```
That's a total saving of 272 bytes compared to step 6. I believe the extra 8 byte saving comes from needing less padding in a couple places, but honestly I don't really care that much. Let's ensure it still works:
```cmd
root\TinyHW\step7>tinyhws7
Hello, World!

```
## Step 8
Up until now, I had been just copying the machine code emitted by the MSVC compiler. However, this code is pretty inefficient and does a bunch of stuff that is not really needed if we know what we are doing (and I hopefully know enough about what I'm doing in this specific example by this point). Here's a breakdown of the machine code that the MSVC compiler emitted (refer back to step 4 for the most recent source that this was generated from):
```asm
push ebp;                                       ; Function prologue part 1, save base pointer from previous stack frame
mov ebp, esp;                                   ; Function prologue part 2, set base pointer for this new stack frame equal to the current stack pointer
push ecx;                                       ; Make space for temporary local variables
push ecx;                                       ; Continue to make space
mov eax, [ebx + 0x10];                          ; Get the address of table containing the handle
mov eax, [eax + 0x1C];                          ; Put the handle into eax
mov [ebp - 4], eax;                             ; Write the handle to a temporary slot in the stack to save for later
push 0;                                         ; 5th argument to WriteFile, not needed here so can be null
lea eax, [ebp - 8];                             ; Calculate 4th argument to WriteFile, pointer for WriteFile to record the number of bytes written. This falls in the temporary space created earlier by pushing ecx twice.
push eax;                                       ; Push 4th argument
push 0xF;                                       ; 3rd argument to WriteFile, length of string to print (15)
push IMAGE_BASE + DATA;                         ; 2nd argument to WriteFile, pointer to the string. I used an absolute pointer here, I'm unsure if the x86 instruction set allows for relative pointers for this kind of thing.
push [ebp - 4];                                 ; 1st argument to WriteFile, handle of 
call [IMAGE_BASE + IMPORT_ADDRESS_TABLE];       ; Calls WriteFile by using the address that the loader patches into the import address table at runtime
leave;                                          ; Undo function prologue
ret;                                            ; Return so the program doesn't crash
```
I've had some experience with assembly before and I can tell that this is pretty wasteful. It seems the compiler got it's arms tangled trying to link together both my handwritten assembly that retrieves the handle, and also the function call to WriteFile which was written in C. So, I cleaned up the assembly with some pretty basic modifications. First, I reordered the calculation of the handle so that it would go last and thus not need to be stored to a temporary slot in the stack. Second, I just used a random address beyond the end of my file for the pointer to the number of bytes written because I know that the loader is going to map at least one page of memory (4096 bytes) for my PE file, so anything past the end is completely fair game to use and this saves the need to create another temporary slot on the stack to keep it. Lastly, I removed the function prologue and epilogue as well since these are not needed. The inner function call is then able to restore the stack pointers for us so that the return instruction can be executed safely. This is similar to a tail call, which is a technique compilers use all the time, and is inspired by the structures I saw in the test files in step 5.
```asm
push 0;                                         ; Fifth argument to WriteFile, long pointer to overlap status
push IMAGE_BASE + DLL_NAME_1 + 0x30;            ; Fourth last argument to WriteFile, long pointer to number of bytes written
                                                ; I just made this be something past the file in memory which is probably ok since we allocate a whole page for this
push 0xF;                                       ; Third argument to WriteFile, number of bytes to write, which is just 0xF (15)
push IMAGE_BASE + DATA;                         ; Second argument to WriteFile, long pointer to buffer, which is just at RVA of DATA
mov eax, [ebx + 0x10];                          ; Calculating handle by looking into PEB idk I just copied the implementation of the kernel DLL don't ask
mov eax, [eax + 0x1C];
push eax;                                       ; First argument to WriteFile, the handle of the "file" or "stream" to write to
call [IMAGE_BASE + IMPORT_ADDRESS_TABLE];       ; Call the thing
ret;                                            ; Only effect is to adjust stack pointer (inner function that we call actually resets the stack pointer for us which is so kind)
                                                ; And to pop the top of the stack into the instruction pointer
```
The updated assembly file for the PE was thus:
```asm
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
    push 0;                                     ; Fifth argument to WriteFile, long pointer to overlap status
    push IMAGE_BASE + DLL_NAME_1 + 0x30;        ; Fourth last argument to WriteFile, long pointer to number of bytes written
                                                ; I just made this be something past the file in memory which is probably ok since we allocate a whole page for this
    push 0xF;                                   ; Third argument to WriteFile, number of bytes to write, which is just 0xF (15)
    push IMAGE_BASE + DATA;                     ; Second argument to WriteFile, long pointer to buffer, which is just at RVA of DATA
    mov eax, [ebx + 0x10];                      ; Calculating handle by looking into PEB idk I just copied the implementation of the kernel DLL don't ask
    mov eax, [eax + 0x1C];
    push eax;                                   ; First argument to WriteFile, the handle of the "file" or "stream" to write to
    call [IMAGE_BASE + IMPORT_ADDRESS_TABLE];   ; Call the thing
    ret;                                        ; Only effect is to adjust stack pointer (inner function that we call actually resets the stack pointer for us which is so kind)
                                                ; And to pop the top of the stack into the instruction pointer

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
    dw 0                    ; [UNUSED/FREE] Function ordinal (loader attempts to match this first)
    db "WriteFile", 0       ; Function name (loader only uses if match fails)

; Name of DLL 1

DLL_NAME_1:
    db "KERNEL32.dll", 0    ; Name of DLL 1 from the import directory/table

MAIN_SIZE equ $ - CODE

times align($ - $$, 16) - ($ - $$) db 0; Padding to end of section

CODE_SIZE equ $ - CODE

FILE_SIZE equ $ - $$
```
Let's see how this file does for size when assembled:
```powershell
PS root\TinyHW\step8> nasm -f bin tinyhws8.exe -l tinyhws8.lst tinyhws8.asm
```
```powershell
PS root\TinyHW\step8> certutil -encodehex tinyhws8.exe tinyhws8.exe.hex
Input Length = 368
Output Length = 1702
CertUtil: -encodehex command completed successfully.
```
That's a nice save. This is a 16 byte save because the file is still being padded to a multiple of 16 bytes, although I know that this is not necessary. It just felt better to keep some saves up my sleeve for later. Let's ensure that this new assembly still works:
```cmd
root\TinyHW\step8>tinyhws8
Hello, World!

```
Now it's time for some more cursed techniques.
## Step 9
This was always going to be inevitable, but I wanted to delay it as much as possible so that I could maximise everything else first. However, now was the time to start overlapping sections of the file. This is possible due to the sheer number of unused fields that were uncovered in step 7, which allows us to place structures in this unused space. I printed out a copy of the hexdump of the file and highlighted the different sections and all the fields that were either restricted or unable to be changed. In doing so, I noticed that the longest data structure that was forced to be contiguous was the combined structure of the PE header and section table, stretching from offset 0x40 to offset 0xEF, covering 176 bytes. This is therefore a limiting factor since theres nothing you can do to split this section up and overlap it with itself - the loader will parse these 176 bytes in one continuous stream. It is therefore important to put the PE header as early as possible in the file. 
The ideal case would be to put the PE header at offset 0x02, which is the earliest it could possibly go. If you do this, then you need to set the pointer to the PE header e_lfanew to 0x02. However, with the PE header at 0x02, e_lfanew is itself inside the PE header and thus sets the section alignment field of the PE header to 0x20000. To be quite honest with you, I have no idea why this doesn't work. Other files seem quite fine with a section alignment of 0x20000, but apparently not this one. Putting the PE header at 0x03 causes a similar problem, but putting it at 0x04 sets the section alignment to 0x04, which is completely allowed and okay. So the earliest we can place the PE header is at offset 0x04. 
I therefore moved the PE header to this offset, and then looked for more opportunities to compress the file. 
My ultimate goal was to overlap every other piece of data or code in the file with the PE header/section table, so that the end of the section table was also the end of the file. This would make the file as small as physically possible because the PE header and section table cannot be split up into smaller units. 
I considered printing out and cutting up the hexdump of the file into a jigsaw puzzle that I had to fit together physically, since this would allow me to test combinations way faster than by staring at a screen. However, I decided to look for more compression opportunities first.
One of the first things I tried was removing the import lookup table. It seemed strange that it was not being used, so I thought it might be removable. And sure enough, testing revealed that this could be completely removed and the loader was just fine with it. I don't know why this wasn't the case for ayaka14732, because for them the import lookup table (which they refer to with the label intbl in their assembly) was clearly being used since it was the only place that pointed to the name of the function to import. But here, the loader just didn't seem to ever care. 
I then considered importing by ordinal, since this would save me having to create a hint/name table at all, and thus the expensive text WriteFile would not need to be written down. However, research determined that this is extremely unstable and probably won't work on anyone else's PC because ordinals are highly shuffled between updates. However, I did discover that there is no need to write out `KERNEL32.dll` in full with the `.dll` at the end, as it turns out the loader is smart enough to know what to do if you just put `KERNEL32`. This reduced the length of the area that I would have needed to overlap this string in to fit inside the headers, which significantly opens up the options for everything else.
However, I quickly ran into a snag with the text `Hello, World!\r\n`. This was 15 bytes long, and in theory this could fit into the fields specifying the size of stack and heap reserves and commits. However, these fields really didn't like going over 0x70000000, and I suspect that this is actually dependent on how much memory is available at the time of execution, or something. The problem is that ascii lowercase letters range from bytes 0x61 to 0x7a, which ended up causing problems with the overlap. The next largest suitable space I could find to overlap the text (I will explain why I didn't overlap it into other regions that would have been big enough later) was unrestricted but only 14 bytes long. So I made the decision to drop the `\r` from the string and only print `Hello, World!\n`, which was a compromise, but really the distinction between `\r\n` and `\n` shouldn't be important when viewed from a console.
With this change I was able to fit `Hello, World!\n` in the optional header between the magic field 0x10B and the field specifying the address of the entry point in memory once mapped by the loader. This then meant I had to change the length argument for WriteFile to 0x0E from 0x0F. I then fit `KERNEL32` after the image base and before the image base field. This string did not need to be explicitly null terminated because the little endian encoding of the entry point 0x690000 is 00 00 69 00, so the null terminator is provided for me by the entry point field. 
I then focused on fitting the import directory and import address table into the headers. I knew that trailing zeroes didn't need to be added to the file to make up fields that were zero as the loader would map the sections into a memory page which was zeroed out beforehand. So my goal was to overlap trailing zeroes so that I could delete them and thus delete two sets of redundant zeroes rather than just one. This should enable for more space saving. 
I experimented first with the import directory. This needs to have a null entry after the final entry with data to signify the end of the table, as it doesn't have a length specifier or anything like that. Experimentation showed that the loader is somewhat strict with this, and the fields specifying the address of the dll name and the thunk in the import address table need to be zeroed or else it won't run. My goal was to overlap the null entries of the import directory with the zeroed and unused fields in the section table, so I put the import directory start location right around the start of the section table. I spent a while trying to fit it in, and eventually found a configuration that doesn't cause any errors and also leaves enough space for the hint/name table entry of `WriteFile` to fit into the unused field for the address of the unused import lookup table as well. Finally, the import address table was moved up into the data directories since it only needed 8 bytes of space and could easily fit in that location. This meant that everything except for the code had been folded into the headers according to my goal.
However, around this time, I started having issues. When trying to run the file, it would always give me errors saying that this is an unsupported 16 bit application and couldn't run. This confused me, because it seemed entirely dependent on the length of the file. If I added padding to the file to reach 268 bytes, it worked fine. But as soon as I removed one padding byte to reach 267, it suddenly stopped working. 
Then I realised that this must be why everyonne else had stopped at 268 bytes. There must be some hard limit preventing the size from going lower, perhaps Windows simply refuses to run anything under 268 bytes. I had to check for sure, though.
So I spent the rest of the day setting up a network kernel debugging session in [WinDbg](https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/) attached to a virtual machine to see if I could catch the check that throws this error. Of course, it's not quite so simple, since millions upon millions of instructions get executed to load the file and even if a check fails, a backup path could run some microseconds later that loads it anyway. Nonetheless, I really wanted to try and find the source of this apparent 268 byte limit, so I pressed on. While searching google, the google search inbuilt AI told me that I might be able to catch the error if I set a breakpoint in the function MiCreateImageFileMap. This took ages to get right because WinDbg seems to really struggle with connecting to debugger and the printouts seem really misleading to me, but anyway. 
Eventually, I was able to find the point in the code where a function returned with an error code, which seems like it could be the culprit. Here is a breakdown of the offending code:
```asm
fffff802`6a69b4a2 498b5518       mov     rdx, qword ptr [r13+18h]
fffff802`6a69b4a6 b84d5a0000     mov     eax, 5A4Dh
fffff802`6a69b4ab 488955a0       mov     qword ptr [rbp-60h], rdx
fffff802`6a69b4af 663902         cmp     word ptr [rdx], ax
fffff802`6a69b4b2 0f85fe030000   jne     ntkrnlmp!MiCreateImageFileMap+0x5da (fffff8026a69b8b6)
fffff802`6a69b4b8 8b4a3c         mov     ecx, dword ptr [rdx+3Ch]
fffff802`6a69b4bb 894c2470       mov     dword ptr [rsp+70h], ecx
fffff802`6a69b4bf 8d8108010000   lea     eax, [rcx+108h]
fffff802`6a69b4c5 3bc1           cmp     eax, ecx
fffff802`6a69b4c7 0f86b5181800   jbe     ntkrnlmp!MiCreateImageFileMap+0x181aa6 (fffff8026a81cd82)
fffff802`6a69b4cd 4c8b7580       mov     r14, qword ptr [rbp-80h]
fffff802`6a69b4d1 488d8108010000 lea     rax, [rcx+108h]
fffff802`6a69b4d8 448be9         mov     r13d, ecx
fffff802`6a69b4db 493bc6         cmp     rax, r14
fffff802`6a69b4de 0f87b3181800   ja      ntkrnlmp!MiCreateImageFileMap+0x181abb (fffff8026a81cd97)
```
The first group of instructions simply checks the MZ header. If the first two bytes of the file are not MZ, it jumps to what is presumably an error handler of some kind. For us, that's not important since the first two bytes are MZ, as is required. Then, it checks the field `e_lfanew` (i.e. address of PE header within the file), and loads it into `ecx`. Then, it saves this onto space left on the stack. It then checks if adding `0x108` to `e_lfanew` causes an overflow, i.e. exceeds `2^32-1`. Again, this check passes for us since our file is nowhere near that big. Then comes the real problem. It moves a value previously stored on the stack (which after checking, turns out to be the file size returned by RtlGetFileSize) into a register, and then checks if `e_lfanew + 0x108 > file size`. If this is true, then it takes the branch and leads to an error handler which returns with error code `0xC0000130` which corresponds to STATUS_INVALID_IMAGE_PROTECT. The [documentation](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-erref/596a1078-e883-4972-9bbc-49e60bebca55) says that this means:
```The specified image file did not have the correct format: it did not have a proper e_lfarlc in the MZ header.```
The field `e_lfarlc` is contained within the DOS header, and is only important if this is a 16 bit program. This means that the system has become convinced somehow that the file we are trying to run is a 16 bit program, hence the unsupported 16 bit error message. What is particularly interesting is the check that it performs to determine this. The error is primarily from the fact that our file has `e_lfanew + 0x108 > file size`, as we set `e_lfanew` to 0x04, and so `e_lfanew + 0x108 = 0x10C = 268`. So the check becomes: return error if the file is smaller than 268 bytes, exactly as suspected. It does at least show that this is not a hard check for 268 specifically (at least not in this execution path), but rather a check to see if 264 bytes are present after the offset that `e_lfanew` points to. 
This is interesting because 264 bytes is equal to the total combined maximal size of the following structures for a *64 bit* PE file (PE32+):
```
PE_HEADER:                          4
COFF_FILE_HEADER:                   20
IMAGE_OPTIONAL_HEADER (PE32+):      240
```
To reiterate, those are the *maximum* sizes of those structures in a *64 bit* PE file, which makes the structures larger due to having longer addresses. So, it seems like the kernel loader is checking to see if the largest possible PE header can fit in the remainder of the file, and if it can't, then your binary is rejected. 
This means that 268 would not be the limit if we could get the PE header to start at offset 0x02. However, for reasons unknown to me, I can't get the loader to accept this, and it seems that nor can anyone else (at least for now).
So, with that rather disappointing piece of news, I realised I was stuck at 268 bytes. But I could still get "smaller" in my books, if I changed how I scored "size". I decided that my "size" score would be equal to the file size without trailing zeroes at the end, which is an artificial way of allowing optimisation to continue even though the file size is itself stuck at 268.
I just needed to fit the machine code itself into the headers and make sure it ends before the last nonzero entry in the section table to achieve my goal of having the lowest score that I could achieve with my current understanding. However, the code looked rather long still and I wasn't confident that it would fit, so I decided to try and shorten it some more, this time also considering the encoding of the instructions itself.
The first improvement that I found was that the fourth argument to WriteFile can be zero and it will still work fine, saving the need to push an absolute address to the stack. The code for the fifth, fourth, and third arguments was therefore simplified to:
```asm
push 0;                     ; Fifth argument, unused                
push 0;                     ; Fourth argument, unused
push 0xE;                   ; Third argument, number of bytes to write (14)
```
The code for the second argument could be improved by using a relative pointer. I inspected the state of the registers when the program starts in x32dbg and found that registers `ecx`, `edx`, `esi`, and `edi` all contained the absolute address of the entry point in memory. Therefore, I could use the `lea` instruction to put the absolute address of the `Hello, World!\n` string directly into a register. I chose to do it like this:
```asm
lea eax, [ecx + DATA - ENTRY_POINT];        ; Calculate second argument, pointer to string
push eax;                                   ; Push it
```
I could also make an improvement by pushing the handle directly to the stack instead of storing it in `eax` first. The code for the first argument was now:
```asm
mov eax, [ebx + 0x10];                      ; Getting address of PEB
push [eax + 0x1C];                          ; Push offset 0x1C as this is the handle we want
```
Finally, I improved by shortening the call instruction to calculate the address as a short call based on the registers that already contain the entry point. The last part of the code was now:
```asm
call [ecx + IMPORT_ADDRESS_TABLE - ENTRY_POINT];            ; Call WriteFile using relative address from ecx
ret;                                                        ; Safely exit so no errors are thrown
```
This shortened the machine code to just 27 bytes, and I was much more confident that I could sprinkle this throughout the headers with short `jmp` instructions to move between segments of code. In the end, I only needed 3 code segments because the code was so short and the headers had so much unused space. This now meant that the last nonzero byte of the entire file was the last nonzero byte of the section table, which was my final goal for this project after learning about the limitation on file size. This was the final assembly code used:
```asm
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
    push [eax + 0x1C];      ; Checksum part 2                                       ; [UNUSED/FREE] PointerToSymbolTable part 3
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
```
Let's assemble it:
```powershell
PS root\TinyHW\step9> nasm -f bin -o tinyhws9.exe -l tinyhws9.lst tinyhws9.asm
```
Confirm that the size is 268:
```powershell
PS root\TinyHW\step9> certutil -encodehex tinyhws9.exe tinyhws9.exe.hex                 
Input Length = 268
Output Length = 1254
CertUtil: -encodehex command completed successfully.
```
And confirm that it works:
```cmd
root\TinyHW\step9>tinyhws9
Hello, World!

```
I then opened the file with the hex editor [HxD](https://mh-nexus.de/en/hxd/) to determine the offset of the last nonzero byte, which turns out to be 0xA0, or 160. This gives a score of 160 + 1 = 161 since I need to count that last byte itself in the total.
This is perhaps the smallest possible score for this program with `e_lfanew = 0x4` and `PointerToRawData` in the section header not equal to 0. If I could find a way to set `PointerToRawData` equal to 0, then it would save 4 bytes. A further 2 could be saved if I could figure out how to make `e_lfanew = 0x2` not get rejected by the loader.

**Update**

I decided to do another kernel debugging session to see if I could figure out why `e_lfanew = 0x2` was being refused by the loader. I found this snippet in nt!MiCreateImageFileMap:
```asm
nt!MiCreateImageFileMap + 0x22b:                                                                                // At this point, rdx = file_start_addr, and r13 = e_lfanew
    fffff806`496a9507 4a8d3c2a       lea     rdi, [rdx+r13]                                                     // rdi = file_start_addr + e_lfanew
    fffff806`496a950b 4d2bcd         sub     r9, r13                                                            
    fffff806`496a950e 488b4c2478     mov     rcx, qword ptr [rsp+78h]                                           
    fffff806`496a9513 4c8bc2         mov     r8, rdx                                                            
    fffff806`496a9516 488bd7         mov     rdx, rdi                                                           // rdx = file_start_addr + e_lfanew
    fffff806`496a9519 e8ea090000     call    ntkrnlmp!MiVerifyImageHeader (fffff806496a9f08)

    ntkrnlmp!MiVerifyImageHeader:
        fffff806`496a9f08 48895c2408     mov     qword ptr [rsp+8], rbx                                         
        fffff806`496a9f0d 4889742410     mov     qword ptr [rsp+10h], rsi                                       
        fffff806`496a9f12 57             push    rdi                                                            
        fffff806`496a9f13 4883ec20       sub     rsp, 20h                                                       
        fffff806`496a9f17 4c8bd2         mov     r10, rdx                                                       // r10 = file_start_addr + e_lfanew
        fffff806`496a9f1a 498bc0         mov     rax, r8                                                        
        fffff806`496a9f1d 488bd1         mov     rdx, rcx                                                       
        fffff806`496a9f20 41f6c203       test    r10b, 3                                                        // Is file_start_addr + e_lfanew aligned to 4 byte boundary?
        fffff806`496a9f24 0f85fe161800   jne     ntkrnlmp!MiVerifyImageHeader+0x181720 (fffff8064982b628)       // If not, error.
```
Instructions that do not have comments are not relevant and you can ignore them. The key takeaway is that the loader enforces that `PE_HEADER & 0x3 == 0` or else it will raise the same error as if the file is too short. So to get the lower bound smaller, you'd have to start the PE header at offset 0. However, you can't do that as the PE signature would overwrite the MZ signature and therefore the file would get rejected even earlier by the loader. So, you can't put the PE header at an offset less than 4, meaning that only the bytes from the end of the section table can be saved from the score.

In fact, it is possible to omit the section table entirely. If you specify `NumberOfSections = 0` and also `AddressOfEntryPoint = 0`, the loader will accept it and begin execution at the MZ header. This does not cause an error but needs to be handled carefully, but from there you can jump to the real code body. I tested this out to see if I could make it even shorter by using this trick, but it seems that the loader will not patch the address of the imports unless you have at least one section, or something. I might do another kernel debugging session to try and track down why that is as well.

## Looking Back + Bonus Step 10
Having done this project and now looking at it from the perspective of writing about my journey, it is clear that I could have done things better. If I had read the material at the earliest moment rather than delaying it, I could have potentially saved a lot of time. However, this presented an opportunity to see what else I could have done and look at this problem in a new way, and I couldn't pass it up. 
I found that you can in fact use `puts` just fine, even without any CRT startup code running. The handle is still accessible in the same way as before, so there's no obvious reason why it wouldn't work, since `puts` calls into WriteFile anyway. So I had a go using puts, and this gave me a bit more space since the machine code was shorter, only 12 bytes this time. Additionally, the string `puts` is 5 bytes shorter than the string `WriteFile`, so the function name could be placed in a location that would otherwise be unused and free up larger spaces for other structures. 
So, I made the 161 byte score using `puts`, however it left me wanting more. I still hadn't scratched that one last itch of why I couldn't get `PointerToRawData` to equal 0. So I did the only thing that I knew how to at this point: ran another kernel debugging session.
I won't go into too much detail but I found that when a certain condition is met, it checks to see if `PointerToRawData` is equal to `VirtualAddress`. If not equal, it rejects the file. I couldn't find what condition needs to be met for this check to happen, and I couldn't be bothered to trace thousands of machine instructions to try and figure it out. So, I set both of these fields to 0 and the file was now accepted. All that remained was to figure out how to fit in the code and import tables into the headers again. It turned out to be a bit more difficult than before because I took a wrong turn initially, but in the end it worked out quite nicely.
Here is the assembly file used:
```asm
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
```
Assemble:
```powershell
PS root\TinyHW\step10_bonus nasm -f bin -o tinyhws10.exe -l tinyhws10.lst tinyhws10.asm
```
Now create hexdump as usual:
```powershell
PS root\TinyHW\step10_bonus> certutil -encodehex tinyhws10.exe tinyhws10.exe.hex                                                           
Input Length = 268
Output Length = 1254
CertUtil: -encodehex command completed successfully.
```
Finally, test that it runs:
```cmd
root\TinyHW\step10_bonus>tinyhws10
Hello, World!

```
And there we go. That brings the score down to 157, as after the 157th byte, all bytes are zeroes until reaching the 268 hard minimum. 

