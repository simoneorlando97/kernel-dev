print:
  pusha 
start:
  mov al,[bx]
  cmp al, 0x0 
  je finish

  mov ah, 0x0e
  int 0x10

  add bx, 1     
  jmp start

finish:
  popa
  ret