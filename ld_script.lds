ENTRY(kernel_main)

SECTIONS
{
  . = 0x10000; 
  .text : { *(.text) } 
  . = 0x8000000;
  .rodata : { *(.rodata) }
  .data : { *(.data) } 
  .bss  : { *(.bss) } 
}

