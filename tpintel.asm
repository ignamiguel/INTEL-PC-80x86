segment datos data
		msgIng  db 'Ingrese una cadena (max 5): ','$'
		msgMues db 10,13,'Ud ingreso: ','$'
		        db 6
		        db 0
		cadena  times 6 resb 1
		
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

		mov ah,4ch
		int 21h

printMsg:
		mov ah,9
		int 21h
		ret