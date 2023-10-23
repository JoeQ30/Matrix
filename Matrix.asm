include macros.cbc     ; Incluye el archivo de macros predefinidas para el ensamblador.

SSeg Segment 
    pila db 0
         db 65535 dup (?)     
SSeg EndS

Datos Segment               ; Define un segmento llamado "Datos" para almacenar variables y datos.
    char    dw "R"
    psp     dw 00,00

Datos Ends                  ; Finaliza la definición del segmento "Datos".

; Código de los colores
;Azul           equ 1
;Verde          equ 2
;Cian           equ 3
;Rojo           equ 4
;Magenta        equ 5
;Cafe           equ 6
;Gris           equ 7
;Gris Oscuro    equ 8
;Azul Claro     equ 9
;Verde Claro    equ 0ah
;Cian Claro     equ 0bh
;Rojo Claro     equ 0ch
;Magenta Claro  equ 0dh
;Amarillo       equ 0eh
;Blanco         equ 0fh

Codigo Segment              ; Define un segmento llamado "Codigo" para el código ensamblador.
assume cs:Codigo, ds:Datos  ; Asocia los registros de segmento CS (código) y DS (datos) a los segmentos definidos.
    ReadChar Proc Far
        mov ah,01h
        int 21h
        mov bp,sp
        mov [bp+4],al
        retf
    ReadChar endP

inicio:
    mov     ax, Datos
    mov     ds,ax
    mov     psp,es

    mov     ax,0B800h
    mov     es,ax 
    mov     ah,3
    mov     cx,21
    mov     di,160

    mov     al, RandomChar ;LINEA DE PRUEBA CAMBIAR SI NO

animation:
    ;lodsb
    cmp     cx, 21
    je      first

    dec     di
    dec     di
    mov     es:[di],al      ;foreground
    inc     di
    mov     es:[di],0h      ;background
    inc     di

    add     di, 158

  first:
    mov     es:[di],al      ;foreground
    inc     di
    mov     es:[di],0ah     ;background
    inc     di 

    push    ax
    mov     ah,01h
    int     21h
    pop     ax

loop animation

RandomChar Proc Near ;;;;;;;;;FUNCION A PROBAR
; Genera un número aleatorio y lo convierte a un carácter ASCII
    push    ax
    push    bx
    push    cx
    push    dx
    push    si
    push    di
    push    bp

    mov     ax, 40h         ; Carga el valor 40h en el registro AX.
    mov     es, ax          ; Carga el valor de AX en el registro de segmento ES.
    mov     bx, 6Ch         ; Carga el valor 6Ch en el registro BX.
    mov     ax, es:[bx]     ; Carga el valor de la dirección de memoria ES:6Ch en el registro AX.
    mov     dx, es:[bx+2]   ; Carga el valor de la dirección de memoria ES:6Eh en el registro DX.
    mov     ax, dx          ; Carga el valor de DX en el registro AX.
    mov     dx, 25173       ; Carga el valor 25173 en el registro DX.
    mul     dx              ; Multiplica los valores de AX y DX y almacena el resultado en DX:AX.
    add     ax, 13849       ; Suma el valor 13849 al valor de AX y almacena el resultado en AX.
    mov     dx, 65521       ; Carga el valor 65521 en el registro DX.
    div     dx              ; Divide los valores de DX:AX entre DX y almacena el cociente en AX y el residuo en DX.
    mov     RandomChar, al  ; Carga el valor de AX en la variable RandomChar.

    pop     bp
    pop     di
    pop     si
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    ret
RandomChar endP

salir:                        ; Etiqueta de finalización del programa.
    mov ax, 4c00h           ; Prepara una llamada a la interrupción 21h para terminar el programa.
    int 21h                 ; Llama a la interrupción 21h para terminar el programa.

Codigo Ends                 ; Finaliza la definición del segmento "Codigo".
end inicio                  ; Finaliza el programa.