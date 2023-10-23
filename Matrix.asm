include macros.cbc     ; Incluye el archivo de macros predefinidas para el ensamblador.

SSeg Segment 
    pila db 0
         db 65535 dup (?)     
SSeg EndS

Datos Segment               ; Define un segmento llamado "Datos" para almacenar variables y datos.
    psp             dw 00,00
    COL             dw 160
    CHAR            dw 82
    CharFlag        db 1            ; valores entre 1,2,3,4
    ColFlag         db 1            ; valores entre 1,2,3
    GeneratedChars  db 40 DUP(0)    ; Reserva espacio para 40 caracteres generados
    GeneratedCols   db 40 DUP(0)    ; Reserva para el valor de todas las columnas generadas
    Columnas        dw 160, 164, 168, 172, 176, 180, 184, 188, 192, 196, 200, 204, 208, 212, 216, 220, 224, 227, 230, 234, 238, 242, 246, 250, 254, 258, 260, 264, 268, 272, 276, 278, 282, 286, 290, 294, 298, 302, 306, 310, 314, 318, 320
    Contador        db 0
Datos Ends                  ; Finaliza la definición del segmento "Datos".

Codigo Segment              ; Define un segmento llamado "Codigo" para el código ensamblador.
assume cs:Codigo, ds:Datos  ; Asocia los registros de segmento CS (código) y DS (datos) a los segmentos definidos.
    
Descender Proc Near  ; Antes de llamar a este proc se debe pasar al di la columna y a AL el char
    dec     di
    dec     di
    mov     es:[di],al      ; background
    inc     di
    mov     es:[di],0h      ; foreground
    inc     di

    add     di, 158

    mov     es:[di],al      ; background
    inc     di
    mov     es:[di],0ah     ; foreground
    inc     di 



    ret
Descender endP

Animar Proc Near
    cmp     ColFlag, 1
    je      Cflag1
    cmp     ColFlag, 2
    je      Cflag2
    cmp     ColFlag, 3
    je      Cflag3

  Cflag1:
    call    Descender
    mov     ColFlag,3
    jmp     fin
  Cflag2:
    mov     ColFlag,1
    jmp     fin
  Cflag3:
    call    Descender
    call    Descender
    mov     ColFlag,2
    jmp     fin
  fin:
    ret

Animar endP

RandChar Proc Near
    cmp     CharFlag, 1
    je      flag1
    cmp     CharFlag, 2
    je      flag2
    cmp     CharFlag, 3
    je      flag3
    cmp     CharFlag, 4
    je      flag4

  flag1:
    mov     dx, CHAR
    add     dx,15
    mov     CHAR, dx
    mov     CharFlag, 3
    jmp     salirProc
  flag2:
    mov     dx, CHAR
    add     dx,35
    mov     CHAR, dx
    mov     CharFlag, 1
    jmp     salirProc
  flag3:
    mov     dx, CHAR
    sub     dx,40
    mov     CHAR, dx
    mov     CharFlag, 4
    jmp     salirProc
  flag4:
    mov     dx, CHAR
    sub     dx,3
    mov     CHAR, dx
    mov     CharFlag, 2
    salirProc:
    mov     al, CharFlag  ; Usar si como índice para el arreglo GeneratedChars
    mov     si, ax
    mov     [GeneratedChars + si], al ; Almacena el nuevo valor en el arreglo
    ret

RandChar endP

inicio:
    mov     ax, Datos
    mov     ds,ax
    mov     psp,es

    mov     ax,0B800h
    mov     es,ax 
    mov     ah,3
    mov     cx,40           ; Cantidad de columnas en las que habrán caracteres
    mov     si,0            ; Índice para moverse entre los arreglos de las columnas y chars

for:
    mov     di, COL
    mov     al, byte ptr[CHAR]

    mov     es:[di],al      ; background
    inc     di
    mov     es:[di],0ah     ; foreground
    inc     di 

    ; Almacena el caracter generado
    call    RandChar

    mov     dx, COL
    add     dx, 4  ; Agrega el valor de la columna al desplazamiento
    mov     COL, dx

    inc     si

loop for

;    mov     COL,160
;
;Control:
;    mov     al, contador
;    inc     al
;    mov     contador, al
;
;    mov     si, 0 ; Reinicia el índice
;    mov     cx, 40 ; La cantidad de caracteres generados
;    Animation:
;        mov     al, [GeneratedChars + si]   ; Obtiene el carácter del arreglo
;        mov     di, COL  ; Valor de la columna
;        call    Animar ; Llama al procedimiento Descender
;        mov     dx, COL
;        add     dx, 4  ; Agrega el valor de la columna al desplazamiento
;        mov     COL, dx
;        inc     si ; Incrementa el índice
;
;    loop Animation
;
;    push    ax
;    mov     ah,01h
;    int     21h     ; Espera entrada del teclado
;    pop     ax
;
;    cmp contador, 25
;    jl  Control

    salir:                        ; Etiqueta de finalización del programa.
    mov ax, 4c00h           ; Prepara una llamada a la interrupción 21h para terminar el programa.
    int 21h                 ; Llama a la interrupción 21h para terminar el programa.

Codigo Ends                 ; Finaliza la definición del segmento "Codigo".
end inicio                  ; Finaliza el programa.