; Bios routine for read the disk: 
; int 0x13 with ah = 0x02
; dl = drive's number 
; ch = cylinder's number 
; dh = track's number 
; cl = sector's number 
; al = number of sectors to read from the start point 
; bx = address in which load the sectors

; The function wants:
; dl = which drive 
; dh = how many sectors 
; bx = address in which we load the sectors  
disk_load:
  pusha 
  push dx 

  mov ah, 0x02
  mov al, dh 
  mov ch, 0x00
  mov dh, 0x00
  mov cl, 0x02 

  int 0x13 
  jc disk_error 

  pop dx 
  cmp al,dh 
  jne sector_error 
  popa
  ret 
   
disk_error:
  mov bx, DISK_ERROR_MSG 
  call print_nl
  jmp $ 

sector_error:
  mov bx, SECTOR_ERROR_MSG 
  call print_nl
  jmp $ 

DISK_ERROR_MSG:
  db "[!] Disk read error!", 0
SECTOR_ERROR_MSG:
  db "[!] Sector error!", 0
DISK_SUCC_MSG: 
  db "[+] Successfully load kernel!", 0