org 0100h
jmp eti0 
;;datos
col dw 0   ;Columna actual
ren dw 0   ;Renglon actual 
bot dw 0   ;boton de mouse presionado
cc db 00001010b ;Color actual
ac db 00001010b ;Color auxiliar
cad db "Em es pe INT$"
cad1 db "Presione ESC para salir$"  
pincel dw 0 

ListaColores  db 00111111b, 9, 2, 3, 4, 5, 14, 7
  colorCount equ $-ListaColores
    
maxY equ 420
maxX equ 640

  xs dw ?
  ys dw ?
  xf dw ?
  yf dw ?   
  
state db 0 ; 0 = Draw, 1 = erase
temp dw 0

  ColoresY equ maxY + 20
  ColoresX equ 20
  ColoresA equ 20
  
  modX equ ColoresX+ colorCount*ColoresA+200
  modY equ ColoresY
  modW equ 20
  modcount equ 5
  erasew equ 10
  draww equ 5
  airw equ 3
  
  ciclobot dw 0 
;check

pushall macro
  push ax
  push bx
  push cx
  push dx
  push bp
  push si
  push di
endm


popall macro
  pop di
  pop si
  pop bp
  pop dx
  pop cx
  pop bx
  pop ax
endm

dibLinea macro x1, y1, x2, y2
  pushall
  mov ax, x1
  mov xs, ax
  mov ax, y1
  mov ys, ax
  mov ax, x2
  mov xf, ax
  mov ax, y2
  mov yf, ax
  call ddraw
  popall
endm
dibCuad macro x1, y1, x2, y2
  pushall
  mov ax, x1
  mov xs, ax
  mov ax, y1
  mov ys, ax
  mov ax, x2
  mov xf, ax
  mov ax, y2
  mov yf, ax
  call ddraw
  mov ax, x1
  inc ax
  inc ax
  mov xs, ax
  mov ax, y1
  inc ax
  inc ax
  mov ys, ax
  mov ax, x2
  dec ax
  dec ax
  mov xf, ax
  mov ax, y2
  dec ax
  dec ax
  mov yf, ax
  mov al, 0
  mov ac, al
  call ddraw
  popall
endm
clickColor macro  

mov ah,0Dh
int 10h
mov ac,al
mov cc,al

dibLinea 20,20,60,60
  
endm

dibColores macro
  xor si, si
  mov bp, ColoresX
  mov di, ColoresY
  colorLoop:
  mov al, ListaColores[si]
  mov ac, al
  inc si
  mov cx, bp
  add cx, ColoresA
  mov dx, di
  add dx, ColoresA
  dibLinea bp,di,cx,dx
  mov bp, cx
  cmp si, colorCount
  jb colorLoop
  mov al, ListaColores
  mov ac, al
  mov cc, al
endm

dibmods macro
  mov si, 0
  mov bp, modX
  mov di, modY
  modLoop:
  mov al, ListaColores[si]
  mov ac, al
  inc si
  mov cx, bp
  add cx, modW
  mov dx, di
  add dx, modW
  dibCuad bp,di,cx,dx
  mov bp, cx
  cmp si, modCount
  jb modLoop
  mov al, ListaColores
  mov ac, al
  mov cc, al
endm

;check
numero macro num
mov ax,num
mov bl,100d
div bl
mov dl,al
add dl,30h
push ax
mov ah,02h
int 21h
pop ax
shr ax,8d
mov bl,10d
div bl
mov dl,al
add dl,30h
push ax
mov ah,02h
int 21h
pop ax
shr ax,8d
mov dl,al
add dl,30h
mov ah,02h
int 21h
endm

ponpix macro c r  


mov ah,0Ch 
mov cx,c
mov dx,r
mov al,cc ;color (16 colores) cambiar por variable ig
int 10h

endm  

ponpixhl macro c r
mov ah,0Ch
mov al,cc ;color (16 colores) cambiar por variable ig
mov cx,c
mov dx,r
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
inc cx
int 10h
endm

ponpixvl macro c r
mov ah,0Ch
mov al,cc ;color (16 colores) cambiar por variable ig
mov cx,c
mov dx,r
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
inc dx
int 10h
endm

ponpixthicc macro c r
  
mov ah,0Ch
mov al,cc ;color (16 colores) cambiar por variable ig 
mov cx,c
mov dx,r
int 10h
inc cx
inc dx
int 10h
inc cx
inc dx
int 10h
inc cx
inc dx
int 10h
inc cx
inc dx
int 10h
inc cx
inc dx
int 10h
inc cx
inc dx
int 10h
inc cx
inc dx
int 10h
inc cx
inc dx
int 10h
inc cx
inc dx
int 10h
inc cx
inc dx
int 10h
inc cx
inc dx
int 10h
endm

get_input macro
    local check,escape, save
    
    
    escape:
        mov ah, 06h     ;;Check keyboard buffer for input
        mov dl, 255
        int 21h
        cmp al, 1Bh     ;;Esc = exit
        je eti2

    check:          ;;Check for mouse input
        call drawnm
        mov ax, 0003h
        int 33h
        mov col,cx
        mov ren,dx 
        cmp bx,1
        je save
        jne escape
    save:
       
   
endm  

cmpstuff macro 
    ;;jaja, esta cosa es una barbaridad
   cmp col,380
   jb comp0
   cmp col, 400
   ja comp0
   
   cmp ren, 440
   jb comp0
   cmp ren, 460
   ja comp0 
   mov  pincel,0
   
   comp0:
   cmp col,400
   jb comp1
   cmp col, 420
   ja comp1
   
   cmp ren, 440
   jb comp1
   cmp ren, 460
   ja comp1 
   mov  pincel,1
   
   comp1:
    cmp col,420
   jb comp2
   cmp col, 440
   ja comp2
   
   cmp ren, 440
   jb comp2
   cmp ren, 460
   ja comp2
   mov  pincel,2
   
   
   comp2:
   cmp col,440
   jb comp3
   cmp col, 460
   ja  comp3
   
   cmp ren, 440
   jb comp3
   cmp ren, 460 
   ja comp3
   mov  pincel,3
   
   comp3:
   cmp col,460
   jb etidraw
   cmp col, 480
   ja  etidraw
   
   cmp ren, 440
   jb etidraw
   cmp ren, 460 
   ja etidraw
    mov cc,15d
    mov ac,15d
    dibCuad 20,20,60,60
    mov cc,0b
    mov ac,0b
   
   
   
 
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;
eti0:
call inigraf
call prende
mov ac,15d
dibLinea 0,maxY, maxX,  maxY+1
dibLinea 20,20,60,60
dibColores 
dibmods

 eti1:
 
 get_input
 
 cmp al, 1Bh     ;;Esc = exit
 je eti2 
 
 cmp bx,1
 jne eti1
 call apaga
 ;;check if on color or toolbox
   cmp col,coloresX
   jb etiSelecP
   cmp col,coloresX+160
   ja etiSelecP
   cmp ren,coloresY
   jb etiSelecP
   cmp ren,coloresY+20
   ja etiSelecP
 clickColor
  
  etiSelecP:
   cmp col,380
   jb etidraw
   cmp col,480
   ja etidraw
   cmp ren,440
   jb etidraw
   cmp ren,460
   ja etidraw
   cmpstuff
 ;;check for current selected tool
 
 etidraw:
 
 
 cmp pincel,0
 jne Pinc0
 cmp ren, maxY
 ja etireset
  ponpix col,ren
 
 Pinc0:
 cmp pincel,1
  jne Pinc1
  cmp ren, maxY
 ja etireset
   ponpixhl col, ren          
 Pinc1:             
 cmp pincel,2
  jne Pinc2 
  cmp ren, maxY
 ja etireset
   ponpixvl col, ren   
 
 Pinc2:
 cmp pincel,3 
   jne etireset
   cmp ren, maxY
   ja etireset
   ponpixthicc col, ren   
 
 
 ;ponpix cx,dx
 
 etireset:
 call prende
 jmp eti1
 
 
 eti2:
 ;;call ftsamout
 call apaga
 call cierragraf    
 
 int 20h

;;;;;;;;;;;;;;;;;;;;;;
ftsamout proc
mov ax, 3d
int 33h
mov bot, bx
cmp bot,2d
jne eti1
ret
endp

ddraw proc 
      pushall
      mov cx, xs                  ;For xs <= CX < xf
    XLOOP:

        mov dx, ys                  ;For ys <= CY < yf
    YLOOP:

        mov al, ac               ;Change color of a pixel
        mov ah, 0ch
        int 10h

        inc dx
        cmp dx, yf
        jb YLOOP

        inc CX
        cmp CX, xf
        jb XLOOP
        popall
        ret
  ddraw endp

drawnm proc
    pushall
mov ax, 0003h
        int 33h    
mov col,cx
mov ren,dx
call posC
numero col
call posR
numero ren
    popall
ret
endp 

posC proc
mov ah,02h
mov dl,65d
mov dh,29d
mov bh,0h
int 10h
ret
   
endp

posR proc
mov ah,02h
mov dl,70d
mov dh,29d
mov bh,0h
int 10h
ret
endp

prende proc
mov ax,1d
int 33h
ret
endp
apaga proc
mov ax,2d
int 33h
ret
endp
inigraf proc
mov ah,0d
mov al,18d
int 10h
ret
endp
cierragraf proc
mov ah,0d
mov al,3d
int 10h
ret
endp