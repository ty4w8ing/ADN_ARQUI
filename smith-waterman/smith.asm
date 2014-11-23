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
	
; La siguiente parte de código son datos inicializados
section .data

espacio: db " | "
espacio2: db "| "
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
	
;pregunto el primer nombre del archivo	
Preguntar_Nombre_1:
	mov ecx, mnsj1					;muevo al ecx el mensaje al usuario
	mov edx, lenmnsj1				;muevo al edx el largo
	call DisplayText				;llamo al procedimiento de imprimir en pantalla
	;leo de usuario un texto
	mov ecx, input1					;muevo al ecx el puntero del buffer de almacenamiento
	mov edx, lenInput1				;muevo la catidad de caracteres maxima q puedo tener
	call ReadText					;llamo al procedimiento de recibir de teclado
	dec eax							;en el eax tengo el largo del mensaje, lo decremento
	mov byte[input1+eax],0h			;cambio el ultimo caracter (enter) por un null
	;abro el archivo con el nombre que el usuaro me dio
.Abrir_archivo_1:			
	mov eax, sys_open				;muevo al eax la directiva de abrir archivo
	mov ebx, input1					;muevo al ebx el nombre de lo que quiero abrir
	mov ecx, 2						;muevo permisos que tendra el archivo
	int 80h							;interrupcion del sistema
	push eax						;salvo el FD
	test eax, eax 					; primero nos aseguramos que abrio bien
	js	error						; no es asi? imprime mensaje de error
	mov	ebx, eax					; paso al ebx el FD
	mov	ecx, archivo_1				; paso el puntero del buffer con el archivo
	mov	edx, LenArchivo_1			; y su len correspondiente
	mov	eax, sys_read				; y llamo a read de dicho archivo
	int 80h							; interrupcion del sistema
	pop ebx							;saco el FD de la pila
	push eax						;salvo la cantidad de digitos
	mov eax, sys_close				; muevo la directiva de cerrar el archivo
	int 80h							; interrupcion del sistema
	
;pregunto el Segundo nombre del archivo	
Preguntar_Nombre_2:
	mov ecx, mnsj2					;muevo al ecx el mensaje al usuario
	mov edx, lenmnsj2				;muevo al edx el largo
	call DisplayText				;llamo al procedimiento de imprimir en pantalla
	;leo de usuario un texto
	mov ecx, input2					;muevo al ecx el puntero del buffer de almacenamiento
	mov edx, lenInput2				;muevo la catidad de caracteres maxima q puedo tener
	call ReadText					;llamo al procedimiento de recibir de teclado
	dec eax							;en el eax tengo el largo del mensaje, lo decremento
	mov byte[input2+eax],0h			;cambio el ultimo caracter (enter) por un null
	;abro el archivo con el nombre que el usuaro me dio
.Abrir_archivo_1:			
	mov eax, sys_open				;muevo al eax la directiva de abrir archivo
	mov ebx, input2					;muevo al ebx el nombre de lo que quiero abrir
	mov ecx, 2						;muevo permisos que tendra el archivo
	int 80h							;interrupcion del sistema
	push eax						;salvo el FD
	test eax, eax 					; primero nos aseguramos que abrio bien
	js	error						; no es asi? imprime mensaje de error
	mov	ebx, eax					; paso al ebx el FD
	mov	ecx, archivo_2				; paso el puntero del buffer con el archivo
	mov	edx, LenArchivo_2			; y su len correspondiente
	mov	eax, sys_read				; y llamo a read de dicho archivo
	int 80h							; interrupcion del sistema
	pop ebx							;saco el FD de la pila
	push eax						;salvo la cantidad de digitos
	mov eax, sys_close				; muevo la directiva de cerrar el archivo
	int 80h							; interrupcion del sistema

;esta funcion llena la primera fila de ceros en la matriz
llenar_ceros_fila:
	pop eax							;saco el largo del 2do archivo
	pop edx							;saco el largo del primer archivo
	push edx						;los vuelvo a salvar
	push eax
	mov ecx, 0						;limpio el ecx para usarlo como contador
.ciclo:
	mov byte[matriz+ecx], 0			;muevo a la matriz un cero
	inc ecx							;incremento el contador
	cmp ecx, edx					;pregunto si ya llene la primera fila
	jne .ciclo						;si no lo he llenada, siga llenando
	pop ebx							;saco el largo del 2do archivo
	pop eax							;saco el largo del primer archivo
	push eax						;los vuelvo a salvar
	push ebx
	xor edx, edx					;limpio el edx
	mul ebx							;multiplico los largos para sacar el area de la matriz
	mov edx, eax					;muevo al edx el area
;esta funcion llena de basura el resto de la matriz (con fines de debugg)
llenar_basura:
	mov byte[matriz+ecx], "1"		;muevo a la matriz un "1"
	inc ecx							;incremento el contador
	cmp ecx, edx					;pregunto si es el final de la matriz
	jne llenar_basura				;si no lo es sigo llenando
	pop eax							;saco el largo del 2do archivo
	pop ecx							;saco el largo del primer archivo
	push ecx						;los vuelvo a salvar
	push eax
	mov eax, ecx					;muevo eax el largo del primer argumento
;esta funcion llena de ceros la primera columna de la matriz
llenar_ceros_col:
	mov byte[matriz+ecx], 0			;muevo a la matriz un cero
	add ecx, eax					;sumo al contador para que quede inicie en la siguiente columna
	cmp ecx, edx					;pregunto si ya termino
	jne llenar_ceros_col			;si no lo es sigo llenando
	
	pop eax							;saco el largo del 2do archivo
	pop ecx							;saco el largo del primer archivo
	push ecx						;los vuelvo a salvar
	push eax
	inc ecx							;incremento el tamaño de la fila (para quedar en la pos [1,1] de la matriz

;aqui tenemos el ciclo principal de la matriz
Ciclo_Principal:
.ArribaIzq:							;etiqueta que india q buscamos el numero de arriba a la izquierda (i-1, j-1)
	mov eax, ecx					;muevo al eax el puntero de (i,j)
	dec eax							;decremento ese puntero (i,j-1)
	pop edx							;saco el largo del 2do archivo
	pop ebx							;saco el largo del primer archivo
	push ebx						;los vuelvo a salvar
	push edx
	xor edx, edx					;limpio el edx para dividir
	div ebx							;realizo la division (i,j-1)/largo de i
	dec eax							;decremento el eax
	pusha							;salvo TODO en la pila
	xor edx, edx					;limpio el edx
	mov bl, byte[archivo_1+eax]		;paso al bl el byte que inica la letra del primer archivo
	mov byte[actual_1+edx], bl		;salvo ese byte en un buffer para luego ser comparado
	popa							;regreso TODO de la pila
	mov edx, eax					;paso el puntero al edx
	inc eax							;incremento el puntero
	mul ebx							;multiplico el puntero por el largo de la fila
	mov ebx, eax					;muevo al ebx el res de la multiplicacion
	mov eax, ecx					;muevo al eax el puntero (i,j)
	sub eax, ebx					;resto el puntero
	dec eax							;decremento el puntero
	pusha							;salvo TODO en la pila
	xor edx, edx					;limpio el edx
	mov bl, byte[archivo_2+eax]		;paso al bl el byte que inica la letra del segundo archivo
	mov byte[actual_2+edx], bl		;salvo ese byte en un buffer para luego ser comparado
	popa							;regreso TODO de la pila
	xor edx, edx					;limpio el edx 
	;ya tengo detectados los bytes para comparar!
	mov bl, byte[actual_1+edx]		;muevo al bl el primer byte
	mov bh, byte[actual_2+edx]		;muevo al bh el segundo byte
	call match						;llamo a la funcion que les hace match (eax = 1 match , eax = -1 dismatch)
	mov [argumento1+edx], eax		;salvo el resultado n un buffer temporal
	pop edx							;saco el largo del 2do archivo
	pop ebx							;saco el largo del primer archivo
	push ebx						;los vuelvo a salvar
	push edx
	xor edx, edx					;limpio el edx
	inc ebx							;inc el largo de la fila
	mov eax, ecx					;muevo al eax el puntero actual (i,j)
	sub eax, ebx					;resto al puntero el largo de la fila +1
	mov bl, byte[matriz+eax]		;ahora q estoy en la pos (i-1,j-1), caso el byte q contiene
	mov eax, ebx					;muevo ese byte al eax
	add eax, [argumento1+edx]		;sumo lo q esta en el buffer temporal (funcion de evaluacion) con el actual (M[i-1,j-1]+F(a,b))
	mov [argumento1+edx], eax		;muevo el resultado al buffer temporal

.Izquierda:							;etiqueta que india q buscamos el numero de la izquierda (i, j-1)
	mov eax, ecx					;muevo al eax el puntero actual (i,j)
	dec eax							;lo decremento (i,j-1)
	mov bl, byte[matriz+eax]		;ahora q estoy en la pos (i,j-1), caso el byte q contiene
	mov eax, ebx					;muevo al eax ese byte
	dec eax							;IMPORTANTE: decremento el eax para simular un gab:-1
	mov [argumento2+edx], eax		;salvo en un bufer temporarl el resultado (M[i,j-1]+gab)

.Arriba:							;etiqueta que india q buscamos el numero de arriba (i-1, j)
	xor edx, edx					;limpio el edx
	mov eax, ecx					;muevo al eax el puntero actual (i,j)
	pop edx							;saco el largo del 2do archivo
	pop ebx							;saco el largo del primer archivo
	push ebx						;los vuelvo a salvar
	push edx
	sub eax, ebx					;resto al puntero actual el largo de la fila
	mov bl, byte[matriz+eax]		;ahora q estoy en la pos (i-1,j), caso el byte q contiene
	mov eax, ebx					;muevo al eax ese byte
	dec eax							;IMPORTANTE: decremento el eax para simular un gab:-1
	mov edx, eax					;muevo al edx el resultado (M[i-1,j]+gab)

;funcion que inserta un nuevo valor en la matriz.
;notese que en los registros quedan de la misma forma que la funcion de smith-waterman
;eax = 0
;ebx = (M[i-1,j-1]+F(a,b))
;ecx = (M[i,j-1]+gab)
;edx = (M[i-1,j]+gab)
; y se inserta el Maximo valor de todos estos anteriores
.InsertarNuevoValor:
	push ecx						;salvo el puntero actual en la pila (i,j)
	mov eax, 0						;eax = 0
	mov ebx, [argumento1+eax]		;ebx = (M[i-1,j-1]+F(a,b))
	mov ecx, [argumento2+eax]		;ecx = (M[i,j-1]+gab)
	call maxNumber					;funcion q detecta al mayor entre 4 numeros, queda el mayor en el eax
	pop ecx							;regreso al ecx el puntero actual (i,j)
	mov byte[matriz+ecx],al			;muevo a la matriz (i,j) el resultado del max
	
;funcion q verifica si ya termine de recorrer la matriz
.verificar_fin:
	pop eax							;saco el largo del 2do archivo
	pop ebx							;saco el largo del primer archivo
	push ebx						;los vuelvo a salvar
	push eax
	mul ebx							;saco el maximo valor de la matriz
	dec eax							; lo decremento (xq empiezo en 0)
	cmp eax, ecx					;comparo ese maxio con el puntero actual
	je imprime_res					;si es igual me voy a imprimir

.verificar_fin_linea:				;si no lo es veo si es final de linea
	mov eax, ecx					;muevo al eax el puntero actual (i,j)
	inc eax							;incremento ese puntero(i,j+1)
	pop edx							;saco el largo del 2do archivo
	pop ebx							;saco el largo del primer archivo
	push ebx						;los vuelvo a salvar
	push edx
	xor edx, edx					;limpio el edx para dividir
	div ebx							;divido el puntero +1 con el largo del primer archivo
	cmp edx, 0						;comparo el modulo con 0
	jne .NoEsFin					;si es 0, es fin de linea y continuo, si no es 0, no es fin de linea y voy a no es fin
	inc ecx							; incremento 2 veces el ecx para q no quede en la columna de ceros
	inc ecx								
	jmp Ciclo_Principal				;brinco al ciclo principal para porbar con (i,j+2)
.NoEsFin:					
	inc ecx							;incremento el puntero actual
	jmp Ciclo_Principal				;brinco al ciclo principal para porbar con (i,j+1)
	
;imprimo a continuacion la matriz generada. OJO que esta toda en INT asi q debo convertir estos valores
imprime_res:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	pop eax							;saco el largo del 2do archivo
	pop ebx							;saco el largo del primer archivo (limpiar pila)
	mov ecx, ebx					;muevo al ecx, el largo del primer archivo
	mul ebx							;multiplico el largo de ambas filas/columna
	dec eax							; lo decremento (xq empiezo en 0)
	mov ebx, ecx					;muevo al ebx, el largo del primer archivo
	dec ebx							; lo decremento
	xor ecx, ecx					;limpio registros
	xor edx, edx					;limpio registros

.ciclo:
	pusha							;salvo todo en la pila
	mov dl, byte[matriz+ecx]		;muevo el byte actual de la matriz al dl
	mov eax, edx					;muevo al eax el edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	cmp eax, 9						;comparo con 9 a ver si tiene mas de un digito
	jg .printLinea2					;si los tiene me voy a printLinea2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lea esi,[buffer]				;dejo todo listo para poder hacer el Int_to_string
	call int_to_string
	mov ecx, eax					;muevo al ecx el resultado en string del numero de la matriz
	mov edx, 7						;muevo 7 al edx (maximo cantidad de numeros)
	call DisplayText				;llamo a la funcion de imprimir en pantalla
	popa							;Retorno de la pila todos los registros
	pusha							;Salvo todo de nuevo
	xor edx, edx					;limpio el edx
	mov eax, ecx					;muevo al el puntero actual
	inc eax							;incremento el puntero
	inc ebx							;incremento e ebx
	div ebx							;aplico una dicision
	cmp edx, 0						;comparo el modulo a ver si es el fin de la fila
	jne .printLinea					;si no lo es imprimo el resto de la linea
	popa							;Retorno de la pila todos los registros
	pusha							;Salvo todo de nuevo
	mov ecx, enter					;muevo al exc un enter (10)
	mov edx, 1						;muevo el edx el largo 1
	call DisplayText				;llamo a la funcion de imprimir en pantalla
	popa							;Retorno de la pila todos los registros
	jmp .verFin						;brinco a verfin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.printLinea2:
	lea esi,[buffer]				;dejo todo listo para poder hacer el Int_to_string
	call int_to_string
	mov ecx, eax					;muevo al ecx el resultado en string del numero de la matriz
	mov edx, 7						;muevo 7 al edx (maximo cantidad de numeros)
	call DisplayText				;llamo a la funcion de imprimir en pantalla
	popa							;Retorno de la pila todos los registros
	pusha							;Salvo todo de nuevo
	xor edx, edx					;limpio el edx
	mov eax, ecx					;muevo al el puntero actual
	inc eax							;incremento el puntero
	inc ebx							;incremento e ebx
	div ebx							;aplico una dicision
	cmp edx, 0						;comparo el modulo a ver si es el fin de la fila
	jne .printLinea3				;si no lo es imprimo el resto de la linea
	popa							;Retorno de la pila todos los registros
	pusha							;Salvo todo de nuevo
	mov ecx, enter					;muevo al exc un enter (10)
	mov edx, 1						;muevo el edx el largo 1
	call DisplayText				;llamo a la funcion de imprimir en pantalla
	popa							;Retorno de la pila todos los registros
	jmp .verFin						;brinco a verfin

.printLinea3:	
	popa							;Retorno de la pila todos los registros
	pusha							;Salvo todo de nuevo
	mov ecx, espacio2				;muevo al ecx un espacio
	mov edx, 2						;muevo el largo del espacio
	call DisplayText				;llamo a la funcion de imprimir en pantalla
	popa							;Retorno de la pila todos los registros
	jmp .verFin						;brinco a verfin
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
.printLinea:
	popa							;Retorno de la pila todos los registros
	pusha							;Salvo todo de nuevo
	mov ecx, espacio				;muevo al ecx un espacio
	mov edx, 3						;muevo el largo del espacio
	call DisplayText				;llamo a la funcion de imprimir en pantalla
	popa							;Retorno de la pila todos los registros
	jmp .verFin						;brinco a verfin

.verFin:
	cmp eax, ecx					;comparo el eax con el puntero actual
	je Cerrar						; si son iguales voy a cerrar
	inc ecx							;sino incremento el puntero actual
	jmp .ciclo						;brinco a continuar el ciclo
	
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
