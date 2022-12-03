// gcc -ffreestanding -c ./src/kernel/kernel.c -o ./obj/kernel.o
// ld -o ./out/kernel.bin -Ttext 0x1000 ./obj/kernel_entry.o ./obj/kernel.o --oformat binary
// cat ./out/boot_sect.bin ./out/kernel.bin > os-image.bin
// qemu-system-x86_64 -fda ./os-image.bin

// On real hw: dd if=disk.img of=/dev/sdb bs=4M. if is input file, of is output file, bs is block size
#include "../drivers/screen.h"

void kernel_main () {
  
  // Sometimes printing individual characters works, 
  // but printing strings fails. This is usually due to the 
  // .rodata section missing in the linker script.
  char *str = "Welcome!";
  char * vidptr = (char *) 0xb8000;

  init_screen();

  vidptr[1] = str[0];
  vidptr[2] = 0x0f;
  vidptr[3] = 'e';
  vidptr[4] = 0x0f;
  vidptr[5] = 'l';
  vidptr[6] = 0x0f;
  vidptr[7] = 'c';
  vidptr[8] = 0x0f;
  vidptr[9] = 'o';
  vidptr[10] = 0x0f;
  vidptr[11] = 'm';
  vidptr[12] = 0x0f;
  vidptr[13] = 'e';
  vidptr[14] = 0x0f;
  vidptr[15] = ' ';
  vidptr[16] = 0x0f;
  vidptr[17] = 'T';
  vidptr[18] = 0x0f;
  vidptr[19] = 'o';
  vidptr[20] = 0x0f;
  vidptr[21] = ' ';
  vidptr[22] = 0x0f;
  vidptr[23] = 'T';
  vidptr[24] = 0x0f;
  vidptr[25] = 'o';
  vidptr[26] = 0x0f;
  vidptr[27] = 'H';
  vidptr[28] = 0x0f;
  vidptr[29] = '-';
  vidptr[30] = 0x0f;
  vidptr[31] = 'O';
  vidptr[32] = 0x0f;
  vidptr[33] = 'S';
  vidptr[34] = 0x0f;
  vidptr[35] = '!';
  vidptr[36] = 0x0f;
  
  return;
}