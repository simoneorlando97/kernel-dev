; nasm ./src/boot/kernel_entry.asm -f elf64 -o ./obj/kernel_entry.o
; ld -o ./out/kernel.bin -Ttext 0x1000 ./obj/kernel_entry.o ./obj/kernel.o --oformat binary
[bits 32]
[extern kernel_main]
call kernel_main
jmp $