        format MZ
        stack stk:256
        entry codeseg:main
        macro ryslinia xx0,yy0,xx1,yy1
{

   mov [x0],xx0
   mov [y0],yy0
   mov [x1],xx1
   mov [y1],yy1
   call bresenham


}

macro  mPutPixel x,y,col
{
   push ax
   push bx
   push cx
   push dx
   mov bh,0
   mov cx,[x]   ;pozycja x
   mov dx,[y]   ;pozycja y
   mov al,[col]
   mov ah,0Ch   ;putpixel
   int 10h   
   pop dx
   pop cx
   pop bx
   pop ax
                    }


        ;-------------------Segment danych---------------
segment sdat use16
x0  dw 4
y0  dw 4
x1  dw 9
y1  dw 6
kx  dw ?
ky  dw ?
ddx  dw ?
dy  dw ?
x  dw ?
y  dw ?
d  dw ?
n  dw ?
ne dw ?
xPierwsze dw 0h
yPierwsze dw 0h
xDrugie dw 0h
yDrugie dw 0h
kolor db 0Ch
oldposx  dw 0h
oldposy  dw 0h
oldcolor db 0h
;----------------Koniec segmentu danych---------
        segment stk use16
        db 256 dup(?)

        segment codeseg use16
        main:

        start:
        ;Tryb graficzny
        mov     ax,12h
        int     10h
        mysz:
        ;Inicjalizacja myszki
     ;   xor     ax,ax
        int     00h


        mloop:
        ;Kursor myszy
        mov     ax,0001h
        int     33h

       mov     ax,0003h
        int     33h
        shr     cx,0h ; mov ax,13h

        cmp     bx,1h ;  lewy klikniêty
        je      lewa

        cmp     bx,2h ;y prawy klikniety
        je      prawa
        jmp update


        lewa:
        mov [xPierwsze],cx
        mov [yPierwsze],dx

        jmp     update

        prawa:

       mov ax,[xPierwsze]
        mov bx,[yPierwsze]
        ryslinia ax,bx,cx,dx

        update:

        ;Ustawienie pixeli na wczesniejszej pozycji
        push    cx
        push    dx
        shr     dx,3
        shr     dx,3
        mov     cx,[oldposx]
        mov     dx,[oldposy]
        pop     dx
        pop     cx

        ;Zapis rzeczywistej pozycji myszy

        mov     [oldposx],cx
        mov     [oldposy],dx
        ;Zapis pixela na aktualnej pozycji
        mov     ah,0Dh
        int     10h
        mov     [oldcolor],01h

        ;Sprawdzenie czy klawisz wcisniety
        mov     ah,1h
        int     16h
        jz      mloop

        ; set text video mode
        mov     ax,3h
        int     10h

        ; return to operating system
        int     20h
        ret
              bresenham:
 push ax
 push bx
 push cx
 push dx

 mov [kx],1
 mov [ky],1
 mov ax,[y0]
 mov [y],ax
 mov ax, [x0]
 mov [x],ax
 mov ax, [y1]
 sub ax,[y0]    ;ddy=y1-y0
 jns y_dodatnie     ; jezeli y1>y0
 mov [ky],-1
 neg ax         ; |ddy|
 y_dodatnie:
 mov [dy],ax
 mov ax,[x1]
 sub ax,[x0]   ;ddx=x1-x0
 jnz kat   ;jesli ddx != 0 to znaczy ze linia przesuwa sie po osi x
 mov cx,[dy]
 inc cx
 mov [kolor],0Fh
rys1:
 mPutPixel x,y,kolor
 mov ax,[y]
 add ax,[ky]
 mov [y], ax
 loop rys1
 jmp koniec
kat:
 jns x_plus ;jesli ddx>0
 mov [kx],-1
 neg ax ;
x_plus:
 mov [ddx],ax
 cmp [dy],0       ;;czy linia jest pozioma
 jne sprawdzenie_kata  ; jesli nie rowne
 mov cx,[ddx]
 inc cx
 mov [kolor],0Fh
rys2:
 mPutPixel x,y,kolor
 mov ax,[x]
 add ax,[kx]
 mov [x],ax
 loop rys2
 jmp koniec
sprawdzenie_kata:
 cmp [dy],ax
 jle kat45 ; jesli mniejsze badz rowne to kat maksymalny to 45 stopni
wart_pom:
 sal ax,1 ;2*dx
 mov [n],ax
 sub ax,[dy] ;d=2*dx-dy
 mov [d],ax
 mov bx,[dy]
 sal bx,1 ;2*dy
 sub ax,bx ;2*(dx-dy)
 mov[ne],ax
 mov cx,[dy]
 inc cx
 mov [kolor],0Fh
punkty:
 mPutPixel x,y,kolor
  cmp [d],0
     js  tu1y     ;d<0 tu1y
     call zmiana_NE
     jmp spry
tu1y: mov ax,[d]
     add ax,[n]
     mov [d],ax
     mov ax,[y]
     add ax,[ky]
     mov [y],ax
spry: loop punkty
     jmp koniec
kat45:
;wyliczanie wartoœci pomocniczych
     mov  ax,[dy]
     sal  ax,1   ;2*ddy
     mov [n],ax  ;N=2*ddy
     sub ax,[ddx] ;d=2*ddy-ddx
     mov [d],ax
     mov ax,[n]
     mov bx,[ddx]
     sal bx,1     ;2*ddx
     sub ax,bx
     mov [ne],ax   ; NE=2*ddy-2*ddx=N-2*ddx
     mov cx,[ddx]
     inc cx
     mov [kolor],0Fh
     jmp punktx

punktx: mPutPixel x,y,kolor 
;punktx: call AA
     cmp [d],0
     js tu1x
     call zmiana_NE
     jmp sprx
tu1x: mov ax,[d]
     add ax,[n]    ;d=d+2*ddy
     mov [d],ax
     mov ax,[x]
     add ax,[kx]
     mov [x],ax
sprx:dec cx
     jnz punktx
koniec:
     mov [kolor],0Fh
    pop   dx
    pop   cx
    pop   bx
    pop   ax
   ret


;---------------------------------------------------
zmiana_NE:
    mov ax,[d]
    add ax, [ne]  ; d=d+2*ddy-2*ddx
    mov [d],ax
    mov ax,[x]
    add ax,[kx]
    mov [x],ax
    mov ax,[y]
    add ax,[ky]
    mov [y],ax
   ret

