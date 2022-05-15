org 0100h
jmp eti0 
;;datos
col dw 0   ;Columna actual
ren dw 0   ;Renglon actual 
bot dw 0   ;boton de mouse presionado
cc db 00001010b ;Color actual
ac db 00001010b ;Color auxiliar  

ListaColores  db 00111111b, 1, 2, 3, 4, 5, 14, 7
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
  
  modboxstartx equ colorboxstartx+ colorCount*colorboxwidth+200
  modboxstarty equ colorboxstarty
  modboxwidth equ 20
  modcount equ 3
  erasew equ 10
  draww equ 5
  airw equ 3 
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

clickColor macro x1,y1,x2,y2 
pushall
mov ax, 3d
int 33h
mov bot, bx
cmp bot,1d
jne endcl;loopback
;cmp col,x1
;jb eti2
;cmp col,x2
;ja eti2
;cmp ren,y1
;jb eti2
;cmp ren,y2
;ja eti2
mov ah,0Dh
mov cx,col
mov dx,ren
int 10h
mov ac,al
mov cc,dl
dibLinea 20,20,60,60
endcl:
popall  
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
mov al,cc ;color (16 colores) cambiar por variable ig
mov cx,c
mov dx,r
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
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;
eti0:
call inigraf
call prende
dibLinea 0,maxY, maxX,  maxY+1
dibColores 
 
 eti1:
 clickColor ColoresX,ColoresY,ColoresX-140,ColoresY-20
 eti2:
 call ftsamout
 call apaga
 call cierragraf    
 
 int 20h

;;;;;;;;;;;;;;;;;;;;;;
ftsamout proc
mov ax, 3d
int 33h
mov bot, bx
call drawnm
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
mov col,cx
mov ren,dx
call posC
numero col
call posR
numero ren
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