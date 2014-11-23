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

;los siguientes son permisos de escritura y lectura de archivos
%assign S_IRUSR 00400q
%assign S_IWUSR 00200q

; La siguiente parte de código son datos no inicializados
section .bss

	buffer resb 100	
	
	inputLen equ 100		;buffer almacenador el string original del usuaro 
	input resb inputLen		;largo de este buffer
	
	archivoLen equ 1000000		;buffer almacenador el string original del usuaro 
	archivo resb archivoLen		;largo de este buffer
	
	cadenaLen equ 1000001		;buffer almacenador el string original del usuaro 
	cadena resb cadenaLen		;largo de este buffer
	

; La siguiente parte de código son datos inicializados
section .data

solicitarLen: db "Ingrese el tamanno de la secuencia de ADN: ",10		
LensolicitarLen: equ $-solicitarLen	

solicitarArchivo: db "Ingrese el nombre del archivo: ",10		
LensolicitarArchivo: equ $-solicitarArchivo	

espacio: db 10,10
espacioLen: equ $-espacio

errorMensj: db "Error al crear el archivo",10		
lenErrorMensj: equ $-errorMensj	

MensjExito: db "¡Archivo creado con exito!",10,10
lenMensjExito: equ $-MensjExito	


; La siguiente parte de código son las instrucciones
section .text
; inicio del codigo del programa
	global _start 
	
_start:
	nop								; mantiene feliz al debuger
		
	;esta parte imprime lineas en blanco para aspectos esteticos
	mov ecx, espacio
	mov edx, espacioLen
	call DisplayText
	;solicito el nombre del archivo que vamos a generar
	mov ecx, solicitarArchivo
	mov edx, LensolicitarArchivo
	call DisplayText				;imprio el mensaje al usuario
	mov edx, archivoLen				
	mov ecx, archivo 				
	call ReadText					;recivo el mensaje del usuario
	
	mov ecx, eax					;muevo al ecx la cantidad de digitos leidos
	dec ecx							;decremento el ecx
	mov bl, "."						;muevo al bl un caracter "." 
	mov byte[archivo+ecx],bl		;paso al buffer el "."
	mov bl, "a"						;muevo al bl un caracter "a" 
	mov byte[archivo+eax], bl		;paso al buffer el "."
	inc eax							;incremento el puntero
	mov bl, "d"						;muevo al bl un caracter "d" 
	mov byte[archivo+eax], bl		;paso al buffer el "d"
	inc eax							;incremento el puntero
	mov bl, "n"						;muevo al bl un caracter "n" 
	mov byte[archivo+eax], bl		;paso al buffer el "n"
	inc eax							;incremento el puntero
	mov bl, 0h						;muevo al bl un caracter null
	mov byte[archivo+eax], bl		;paso al buffer el null
	;esta parte imprime lineas en blanco para aspectos esteticos
	mov ecx, espacio
	mov edx, espacioLen
	call DisplayText
	;solicito el largo de la cadena de ADN
	mov ecx, solicitarLen
	mov edx, LensolicitarLen
	call DisplayText				;imprimo el mensaje al usuario
	mov edx, inputLen				;muevo al edx el largo del mensaje
	mov ecx, input					;muevo al ecx el puntero del mesaje
	call ReadText					;llamo a la rutina que me genera un CIN
	push eax						;salvo en pila el largo del mensaje
	
	lea esi, [input]				;inicializo para poder llamar al STR TO INT
	pop ecx							;muevo al ecx el largo del mensaje
	dec ecx							;le resto 1 (el largo incluye el ENTER)
	call string_to_int				;llamo a la subrutina de STR TO INT
	push eax						;salvo en la pila el int de la cantidad de digitos (*)
	mov ebx, eax					;muevo la cantidad de digitos al ebx
	push ebx						;la vuelvo a salvar
	xor eax, eax					;limpio el eax
	push eax						;salvo un 0 en la pila
	;;;;;;;;;;;;;;;;;;;;;
; funcion que genera un numero random entre 0 y 3
; donde tomaremos la info para generar este diccionario
; eax = {0:"A" , 1:"C", 2:"T", 3:"G"}
generar_random: 
	xor eax, eax						
	RDTSC				; \ estas 2 lineas me dejan el el eax un numero random entre 0 y 255 - Tomado de :
	and eax, 0FFH		; / http://stackoverflow.com/questions/17182182/how-to-create-random-number-in-nasm-getting-system-time
	mov ebx, 4			; muevo al ebx un 4 
	xor edx, edx		; limpio el edx para aplicar modulo
	div ebx				; divido (modulo) entre 4
	mov eax, edx		; paso el resultado random(0, 1, 2, 3) al eax

	cmp eax, 0			;aca en caso de que el random sea 0 es adenina, 1 es citocina, 
	je adenina			;2 es timina y 3 es guanina
	cmp eax, 1
	je citocina
	cmp eax, 2
	je timina
	jmp guanina

;cada una de las sgts subrutinas insertan su caracter correspondiante en un buffer para
;luego ser impresos en el archivo.adn
adenina:
	pop edx							;saco el puntero del buffer
	pop ecx							;saco el largo de la cadena de adn
	mov bl, "A"						;en el bl queda el caracter
	mov byte[cadena+edx], bl		;muevo al buffer el caracter dedicado a esta funcion
	inc edx							;incremento el puntero de buffer
	dec ecx							;decremento el largo de la cadena de adn
	push ecx						;guardo el largo de la cadenaLen	
	push edx						;guerdo el puntero del buffer
	cmp ecx, 0						;me fijo si no tengo mas elementos que insertar	
	jne generar_random				;si aun tengo elementos, vuelvo a generar random
	jmp insertar					;si ya los tengo todos, los paso a insertar
	
citocina:
	pop edx							;saco el puntero del buffer
	pop ecx							;saco el largo de la cadena de adn
	mov bl, "C"						;en el bl queda el caracter
	mov byte[cadena+edx], bl		;muevo al buffer el caracter dedicado a esta funcion
	inc edx							;incremento el puntero de buffer
	dec ecx							;decremento el largo de la cadena de adn
	push ecx						;guardo el largo de la cadenaLen	
	push edx						;guerdo el puntero del buffer
	cmp ecx, 0						;me fijo si no tengo mas elementos que insertar	
	jne generar_random				;si aun tengo elementos, vuelvo a generar random
	jmp insertar					;si ya los tengo todos, los paso a insertar
	
timina:
	pop edx							;saco el puntero del buffer
	pop ecx							;saco el largo de la cadena de adn
	mov bl, "T"						;en el bl queda el caracter
	mov byte[cadena+edx], bl		;muevo al buffer el caracter dedicado a esta funcion
	inc edx							;incremento el puntero de buffer
	dec ecx							;decremento el largo de la cadena de adn
	push ecx						;guardo el largo de la cadenaLen	
	push edx						;guerdo el puntero del buffer
	cmp ecx, 0						;me fijo si no tengo mas elementos que insertar	
	jne generar_random				;si aun tengo elementos, vuelvo a generar random
	jmp insertar					;si ya los tengo todos, los paso a insertar
	
guanina:
	pop edx							;saco el puntero del buffer
	pop ecx							;saco el largo de la cadena de adn
	mov bl, "G"						;en el bl queda el caracter
	mov byte[cadena+edx], bl		;muevo al buffer el caracter dedicado a esta funcion
	inc edx							;incremento el puntero de buffer
	dec ecx							;decremento el largo de la cadena de adn
	push ecx						;guardo el largo de la cadenaLen	
	push edx						;guerdo el puntero del buffer
	cmp ecx, 0						;me fijo si no tengo mas elementos que insertar	
	jne generar_random				;si aun tengo elementos, vuelvo a generar random
	jmp insertar					;si ya los tengo todos, los paso a insertar
	
	
insertar:
	pop edx							;\ limpio la pila
	pop eax							;/

	mov	eax, sys_create				;llamada al sistema
	mov ebx, archivo				;puntero del nombre del programa
	mov ecx, S_IRUSR|S_IWUSR		;otorgo permisos de escritura y lectura
	xor edx, edx					;limpio el edx
	int	80h							;llamada al sistema
	test eax,eax					;pregunto si cree bien el archivo
	js error						;si lo creo mal, paso a notificarlo
		
	pop edx							;retorno el INT del largo de la cadena de archivo (*)
	push eax						;salvo el file descriptor
	
	mov ebx, eax					;muevo al bx, el file descriptor
	mov eax, sys_write				;muevo al eax la funcion de escribir del sys
	mov ecx, cadena					;muevo al ecx el puntero a la cadena de adn generada anteriormente
	int 80h							;llamada del sistema
	
	mov eax, sys_close				;solamente se llama a la llamada del sistema sys_close
	pop ebx							;retirno el file descriptor
	int 80h							;llada al sistema
	
	;esta parte imprime lineas en blanco para aspectos esteticos
	mov ecx, espacio
	mov edx, espacioLen
	call DisplayText
	;imprimo que se creo el archivo exitoxamente
	mov ecx, MensjExito
	mov edx, lenMensjExito
	call DisplayText
	;esta parte imprime lineas en blanco para aspectos esteticos
	mov ecx, espacio
	mov edx, espacioLen
	call DisplayText
	jmp Cerrar						;paso a cerrar el programa
	
;muestra en pantalla que ocurrio un error al crear el archivo
error:
	mov ecx, errorMensj
	mov edx, lenErrorMensj
	call DisplayText
	jmp Cerrar
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
	mov eax, sys_exit				;muevo la variabla sys_close al eax
	int 80h							;llamo a la interrupcion de kernel
