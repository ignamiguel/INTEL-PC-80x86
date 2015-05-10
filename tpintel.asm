segment pila stack
		resb 64
		stacktop:
		
segment datos data
        menuStart  db  '=========>  MENU <=========','$'
		menuOptions  db  'Seleccionar opcion [1-3]','$'
		menuDecimal  db  '[1] Convertir de decimal a octal','$'
		menuOctal  db  '[2] Convertir de octal a decimal','$'
		menuExit  db  '[3] Salir','$'
		
		           db  2
		           db  0
		menuInput  times 2 resb 1
		
		msgIng  db 'Ingrese una cadena (max 5): ','$'
		msgMues db 10,13,'Ud ingreso: ','$'
		
                db 6
		        db 0
		cadena  times 6 resb 1
		
		octalTxt times 10 resb 1  
		octalTxtSize db 10
		
		caracter db  0
		divisor  db  8 
		numero  dw  0
		        db '$'
		
		divdendo dw  0
		
		aux  times 10 resb 1
		
		esCuatro  db 'ES 4!!!','$'
		esUno  db 'ES 1!','$'
		
 		opcion1  db  'Opcion 1 - decimal a octal','$'
		opcion2  db  'Opcion 2 - octal a decimal','$'
		
		factor  db  1
		index   db  0
		
		salto db 13,10,'$'
		
segment codigo code
..start:
		;incialización de registro DS, SS y el puntero a la PILA
		mov ax,datos
		mov ds,ax
		mov ax,pila
		mov ss,ax
		mov sp,stacktop
		
		call  printMenu ;imprimo menu

		mov ah,1
		int 21h ;se va a imprimir el carácter en pantalla
		mov byte[menuInput],al	

		;TODO valiar ingreso
		cmp  byte[menuInput],'1'
		je   opConvertToOctal
		
		cmp  byte[menuInput],'2'
		je   opConvertToDecimal
		
		jmp  salir
		
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
		lea  dx,[octalTxt]
		call printMsg
		
		;comparo con el 8
		;cmp  byte[numero],100
		;je   procesarMayor		
		
		;lea dx,[esMayorIgual]		
		;call printMsg ;imprimo mensaje

salir:		
		mov ah,4ch
		int 21h

printMenu:
		lea dx,[menuStart]
		call printMsg
		call printEnter
		call printEnter
		
		lea dx,[menuOptions]
		call printMsg
		call printEnter
		
		lea dx,[menuDecimal]
		call printMsg
		call printEnter
		
		lea dx,[menuOctal]
		call printMsg
		call printEnter
		
		lea dx,[menuExit]
		call printMsg
		call printEnter
		
		ret

opConvertToOctal:
		call printEnter
        lea dx,[opcion1]
		call printMsg
		call printEnter
		ret

opConvertToDecimal:
		call printEnter
        lea dx,[opcion2]
		call printMsg
		call printEnter
		ret

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
        ; uso la variable index para la posicion donde guardar
		mov  ax,0
		mov  al,byte[octalTxtSize]
		mov  byte[index],al
		mov  si,ax
		mov  byte[octalTxt+si],'$'
		
		; uso aux para ver
		mov  byte[aux+si],'$'
		
        sub  byte[index],1		
		
nacho:
		; cargo de atras para adelante
		mov  ax,0
		mov  al,byte[index]
		mov  si,ax
		
		; veo que tiene indice
		mov  byte[aux+si],al
		add  byte[aux+si],30h		
		
		lea  dx,[aux+si]		
		call  printMsg
		call  printEnter
			
		;limpio el registro ax		
		mov  ax, 0
		
		;copio numero al registro ax
		mov  ax,word[numero]
		
		;divido por divisor=8
		div  byte[divisor]		
		
		;guardo el resto en caracter
		;con el offset de posicion
		mov  byte[octalTxt+si],ah
		
		;copio el cociente antes de hacer una operacion aritmetica
		mov  ah,0
		mov  word[numero],ax
		
		;le sumo 30h para convertirlo a ASCII
     	add  byte[octalTxt+si],30h
		
		cmp  byte[octalTxt+si],'4'
		jne  sigue

		lea dx,[octalTxt+si]		
		call printMsg
		call printEnter
        
sigue:		
		;copio el cociente a numero
		;cmp word[numero],12
		;jne salir
		
		;cmp word[numero],000ch
		;jne salir
		
		;resto 1 a indice
		sub  byte[index],1
		
		; comparo si el cociento con la base=8
		cmp  word[numero],8
        jge  nacho	
		
		mov  ax,0
		mov  al,byte[index]
		mov  si,ax
		
		; le sumo el cociente
		mov  ax,word[numero]
		
		mov  byte[octalTxt+si],al
		add  byte[octalTxt+si],30h	
		
		ret
		
	
		
printMsg:
		mov ah,9
		int 21h
		ret
		
printEnter:
		mov dx,salto			;realizo un salto de linea
		mov ah,9h
		int 21h
		ret
		
