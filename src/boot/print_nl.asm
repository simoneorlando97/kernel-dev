print_nl:
  pusha 
start_nl:
  mov al,[bx]
  cmp al, 0x0 
  je finish_nl

  mov ah, 0x0e
  int 0x10

  add bx, 1     
  jmp start_nl

  
finish_nl:
  mov ah, 0x0e
  mov al, 0x0a 
  int 0x10
  mov al, 0x0d
  int 0x10

  popa
  ret
