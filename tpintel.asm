segment pila stack
		resb 64
		stacktop:
		
segment datos data
        menuStart  db  '=========>  MENU <=========','$'
		menuOptions  db  'Seleccionar opcion [1-3]','$'
		menuDecimal  db  '[1] Convertir de decimal a octal','$'
		menuOctal  db  '[2] Convertir de octal a decimal','$'
		menuExit  db  '[3] Salir','$'
		
		menuInput  resb 1
		           db  '$'
		
		msgIngBase10  db 'Ingrese una numero en base 10 (max 3): ','$'
		msgIngBase8  db 'Ingrese una numero en base 8 (max 3): ','$'
		
		msgMues db 10,13,'Ud ingreso: ','$'
		
                db 6
		        db 0
		cadena  times 6 resb 1
		
		octalTxt times 10 resb 1  
		octalTxtSize db 9
		
		decimalTxt times 10 resb 1
		decimalTxtSize db 9
		
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
		
		msgToOctal  db 'Numero en base 8: ','$'  
		
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
		
inicio:
		;imprimo menu
		call  printMenu 

		; pido ingresar opcion [1-3]
		mov ah,1
		int 21h ;obtengo la opcion ingresada
		mov byte[menuInput],al

		;TODO valiar ingreso
		cmp  byte[menuInput],'1'
		je   opConvertToOctal
		
		cmp  byte[menuInput],'2'
		je   opConvertToDecimal
		
		jmp  salir
salir:		
		mov ah,4ch
		int 21h

;******************************************************
;****                                              ****
;****       CONVERT FROM DECIMAL TO OCTAL          ****
;****                                              ****
;******************************************************
opConvertToOctal: 
		; convierte un numero en base 10 a base 8
		call printEnter
        lea dx,[opcion1]
		call printMsg
		call printEnter

		lea dx,[msgIngBase10]
		call printMsg ;pido ingreso
		
		lea dx,[cadena-2] ; cargo desplaz del buffer
		mov ah,0ah
		int 21h ;ingreso de cadena
		
		mov ax,0
		;copia la longitud de los caracters ingresados
		mov al,[cadena-1]
		mov si,ax
		mov byte[cadena+si],'$' ; piso el 0Dh con el '$'para indicar fin de string 
		
		lea dx,[msgMues]		
		call printMsg ;imprimo mensaje
		
		lea dx,[cadena]		
		call printMsg ; imprimo lo ingresado

		call printEnter
		
		; convierto caracteres (decimales) a BPFs
		call convertDecimalToBPF		
		
		; convierto a octal
		call convertToOctal
		
		call printEnter
		jmp  inicio
		
;******************************************************
;****                                              ****
;****       CONVERT FROM OCTAL TO DECIMAL          ****
;****                                              ****
;******************************************************
opConvertToDecimal:
		;convierte un numero en base 8 a base 10
		call printEnter
        lea dx,[opcion2]
		call printMsg
		call printEnter		 
		;--------------
		lea dx,[msgIngBase8]
		call printMsg ;pido ingreso
		
		lea dx,[cadena-2] ; cargo desplaz del buffer
		mov ah,0ah
		int 21h ;ingreso de cadena
		
		mov ax,0
		;copia la longitud de los caracters ingresados
		mov al,[cadena-1]
		mov si,ax
		mov byte[cadena+si],'$' ; piso el 0Dh con el '$'para indicar fin de string 
		
		lea dx,[msgMues]		
		call printMsg ;imprimo mensaje
		
		lea dx,[cadena]		
		call printMsg ; imprimo lo ingresado

		call printEnter
		
		; convierto desde octal a BPF c/s
		call convertOctalToBPF		
		
		;call printEnter		
		jmp  inicio
		
;==========================================================
;======     CONVERT FROM CHARACTER (BASE 10) TO BPFs
;==========================================================	
convertDecimalToBPF:        
		; cargo la longitud de los caracteres ingresados en cx
		mov  ax,0		
		mov  al,[cadena-1]
		mov  cx,ax
		
		;cargo valor por default en factor=1
		mov  byte[factor],1
		
		;cargo valor por default en numero=01h
		mov  word[numero],0
		
		;cargo en index la posicion desde donde copiar
		mov  byte[index],al
		;cantidad de caracteres ingresados -1
		sub  byte[index],1
		
doConvertionToBPF:		
		;copio de atras para adelante
		mov  ax,0
		mov  al,byte[index]
		mov  si,ax
		mov  dl,byte[cadena+si]
				
		mov  byte[caracter],dl
		
		; lo transformo a numero restando 30h
		sub  byte[caracter],30h
		
		;multiplico por factor (potencia de 10)
		mov  ax,0
		mov  al,byte[factor]
		mul  byte[caracter]
		add  word[numero],ax
		
		; ajusto el factor multiplicando
		; ***WARING*** en la 4 vuelta es 1000
		mov ax,0
		mov al,10
		mul byte[factor]
		mov byte[factor],al
		
		; resto 1 a index
		sub  byte[index],1
		
		loop doConvertionToBPF
		
		ret

;==========================================================
;======     CONVERT FROM BPFs TO CHARACTER (BASE 8)
;==========================================================	
convertToOctal:		
        ; uso la variable index para la posicion donde guardar
		mov  ax,0
		mov  al,byte[octalTxtSize]
		mov  byte[index],al
		;cargo el caracter de cierre de string en octalTxt[index]
		mov  si,ax
		mov  byte[octalTxt+si],'$'
		
		; uso aux para ver
		mov  byte[aux+si],'$'
		
        sub  byte[index],1		
		
makeDivision:
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
		
		;copio el resto en caracter
		;con el offset de posicion
		mov  byte[octalTxt+si],ah
		
		;copio el cociente antes de hacer una operacion aritmetica
		mov  ah,0
		mov  word[numero],ax
		
		;le sumo 30h para convertirlo a ASCII
     	add  byte[octalTxt+si],30h

		lea dx,[octalTxt+si]		
		call printMsg
		call printEnter
		
		;resto 1 a indice
		sub  byte[index],1
		
		; comparo el cociento con la base=8
		cmp  word[numero],8
        jge  makeDivision	
		
		; si es menor, cargo el cociente en octalTxt
		mov  ax,0
		mov  al,byte[index]
		mov  si,ax
		
		; le sumo el cociente
		mov  ax,word[numero]
		
		mov  byte[octalTxt+si],al
		add  byte[octalTxt+si],30h
		
		;muestro
		lea  dx,[msgToOctal]
		call printMsg
		lea  dx,[octalTxt]
		call printMsg
		
		;reseteo octalTxt
		mov  cx,0
		mov  cl,byte[octalTxtSize]
		
		mov  byte[index],0	

resetOctalTxt:
		mov  ax,0
		mov  al,byte[index]
		mov  si,ax
		mov  byte[octalTxt+si],20h
		add  byte[index],1
		loop resetOctalTxt
		
	    ;vuelvo a mostrar
		call printEnter
		
		;lea  dx,[msgToOctal]
		;call printMsg
		;lea  dx,[octalTxt]
		;call printMsg
		
		ret	
;==========================================================
;======     CONVERT FROM CHARACTER (BASE 8) TO BPFs
;==========================================================	
convertOctalToBPF:
		; cargo la longitud de los caracteres ingresados en cx
		mov  ax,0		
		mov  al,[cadena-1]
		mov  cx,ax
		
		;cargo valor por default en factor=1
		mov  byte[factor],1
		
		;cargo valor por default en numero=00h
		mov  word[numero],0
		
		;cargo en index la posicion desde donde copiar
		mov  byte[index],al
		;cantidad de caracteres ingresados -1
		sub  byte[index],1
		
doConvertionToBPFnacho:		
		;copio de atras para adelante
		mov  ax,0
		mov  al,byte[index]
		mov  si,ax
		mov  dl,byte[cadena+si]
				
		mov  byte[caracter],dl
		
		; lo transformo a numero restando 30h
		sub  byte[caracter],30h
		
		;multiplico por factor (potencia de 8)
		mov  ax,0
		mov  al,byte[factor]
		mul  byte[caracter]
		add  word[numero],ax
		
		; ajusto el factor multiplicando
		; ***WARING*** en la 4 vuelta es 4096
		mov ax,0
		mov al,8
		mul byte[factor]
		mov byte[factor],al
		
		; resto 1 a index
		sub  byte[index],1
		
		loop doConvertionToBPFnacho
		
		cmp  word[numero],100
		je   salir
		
		ret
		;----------
		;reseteo decimalTxt
		;mov  cx,0
		;mov  cl,byte[decimalTxtSize]
		
		;mov  byte[index],0	

resetDecimalTxt:
		mov  ax,0
		mov  al,byte[index]
		mov  si,ax
		mov  byte[decimalTxt+si],20h
		add  byte[index],1
		loop resetDecimalTxt
		
	    ;vuelvo a mostrar
		call printEnter
		
		ret	
		;-----------------

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
		
printMsg:
		mov ah,9
		int 21h
		ret
		
printEnter:
		mov dx,salto
		mov ah,9h
		int 21h
		ret
		
