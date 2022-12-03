## Writing a Kernel from Scratch

The goal of this project is to delve into low-level programming 
starting from the development of the basic functions which constitute 
a real functioning kernel.  
The topics that we are going to deepen and that will be necessary for the 
development of our kernel are:
- How a computer boots
- How  to  write  low-level  programs  in  the  barren  landscape  where  no  operatingsystem yet exists
- How to configure the CPU so that we can begin to use its extended functionality
- How to bootstrap code written in a higher-level language, so that we can reallystart to make some progress towards our own operating system
- How to create some fundamental operating system services, such as device drivers,file systems, multi-tasking processing  

Our path includes the following main steps:
1. Boot from scratch, without GRUB
2. Enter 32-bit mode
3. Jump from Assembly to C
4. Write a tiny, basic libc 

In order to test our work we rely on the QEMU emulator and on the NASM assembler for Intel x86 to
translate our assembly code in machine code.

### 1. Boot from scratch
When the computer boots, the BIOS doesn't know how to load the OS, 
so it delegates that task to the boot sector. Thus, the boot sector 
must be placed in a known, standard location. That location is the 
first sector of the disk (cylinder 0, head 0, sector 0) and it takes 
512 bytes.  
To make sure that the "disk is bootable", the BIOS checks that bytes 
511 and 512 of the alleged boot sector are bytes `0xAA55`.  
The simplest boot sector is:
```
e9 fd ff 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[ 29 more lines with sixteen zero-bytes each ]
00 00 00 00 00 00 00 00 00 00 00 00 00 00 55 aa
```
We can obtain the above bytes by writing the following simple assembly code:
```nasm
; Infinite loop (e9 fd ff)
loop:
    jmp loop 

; Fill with 510 zeros minus the size of the previous code
times 510-($-$$) db 0
; Magic number
dw 0xaa55 
```
and translating it with the command:
```bash
nasm -f bin boot_sect_simple.asm -o boot_sect_simple.bin
```
Finally, we can try it on QEMU:
```bash
qemu boot_sect_simple.bin
```

### 2. Enter 32-bit mode
The 32-bit mode allows us to use 32 bit registers and memory addressing, 
protected memory, virtual memory and other advantages, but we will lose 
BIOS interrupts and we'll need to code the GDT. The easiest way to program 
the GDT is to define two segments, one for code and another for data. 
These can overlap which means there is no memory protection, but it's 
good enough to boot. The first GDT entry must be 0x00 to make sure that 
the programmer didn't make any mistakes managing addresses. Furthermore, 
the CPU can't directly load the GDT address, but it requires a meta 
structure called the "GDT descriptor" with the size (16b) and address 
(32b) of our actual GDT. It is loaded with the lgdt operation.  
In order to jump into 32-bit mode we need to:
1. Disable interrupts
2. Load our GDT
3. Set a bit on the CPU control register `cr0`
4. Flush the CPU pipeline by issuing a carefully crafted far jump
5. Update all the segment registers
6. Update the stack
7. Call to a well-known label which contains the first useful code in 32 bits

After entering 32-bit mode, we will call `BEGIN_PM` which is the entry point for our actual useful code (e.g. kernel code, etc).

### 3. Jump from Assembly to C
In order to compile system-independent code, we need the flag `-ffreestanding`, so we have to compile 
`kernel.c` in this fashion:
```bash
i386-elf-gcc -ffreestanding -c kernel.c -o kernel.o
```
Then to produce a binary file, we use the linker. In particular, we place the offset 
at 0x0 and use the binary format which generates machine code without any labels and/or 
metadata.
```bash
i386-elf-ld -o kernel.bin -Ttext 0x0 --oformat binary kernel.o
```
In `kernel.c` we have a dummy function that does nothing. That function simply forces us to 
create a kernel entry routine which does not point to byte `0x0` in our kernel, but to an actual 
label which we know that launches it. In our case, function `main()`. That routine is coded on `kernel_entry.asm`.
To compile this file, instead of generating a binary, we will generate an elf format file which will be linked with `kernel.o`.
```bash
nasm kernel_entry.asm -f elf -o kernel_entry.o
```
```
i386-elf-ld -o kernel.bin -Ttext 0x1000 kernel_entry.o kernel.o --oformat binary
```
Now we have two separate files for the bootsector and the kernel, we can simply concatenate them with the command:
```bash
cat bootsect.bin kernel.bin > os-image.bin
```
Finally, we can now run `os-image.bin` with qemu.

### 4. Write a tiny, basic libc
It is useful in our kernel development to develop a library containing some of the basic primitives. 
An example are the functions for printing text on the screen. The first function we want to implement 
is our version of the well known `kprint` present in all linux based distributions.  
In `drivers/screen.h` we have defined some constants for the VGA card driver and three public functions, 
one to clear the screen and another couple to write strings.  
We can now compile together the files `kernel/kernel.c` and `drivers/screen.c` in order to produce the `kernel.bin` file.
Then, we proceed with the concatenation:
```bash
cat bootsect.bin kernel.bin > os-image.bin
```
Our new kernel is finally able to print strings in a comfortable way!
