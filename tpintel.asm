segment datos data
		msgIng  db 'Ingrese una cadena (max 5): ','$'
		msgMues db 10,13,'Ud ingreso: ','$'
		
                db 6
		        db 0
		cadena  times 6 resb 1
		
		numero  db  0
		
		esMenor  db 'Es menor a 8','$'
 		esMayorIgual  db 'Es mayor o igual a 8','$'
		
		salto db 13,10,'$'
		
segment codigo code
..start:
		mov ax,datos
		mov ds,ax
		
		lea dx,[msgIng]
		call printMsg ;pido ingreso
		
		lea dx,[cadena-2] ; cargo desplaz del buffer
		mov ah,0ah
		int 21h ;ingreso de cadena
		
		mov ax,0
		mov al,[cadena-1]
		mov si,ax
		mov byte[cadena+si],'$' ; piso el 0Dh con el '$'para indicar fin de string para imprimir
		
		lea dx,[msgMues]		
		call printMsg ;imprimo mensaje
		
		lea dx,[cadena]		
		call printMsg ; imprimo lo ingresado

		call saltoDeLinea
		
		; copio el 1er caracter
		mov  dl,byte[cadena]
		mov  byte[numero],dl
		; lo transformo a numero restando al primero nibble 30
		sub  byte[numero],30h
		;comparo con el 8
		cmp  byte[numero],08h
		jl   procesarMenor
		
		lea dx,[esMayorIgual]		
		call printMsg ;imprimo mensaje
		
salir:		
		mov ah,4ch
		int 21h

procesarMenor:

		lea dx,[esMenor]		
		call printMsg ;imprimo mensaje
		jmp  salir
		
printMsg:
		mov ah,9
		int 21h
		ret
		
saltoDeLinea:
    mov dx,salto			;realizo un salto de linea
	mov ah,9h
	int 21h
	ret