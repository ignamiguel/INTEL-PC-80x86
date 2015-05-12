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
		divisor  db  0 
		numero  dw  0
		        db '$'
		
		divdendo dw  0
		
		aux  times 10 resb 1
		
		esCuatro  db 'ES 4!!!','$'
		esUno  db 'ES 1!','$'
		
 		opcion1  db  'Opcion 1 - decimal a octal','$'
		opcion2  db  'Opcion 2 - octal a decimal','$'
		
		msgToOctal  db 'Numero en base 8: ','$'  
		msgToDecimal  db 'Numero en base 10: ','$'  
		
		factor  db  1
		index   db  0
		
		salto db 13,10,'$'
		
		; Mensajes de errores
		menuInputInvalidMsg  db  'Opcion invalida. Vuelva a intentar...','$' 
		errorMaxLenth  db  'Ingresar hasta 3 digitos. Vuelva a intentar...','$' 
		errorOnlyDigit  db  'Ingresar solo digitos en B10 [0-9]. Vuelva a intentar...','$' 
		errorOnlyOctalDigit  db  'Ingresar solo digitos en B8 [0-7]. Vuelva a intentar...','$' 
		
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
		int 21h
		;obtengo la opcion ingresada		
		mov byte[menuInput],al

		cmp  byte[menuInput],'1'
		je   opConvertToOctal
		
		cmp  byte[menuInput],'2'
		je   opConvertToDecimal
		
		cmp  byte[menuInput],'3'
		je  salir		
		
		call printMenuInputInvalid
		jmp inicio
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

		;pido ingreso
		lea dx,[msgIngBase10]
		call printMsg 
		
		; cargo desplaz del buffer
		lea dx,[cadena-2] 
		;ingreso de cadena
		mov ah,0ah
		int 21h 
		
		mov ax,0
		;copia la longitud de los caracters ingresados
		mov al,[cadena-1]		
		mov si,ax
		; piso el 0Dh con el '$'para indicar fin de string 
		mov byte[cadena+si],'$' 
		
		;imprimo mensaje
		lea dx,[msgMues]		
		call printMsg 
		
		; imprimo lo ingresado
		lea dx,[cadena]		
		call printMsg 

		call printEnter
		
		; validar cadena
		call validateDecimalInput
		
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
		
		;pido ingreso
		lea dx,[msgIngBase8]
		call printMsg 
		
		; cargo desplaz del buffer
		lea dx,[cadena-2] 
		;ingreso de cadena
		mov ah,0ah
		int 21h 
		
		mov ax,0
		;copia la longitud de los caracters ingresados
		mov al,[cadena-1]
		; piso el 0Dh con el '$'para indicar fin de string 
		mov si,ax
		mov byte[cadena+si],'$' 
		
		;imprimo mensaje
		lea dx,[msgMues]		
		call printMsg 
		
		; imprimo lo ingresado
		lea dx,[cadena]		
		call printMsg 

		call printEnter
		
		;validar ingreso
		call validateOctalInput
		
		; convierto desde octal a BPF c/s
		call convertOctalToBPF

		;convierto de numero a caracter base 10
		call convertToDecimal
		
		call printEnter		
		jmp  inicio

;==========================================================
;======     VALIDATE DECIMAL INPUT
;==========================================================
validateDecimalInput:
		; cadena tiene que tener longitud 30h
		mov ax,0
		mov al,[cadena-1]
		cmp al,3
		jg  printMaxLength
		
		;cadena debe ser solo digitos [0-9]
		;cargo la longitud de los caracteres ingresados en cx
		mov  ax,0		
		mov  al,[cadena-1]
		mov  cx,ax
		;cargo en index la posicion 0
		mov  byte[index],0
		
doValidation:
		;valido uno a uno
		mov  ax,0
		mov  al,byte[index]
		mov  si,ax
		mov  dl,byte[cadena+si]
				
		mov  byte[caracter],dl
		; lo transformo a numero restando 30h
		sub  byte[caracter],30h
		
		;comparo
		cmp  byte[caracter],0
		jl   printOnlyDigits
		
		cmp byte[caracter],9
		jg  printOnlyDigits
		
		; sumo 1 a index
		add  byte[index],1
		
		loop doValidation
		
		ret

;==========================================================
;======     VALIDATE OCTAL INPUT
;==========================================================
validateOctalInput:
		; cadena tiene que tener longitud 30h
		mov ax,0
		mov al,[cadena-1]
		cmp al,3
		jg  printMaxLength
		
		;cadena debe ser solo digitos [0-7]
		;cargo la longitud de los caracteres ingresados en cx
		mov  ax,0		
		mov  al,[cadena-1]
		mov  cx,ax
		;cargo en index la posicion 0
		mov  byte[index],0
		
doOctalValidation:
		;valido uno a uno
		mov  ax,0
		mov  al,byte[index]
		mov  si,ax
		mov  dl,byte[cadena+si]
				
		mov  byte[caracter],dl
		; lo transformo a numero restando 30h
		sub  byte[caracter],30h
		
		;comparo
		cmp  byte[caracter],0
		jl   printOnlyOctalDigits
		
		cmp byte[caracter],7
		jg  printOnlyOctalDigits
		
		; sumo 1 a index
		add  byte[index],1
		
		loop doOctalValidation
		
		ret
		
		
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
		; cargo divisor con 8
		mov  byte[divisor],8
		
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
		
		;comento para no mostrar el valor de index
		;lea  dx,[aux+si]		
		;call  printMsg
		;call  printEnter
			
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

		; comento para no mostrar el valor de octalTxt
		;lea dx,[octalTxt+si]		
		;call printMsg
		;call printEnter
		
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
		
doOctalConvertionToBPF:		
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
		
		loop doOctalConvertionToBPF
		
		ret

;==========================================================
;======     CONVERT FROM BPFs TO CHARACTER (BASE 10)
;==========================================================		
convertToDecimal:
		; cargo divisor con 10
		mov  byte[divisor],10
		
		; uso la variable index para la posicion donde guardar
		mov  ax,0
		mov  al,byte[decimalTxtSize]
		mov  byte[index],al
		;cargo el caracter de cierre de string en decimalTxt[index]
		mov  si,ax
		mov  byte[decimalTxt+si],'$'
		
		; uso aux para ver
		mov  byte[aux+si],'$'
		
        sub  byte[index],1		
		
makeDivisionDecimal:
		; cargo de atras para adelante
		mov  ax,0
		mov  al,byte[index]
		mov  si,ax
		
		; veo que tiene indice
		mov  byte[aux+si],al
		add  byte[aux+si],30h		
		
		; comento para no mostrar
		;lea  dx,[aux+si]		
		;call  printMsg
		;call  printEnter
			
		;limpio el registro ax		
		mov  ax, 0		
		;copio numero al registro ax
		mov  ax,word[numero]
		
		;divido por divisor=10
		div  byte[divisor]		
		
		;copio el resto en caracter
		;con el offset de posicion
		mov  byte[decimalTxt+si],ah
		
		;copio el cociente antes de hacer una operacion aritmetica
		mov  ah,0
		mov  word[numero],ax
		
		;le sumo 30h para convertirlo a ASCII
     	add  byte[decimalTxt+si],30h

		; comento para no mostrar
		;lea dx,[decimalTxt+si]		
		;call printMsg
		;call printEnter
		
		;resto 1 a indice
		sub  byte[index],1
		
		; comparo el cociento con la base=10
		cmp  word[numero],10
        jge  makeDivisionDecimal	
		
		; si es menor, cargo el cociente en decimalTxt
		mov  ax,0
		mov  al,byte[index]
		mov  si,ax
		
		; le sumo el cociente
		mov  ax,word[numero]
		
		mov  byte[decimalTxt+si],al
		add  byte[decimalTxt+si],30h
		
		;muestro
		lea  dx,[msgToDecimal]
		call printMsg
		lea  dx,[decimalTxt]
		call printMsg
		
		;reseteo decimalTxt
		mov  cx,0
		mov  cl,byte[decimalTxtSize]
		
		mov  byte[index],0	

resetDecimalTxt:
		mov  ax,0
		mov  al,byte[index]
		mov  si,ax
		mov  byte[decimalTxt+si],20h
		add  byte[index],1
		loop resetDecimalTxt
		
		call printEnter		
		ret	
		
;==========================
;====       MENU       ====
;==========================
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
		
;=============================
;====    UTILITARIOS      ====
;=============================		
printMaxLength:
		call printEnter
		call printEnter
		lea dx,[errorMaxLenth]
		call printMsg
		call printEnter
		call printEnter
		
		jmp inicio

printOnlyDigits:
		call printEnter
		call printEnter
		lea dx,[errorOnlyDigit]
		call printMsg
		call printEnter
		call printEnter
		
		jmp inicio
		
printOnlyOctalDigits:
		call printEnter
		call printEnter
		lea dx,[errorOnlyOctalDigit]
		call printMsg
		call printEnter
		call printEnter
		
		jmp inicio
		
printMenuInputInvalid:
		call printEnter
		call printEnter
		lea dx,[menuInputInvalidMsg]
		call printMsg
		call printEnter
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
		
