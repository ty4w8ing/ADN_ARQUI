; Proyecto #2 de arquitectura de computadores
;
;	
;
; ---------------------------------------------------------------------------------------------------------------------------
;  Este proyecto genera una cadena de ADN definida por el usuario y esta es salvada
;  en un archivo tipo .adn
; ---------------------------------------------------------------------------------------------------------------------------

; La siguiente parte de código son tags para hacer más legible el código
	sys_exit 	equ 	1
	sys_read 	equ 	3
	sys_write 	equ 	4
	sys_open 	equ 	5	
	sys_close 	equ 	6
	sys_create 	equ 	8
	stdin 		equ		0
	stdout 		equ 	1

; La siguiente parte de código son datos no inicializados
section .bss
	buffer resb 100	
	
	LenMatriz equ 1000000
	matriz resb LenMatriz
	
	lenInput1 equ 35
	input1 resb lenInput1
	
	lenInput2 equ 35
	input2 resb lenInput2
	
	LenArchivo_1 equ 1000000
	archivo_1 resb LenArchivo_1
	
	LenArchivo_2 equ 1000000
	archivo_2 resb LenArchivo_2
	
	LenActual_1 equ 1
	actual_1 resb LenActual_1
	
	LenActual_2 equ 1
	actual_2 resb LenActual_2
	
	LenArgumento1 equ 20
	argumento1 resb LenArgumento1
	
	LenArgumento2 equ 20
	argumento2 resb LenArgumento2
	
	LenArgumento3 equ 20
	argumento3 resb LenArgumento3

	

; La siguiente parte de código son datos inicializados
section .data

espacio: db " | "
enter: db 10

mnsj1: db "Introduzca el nombre del primer documento (incluyendo la extension):",10
lenmnsj1: equ $-mnsj1

mnsj2: db "Introduzca el nombre del segundo documento (incluyendo la extension):",10
lenmnsj2: equ $-mnsj2

errorMensj: db "Error al abrir el archivo",10,10
lenErrorMensj: equ $-errorMensj

; La siguiente parte de código son las instrucciones
section .text
; inicio del codigo del programa
	global _start 
	
_start:
	nop		
	
Preguntar_Nombre_1:
	mov ecx, mnsj1
	mov edx, lenmnsj1
	call DisplayText
	
	mov ecx, input1
	mov edx, lenInput1
	call ReadText
	dec eax
	mov byte[input1+eax],0h

.Abrir_archivo_1:	
	mov eax, sys_open
	mov ebx, input1
	mov ecx, 2
	int 80h
	push eax
	test eax, eax 					; primero nos aseguramos que abrio bien
	js	error						; no es asi? imprime mensaje de error
	mov	ebx, eax					; paso al ebx el FD
	mov	ecx, archivo_1				; paso el puntero del buffer con el archivo
	mov	edx, LenArchivo_1			; y su len correspondiente
	mov	eax, sys_read				; y llamo a read de dicho archivo
	int 80h		
	pop ebx
	push eax						;salvo la cantidad de digitos
	mov eax, sys_close
	int 80h
	
Preguntar_Nombre_2:	
	mov ecx, mnsj2
	mov edx, lenmnsj2
	call DisplayText
	
	mov ecx, input2
	mov edx, lenInput2
	call ReadText
	dec eax
	mov byte[input2+eax],0h

.Abrir_archivo_2:
	mov eax, sys_open
	mov ebx, input2
	mov ecx, 2
	int 80h
	push eax
	test eax, eax 					; primero nos aseguramos que abrio bien
	js	error						; no es asi? imprime mensaje de error
	mov	ebx, eax					; paso al ebx el FD
	mov	ecx, archivo_2				; paso el puntero del buffer con el archivo
	mov	edx, LenArchivo_2			; y su len correspondiente
	mov	eax, sys_read				; y llamo a read de dicho archivo
	int 80h		
	pop ebx
	push eax						;salvo la cantidad de digitos
	mov eax, sys_close
	int 80h
		
llenar_ceros_fila:
	pop eax
	pop edx
	push edx
	push eax
	mov ecx, 0
.ciclo:
	mov byte[matriz+ecx], 0
	inc ecx
	cmp ecx, edx
	jne .ciclo
	pop ebx
	pop eax
	push eax
	push ebx
	xor edx, edx
	mul ebx
	mov edx, eax
	
llenar_basura:
	mov byte[matriz+ecx], "1"
	inc ecx
	cmp ecx, edx
	jne llenar_basura
	pop eax
	pop ecx
	push ecx
	push eax
	mov eax, ecx

llenar_ceros_col:
	mov byte[matriz+ecx], 0
	add ecx, eax
	cmp ecx, edx
	jne llenar_ceros_col
	
	pop eax
	pop ecx
	push ecx
	push eax
	inc ecx
	
Ciclo_Principal:
.ArribaIzq:
	mov eax, ecx
	dec eax
	pop edx
	pop ebx
	push ebx
	push edx
	xor edx, edx
	div ebx
	dec eax
	pusha
	xor edx, edx
	mov bl, byte[archivo_1+eax]
	mov byte[actual_1+edx], bl
	popa
	mov edx, eax
	inc eax
	mul ebx
	mov ebx, eax
	mov eax, ecx
	sub eax, ebx
	dec eax
	pusha
	xor edx, edx
	mov bl, byte[archivo_2+eax]
	mov byte[actual_2+edx], bl
	popa
	xor edx, edx
	mov bl, byte[actual_1+edx]
	mov bh, byte[actual_2+edx]
	call match
	mov [argumento1+edx], eax
	pop edx
	pop ebx
	push ebx
	push edx
	xor edx, edx
	inc ebx
	mov eax, ecx
	sub eax, ebx
	mov bl, byte[matriz+eax]
	mov eax, ebx
	add eax, [argumento1+edx]
	mov [argumento1+edx], eax

.Izquierda:
	mov eax, ecx
	dec eax
	mov bl, byte[matriz+eax]
	mov eax, ebx
	dec eax								;gab
	mov [argumento2+edx], eax

.Arriba:
	xor edx, edx
	mov eax, ecx
	pop edx
	pop ebx
	push ebx
	push edx
	sub eax, ebx
	mov bl, byte[matriz+eax]
	mov eax, ebx
	dec eax								;gab
	mov [argumento3+edx], eax
	mov edx, eax

.InsertarNuevoValor:
	push ecx
	mov eax, 0
	mov ebx, [argumento1+eax]
	mov ecx, [argumento2+eax]
	call maxNumber
	pop ecx
	mov byte[matriz+ecx],al
	
	
.verificar_fin:
	pop eax
	pop ebx
	push ebx
	push eax
	mul ebx
	dec eax
	cmp eax, ecx
	je imprime_res

.verificar_fin_linea:
	mov eax, ecx
	inc eax
	pop edx
	pop ebx
	push ebx
	push edx
	xor edx, edx
	div ebx
	cmp edx, 0
	jne .NoEsFin
	inc ecx
	inc ecx
	jmp Ciclo_Principal
.NoEsFin:
	inc ecx
	jmp Ciclo_Principal
	
imprime_res:
	pop eax
	pop ebx
	mov ecx, ebx
	mul ebx
	dec eax
	mov ebx, ecx
	dec ebx
	xor ecx, ecx
	xor edx, edx

.ciclo:
	pusha
	mov dl, byte[matriz+ecx]
	mov eax, edx
	lea esi,[buffer]
	call int_to_string
	mov ecx, eax
	mov edx, 7
	call DisplayText
	popa
	pusha
	xor edx, edx
	mov eax, ecx
	inc eax
	inc ebx
	div ebx
	cmp edx, 0
	jne .printLinea
	popa
	pusha
	mov ecx, enter
	mov edx, 1
	call DisplayText
	popa
	jmp .verFin
	
.printLinea:
	popa
	pusha
	mov ecx, espacio
	mov edx, 3
	call DisplayText
	popa

.verFin:
	cmp eax, ecx
	je Cerrar
	inc ecx
	jmp .ciclo
	
;Funcion que permite saber el numero mayor entre 4 numeros
;ocupa las 4 numeros en los 4 registros principales
;				eax-ebx-ecx-edx
maxNumber:
	cmp eax, ebx			;compara el eax con ebx
	jl .ebx_mayor_eax		;ebx es mayor
	jg .eax_mayor_ebx		;eax es mayor
	
.ebx_mayor_eax:				;comparo ebx con ecx
	cmp ebx, ecx			;ecx es mayor
	jl .ecx_mayor_ebx		;ebx es mayor
	jg .ebx_mayor_ecx
	
.eax_mayor_ebx:				;comparo eax con ecx
	cmp eax, ecx			;ecx mayor eax
	jl .ecx_mayor_eax		;eax mayor a ecx
	jg .eax_mayor_ecx
	
.eax_mayor_ecx:				
	cmp eax, edx			;comparo eax con edx
	jl .edx_mayor_eax		;edx es mayor
	jg .eax_mayor_edx		;eax es mayor

.ebx_mayor_ecx:
	cmp ebx, edx			;comparo ebx con edx
	jl .edx_mayor_ebx		;edx es mayor
	jg .ebx_mayor_edx		;ebx es mayor
	
.ecx_mayor_eax:
	cmp ecx, edx			;comparo ecx con edx
	jl .edx_mayor_ecx		;edx es mayor
	jg .ecx_mayor_edx		;exc es mayor
	
.ecx_mayor_ebx:
	cmp ecx, edx			;comparo el ecx con el edx
	jl .edx_mayor_ecx		;edx es mayor
	jg .ecx_mayor_edx		;ecx es mayor

;en todas estas etiquetas paso el valor mayor al eax y paso a finalizar el procedimiento
.edx_mayor_eax:
	mov eax, edx
	jmp .mayor
.eax_mayor_edx:
	jmp .mayor
.edx_mayor_ebx:
	mov eax, edx
	jmp .mayor
.ebx_mayor_edx:
	mov eax, ebx
	jmp .mayor
.edx_mayor_ecx:
	mov eax, edx
	jmp .mayor
.ecx_mayor_edx:
	mov eax, ecx
	jmp .mayor
;salgo del procedimiento
.mayor:

		;pusha
	;lea esi,[buffer]
	;call int_to_string
	;mov ecx, eax
	;mov edx, 7
	;call DisplayText
	;mov ecx, enter
	;mov edx, 1
	;call DisplayText
	;popa
	
	ret


;muestra en pantalla que ocurrio un error al abrir el archivo
error:
	mov ecx, errorMensj
	mov edx, lenErrorMensj
	call DisplayText
	jmp Cerrar
;esta funcion recibe en el bl y cl 2 argumentos y devuelve en el eax 1 si hay match y -1 si no hay match
match:
	cmp bl, bh			;comparo el bl con el cl
	je .si				;si es igual voy a si
	jne .no				;si no es igual voy a no
	
.si:				
	mov eax, 1			;muevo al eax un 1
	jmp .sale			;brinco a salir
.no:
	mov eax, 0			;muevo al eax un cero
	dec eax				;decremento el eax
.sale:
	ret					;retorno
; La siguiente subrutina llama el kernel y muetra un mensaje en pantalla.
; desplega algo en la salida estándar. debe "setearse" lo siguiente:
; ecx: el puntero al mensaje a desplegar
; edx: el largo del mensaje a desplegar
; modifica los registros eax y ebx.
DisplayText:
    mov     eax, sys_write
    mov     ebx, stdout
    int     80h 
    ret

; lee algo de la entrada estándar.debe "setearse" lo siguiente:
; ecx: el puntero al buffer donde se almacenará
; edx: el largo del mensaje a leer
ReadText:
    mov ebx, stdin
    mov eax, sys_read
    int 80H
    ret
;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////   
;http://stackoverflow.com/questions/19309749/nasm-assembly-convert-input-to-integer
;Input:
; EAX = integer value to convert
; ESI = pointer to buffer to store the string in (must have room for at least 10 bytes)
; Output:
; EAX = pointer to the first character of the generated string
int_to_string:
	push esi
	add esi,9
	mov byte [esi],0
	mov ebx,10         
.next_digit:
	xor edx,edx         ; Clear edx prior to dividing edx:eax by ebx
	div ebx             ; eax /= 10
	add dl,'0'          ; Convert the remainder to ASCII 
	dec esi             ; store characters in reverse order
	mov [esi],dl
	test eax,eax            
	jnz .next_digit     ; Repeat until eax==0
	mov eax,esi
	pop esi
	ret
; Input:
; ESI = pointer to the string to convert
; ECX = number of digits in the string (must be > 0)
; Output:
; EAX = integer value
string_to_int:
  xor ebx,ebx    ; clear ebx
.next_digit:
  movzx eax,byte[esi]
  inc esi
  sub al,'0'    ; convert from ASCII to number
  imul ebx,10
  add ebx,eax   ; ebx = ebx*10 + eax
  loop .next_digit  ; while (--ecx)
  mov eax,ebx
  ret
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; La siguiente subrutina cierra el programa
Cerrar:
	mov edx,1
	mov ecx, enter
	call DisplayText
	mov eax, sys_exit				;muevo la variabla sys_close al eax
	int 80h							;llamo a la interrupcion de kernel
