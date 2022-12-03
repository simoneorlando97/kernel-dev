; nasm -f bin ./src/boot/boot_sect.asm -o ./out/boot_sect.bin
; qemu-system-x86_64 ./out/boot_sect.bin -boot c 
[org 0x7c00]
KERNEL_OFFSET equ 0x1000

; Code 
mov [BOOT_DRIVE], dl ; Remember that the BIOS sets us the boot drive in 'dl' on boot

mov bp, 0x8000
mov sp, bp

mov bx, MSG_boot_sect
call print_nl

call load_kernel

mov bx, MSG_switch_pm
call print_nl
call switch_pm
jmp $


; Subroutines 
%include "./src/boot/print_nl.asm"
%include "./src/boot/disk_load.asm"
%include "./src/boot/switch_pm.asm"
%include "./src/boot/print32.asm"

[bits 16]
load_kernel:
  mov bx, MSG_LOAD_KERNEL
  call print_nl
  mov bx, KERNEL_OFFSET 
  mov dh, 16
  mov dl, [BOOT_DRIVE]
  call disk_load
  mov bx, MSG_SUCC_KERNEL
  call print_nl
  ret

[bits 32]
BEGIN_PM: 
  call KERNEL_OFFSET
  jmp $

; Data
BOOT_DRIVE:
  db 0 
MSG_boot_sect:
  db '[+] Starting boot sector...', 0

MSG_switch_pm: 
  db '[+] Switching to protected mode...', 0

MSG_pm:
  db '[+] Successfully switched into protected mode!', 0

MSG_LOAD_KERNEL:
  db '[+] Loading the kernel...', 0
  
MSG_SUCC_KERNEL:
  db '[+] Kernel successfully loaded!', 0 

; Padding
times 510 - ($-$$) db 0
dw 0xaa55
