;include macros.cbc     ; Incluye el archivo de macros predefinidas para el ensamblador.

SSeg Segment 
    pila db 0
         db 65535 dup (?)     
SSeg EndS

Datos Segment               ; Define un segmento llamado "Datos" para almacenar variables y datos.
    psp             dw 00,00        ; variable 
    COL             dw 160
    ColFlag         db 1            ; valores entre 1,2,3
    GeneratedChars  db 40 DUP(0)    ; Reserva espacio para 40 caracteres generados
    Contador        db 0
Datos Ends                  ; Finaliza la definición del segmento "Datos".

Codigo Segment              ; Define un segmento llamado "Codigo" para el código ensamblador.
assume cs:Codigo, ds:Datos  ; Asocia los registros de segmento CS (código) y DS (datos) a los segmentos definidos.
    
  Descender Proc Near  ; Antes de llamar a este proc se debe pasar al di la columna y a AL el char

      dec     di              ; Se devuelve para cambiar el caracter actual
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
      cmp     ColFlag, 1    ; Comparar caso 1
      je      Cflag1
      cmp     ColFlag, 2    ; Comparar caso 2
      je      Cflag2
      cmp     ColFlag, 3    ; Comparar caso 3
      je      Cflag3

    Cflag1:
      call    Descender
      mov     ColFlag,3     ; Cambio de caso
      jmp     fin
    Cflag2:
      call    Descender
      call    Descender
      call    Descender
      mov     ColFlag,1     ; Cambio de caso
      jmp     fin
    Cflag3:
      call    Descender
      call    Descender
      mov     ColFlag,2     ; Cambio de caso
      jmp     fin
    fin:
      ret
  Animar endP

  GenerarRandom Proc Near
        mov ah, 00h        ; Función 0 - Generar número pseudoaleatorio
        int 1Ah            ; Llama a la interrupción 1Ah para generar un número pseudoaleatorio
        ret
  GenerarRandom endP

  Pausa Proc Near
    mov ah, 86h        ; Función 86h - Esperar un número de milisegundos
    int 15h            ; Llama a la interrupción 15h para pausar
    ret
 Pausa endP

inicio:
    mov     ax, Datos
    mov     ds,ax
    mov     psp,es

    mov     ax,0B800h       ; Posición en memoria de la memoria de video
    mov     es,ax 
    mov     ah,3
   
    mov     si,0            ; Índice para moverse entre los arreglos de las columnas y char
    mov     cx,40           ; Cantidad de columnas en las que habrán caracteres
    
for:

    mov     di, COL

    push    cx              ;Conservar cx para el loop
    call    GenerarRandom   ;Generar caracter aleatorio
    pop     cx
    mov     al, dl          ;Mover el caracter al AL para colocarlo en pantalla

    mov     es:[di],al      ; background
    inc     di
    mov     es:[di],0ah     ; foreground
    inc     di 

    mov     [GeneratedChars+si], al ; Almacena el nuevo valor en el arreglo

    mov     dx, COL
    add     dx, 4           ; Agrega el valor de la columna al desplazamiento
    mov     COL, dx
    inc     si
    
    push cx
    mov cx, 1               ; Ajustar el valor de cx para 2 décimas de segundos por iteracion
    call    Pausa           ; Se ejecuta una pausa en la ejecución
    pop cx

  loop for

    mov     COL,160

Control:
    mov     al, contador
    inc     al
    mov     contador, al      ; Se incrementa el contador

    mov     si, 0         ; Reinicia el índice
    mov     cx, 40        ; La cantidad de caracteres generados
    Animation:
        mov     al, [GeneratedChars + si]   ; Obtiene el carácter del arreglo
        mov     di, COL   ; Valor de la columna
        call    Animar    ; Llama al procedimiento Descender

        mov     dx, COL
        add     dx, 4     ; Agrega el valor de la columna al desplazamiento
        mov     COL, dx

        inc     si        ; Incrementa el índice
    loop Animation

    push cx
    mov cx, 10            ; Ajustar el valor de cx según la velocidad de 1 segundo por iteración
    call    Pausa
    pop cx

    cmp contador, 20
    jl  Control

    salir:                  ; Etiqueta de finalización del programa.
    mov ax, 4c00h           ; Prepara una llamada a la interrupción 21h para terminar el programa.
    int 21h                 ; Llama a la interrupción 21h para terminar el programa.

Codigo Ends                 ; Finaliza la definición del segmento "Codigo".
end inicio                  ; Finaliza el programa.