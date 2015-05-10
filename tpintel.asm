segment datos data
		msgIng  db 'Ingrese una cadena (max 5): ','$'
		msgMues db 10,13,'Ud ingreso: ','$'
		
                db 6
		        db 0
		cadena  times 6 resb 1
		
		octalNum times 10 resb 1  
		
		caracter db  0
		divisor  db  8 
		numero  dw  0
		
		divdendo dw  0
		
		
		esMenor  db 'ES 100!!!Es menor a 8','$'
 		esMayorIgual  db 'Es mayor o igual a 8','$'
		
		factor  db  1
		index       db  0
		
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
		;copia la longitud de los caracters ingresados
		mov al,[cadena-1]
		mov si,ax
		mov byte[cadena+si],'$' ; piso el 0Dh con el '$'para indicar fin de string para imprimir
		
		lea dx,[msgMues]		
		call printMsg ;imprimo mensaje
		
		lea dx,[cadena]		
		call printMsg ; imprimo lo ingresado

		call printEnter
		
		; convierto caracteres a BPF c/s		
		; y lo guardo el numero
		call convertToBinary		
		
		; convierto a octal numero
		call convertToOctal
		
		;muestro
		lea  dx,[octalNum]
		call printMsg
		
		;comparo con el 8
		;cmp  byte[numero],100
		;je   procesarMenor		
		
		;lea dx,[esMayorIgual]		
		;call printMsg ;imprimo mensaje
		
salir:		
		mov ah,4ch
		int 21h

convertToBinary:
        ; cargo la longitud de los caracteres ingresados
		mov ax,0		
		mov al,[cadena-1]
		mov  cx,ax
		
		; uso una variable para ver por cuanto multiplicar
		mov  byte[index],al
		sub  byte[index],01h
		
doConvertion:		
		; copio de atras para adelante
		mov ax,0
		mov al,byte[index]
		mov si,ax
		mov dl,byte[cadena+si]
				
		mov  byte[caracter],dl
		
		; lo transformo a numero restando al primero nibble 30
		sub  byte[caracter],30h
		
		;multiplico por factor
		mov  al,byte[factor]
		mul  byte[caracter]
		add  word[numero],ax
		
		; ajusto el factor multiplicando
		mov ax,0
		mov al,10
		mul byte[factor]
		mov byte[factor],al
		
		; resto 1 al indice
		sub  byte[index],1
		
		loop doConvertion
		
		ret

convertToOctal:
        ; uso la variable indice para la posicon donde guardar
		mov  byte[index],9	
		
nacho:
		; cargo de atras para adelante
		mov ax,0
		mov al,byte[index]
		mov si,ax
			
		;limpio el registro ax		
		mov ax, 0
		
		;copio numero a ax
		mov ax,word[numero]
		
		;divido por divisor=8
		div byte[divisor]
		
		;guardo el resto en caracter
		mov byte[octalNum+si],ah

        ;le sumo 30h para convertirlo a ASCII
     	add byte[octalNum+si],30h	
		
		;copio el cociente a numero
		mov dx,0
		mov dl,al
        mov word[numero],dx
		
		;resto 1 a indice
		sub  byte[index],1
		
		; comparo si el cociento contra la base=8
		cmp word[numero],0008h		
        jge nacho
		
		mov byte[octalNum+si],al
		
		;cierro el vector
		mov ax,0
		mov al,10
		mov si,ax
		mov byte[octalNum+si],'$'
		
		ret
		
procesarMenor:

		lea dx,[esMenor]		
		call printMsg ;imprimo mensaje
		jmp  salir
		
printMsg:
		mov ah,9
		int 21h
		ret
		
printEnter:
		mov dx,salto			;realizo un salto de linea
		mov ah,9h
		int 21h
		ret
		
