org 0100h
jmp eti0
;;datos
col dw 0   ;Columna actual
ren dw 0   ;Renglon actual
bot dw 0   ;boton de mouse presionado
cc db 00001010b ;Color actual
ac db 00001010b ;Color auxiliar

pincel dw 0

ListaColores  db 00111111b, 9, 2, 3, 4, 5, 14, 7
colorCount equ $-ListaColores

maxY equ 420
maxX equ 640

xs dw ?
ys dw ?
xf dw ?
yf dw ?
ColoresY equ maxY + 20
ColoresX equ 20
ColoresA equ 20
modX equ ColoresX+ colorCount*ColoresA+200
modY equ ColoresY
modW equ 20
modcount equ 5
ciclobot dw 0 

cad db 'Error, archivo no encontrado!...presione una tecla para terminar.$' 
filename db "C:\imagen.bmp" 
handle dw ?
imgcol dw 0
imgren dw 479
buffer db ?
colo db ?



;check
loadimg macro
 
 img:
mov ah, 3dh
mov al,0
mov dx, offset filename
int 21h
jc err
mov handle, ax

mov cx,118d
img1:
push cx
mov ah,3fh
mov bx, handle
mov dx, offset buffer
mov cx,1
int 21h
pop cx
loop img1

;mov ah,00h
;mov al, 18d 
;int 10h

img2:
mov ah,3fh
mov bx, handle
mov dx,offset buffer
mov cx,1
int 21h

mov al,buffer
and al,11110000b
ror al,4
mov colo,al
mov ah,0ch
mov al,colo
mov cx,imgcol 
mov dx,imgren

int 10h

mov al,buffer
mov al,00001111b
mov colo,al
inc imgcol
mov ah,0ch
mov al,colo
mov cx,imgcol
mov dx,imgren
int 10h
inc imgcol
mov ah,0ch
mov al,colo
mov cx,imgcol
mov dx,imgren
int 10h 

cmp imgcol,639d
jbe img2

mov imgcol,0
dec imgren
cmp imgren,-1
jne img2


jmp init

err:
call apaga
call cierragraf
mov ah,09h
lea dx,cad
int 21h
mov ah,07h
int 21h
int 20h
endm 

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
;Dibuja un rectangulo con los puntos iniciales y finales indicados
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
;Dibuja cuadrados sin relleno
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

;Cambia el color cuando se da click en la caja de colores
clickColor macro

mov ah,0Dh
int 10h
mov ac,al
mov cc,al

dibLinea 20,20,60,60

endm
;Dibuja la caja de colores
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

;Dibuja la caja de herramientas
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

;Pincel simple
ponpix macro c r


mov ah,0Ch
mov cx,c
mov dx,r
mov al,cc ;color (16 colores) cambiar por variable ig
int 10h

endm
;Pincel ancho horizontal
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
;Pincel ancho vertical
ponpixvl macro c r
mov ah,0Ch
mov al,cc 
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

;Pincel a n c h o
ponpixthicc macro c r

mov ah,0Ch
mov al,cc 
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
mov ren,dx     ;esta comparacion puede ser innecesaria, pero no me gusta arriesgarme
cmp bx,1
je save
jne escape
save:


endm

cmpstuff macro
;;jaja, esta cosa es una barbaridad
;Revisa si las coordenadas del raton corresponden con las de algun boton de herramienta

;Lapiz sencillo
cmp col,380
jb comp0
cmp col, 400
ja comp0

cmp ren, 440
jb comp0
cmp ren, 460
ja comp0
mov  pincel,0

;Linea horizontal
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
;Linea vertical
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

;Pincel grueso
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
;Goma
comp3:
cmp col,460
jb etidraw
cmp col, 480
ja  etidraw

cmp ren, 440
jb etidraw
cmp ren, 460
ja etidraw
mov pincel, 3
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
loadimg

init:
;Se dibuja un cuadrado blanco y una linea que divide el area de trabajo de las herramientas y colores
mov ac,0d
dibLinea 10,10,610,420
dibLinea 610,30,630,420  
mov ac,15d
dibLinea 0,maxY, maxX,  maxY+1
dibLinea 20,20,60,60 
;Se dibuja un cuadrado que indica el espacio que ocupa el boton de salida
;mov ac,4d
;dibLinea 610,00,640,30
mov ac, 15d
dibColores
;;dibmods

eti1:
;;revisa si hay entrada de teclado o raton
get_input

cmp al, 1Bh     ;;Esc = exit
je eti2
;se revisa el estado del raton y se apaga
cmp bx,1
jne eti1
call apaga
;revisa si de dio click en algun color y cambia el color de ser asi
cmp col,coloresX
jb etiSelecP
cmp col,coloresX+160
ja etiSelecP
cmp ren,coloresY
jb etiSelecP
cmp ren,coloresY+20
ja etiSelecP
clickColor
;boton de salir
etiSelecP:
cmp col,610
jb etitool
cmp ren, 30
ja etitool
jmp eti2
;Revisa si se dio click en alguna herramienta y cambia la herramienta de ser asi
etitool:
cmp col,380
jb etidraw
cmp col,480
ja etidraw
cmp ren,440
jb etidraw
cmp ren,460
ja etidraw
cmpstuff


;Realiza acciones dependiendo del pincel seleccionado

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



;Prende el raton y se cicla
etireset:
call prende
jmp eti1


eti2:
;;call ftsamout
call apaga
call cierragraf

int 20h

;;;;;;;;;;;;;;;;;;;;;;


;Dibuja pixeles en las coordenadas especificadas
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
;Despliega las coordenadas del cursor
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
;Posicion de columna
posC proc
mov ah,02h
mov dl,65d
mov dh,29d
mov bh,0h
int 10h
ret

endp
;Posicion de renglon
posR proc
mov ah,02h
mov dl,70d
mov dh,29d
mov bh,0h
int 10h
ret
endp
;Enciende raton
prende proc
mov ax,1d
int 33h
ret
endp
;apaga raton
apaga proc
mov ax,2d
int 33h
ret
endp
;inicia modo grafico
inigraf proc
mov ah,0d
mov al,18d
int 10h
ret
endp              
;cierra modo grafico
cierragraf proc
mov ah,0d
mov al,3d
int 10h
ret
endp
;Linea 666 pq es del diablo 