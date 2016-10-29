		PROCESSOR 16F887
		INCLUDE P16F887.INC
		__CONFIG _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	   	__CONFIG _CONFIG2, _WRT_OFF & _BOR21V
ESTADO			EQU 7D
STATUS_TEMP 	EQU 7F
W_TEMP		EQU 7E
		ORG 0
		GOTO INICIO
		ORG 04
		GOTO INTER

INICIO
		
		MOVLW		B'00000000'
		BANKSEL 		ANSELH
		MOVWF		ANSELH
		BSF				STATUS,RP1
		BANKSEL		TRISB
		CLRF TRISB				;CONFIGURACION PUERTO B
		MOVLW 0D0				;CONFIGURACION TIMER0 
		MOVWF OPTION_REG
		MOVLW 0E				;CONFIGURACION 1 DE CONVERTIDOR A/D
		;MOVWF ADCON1
		BANKSEL TRISA ;
            	BSF TRISA,0 ;PONEMOS A RA0 COMO ENTRADA
            	BANKSEL ANSEL ;
            	BSF ANSEL,0 ;PONEMOS A RA0 COMO ANALOGICO
           	 BANKSEL ADCON0 ;
           	 MOVLW B'11000001' ;ELEGIMOS EL RELOJ Frc DEL ADC
		MOVWF ADCON0 ;Y ENCENDEMOS EL CONVERTIDOR
		BCF STATUS, RP0
		BSF INTCON, TMR0IE		;Habilita TMR0
		BSF INTCON, GIE			;Habilita Interrupciones

CICLO	NOP
		GOTO CICLO		

INTER	MOVWF W_TEMP		;guarda los valores de w y estatus
		SWAPF STATUS,W
		MOVWF STATUS_TEMP

		BTFSC INTCON, TMR0IF	;pregunta si se trata de la interrupcion TMR0
		GOTO INTTMR0
		
		BTFSC PIR1, ADIF		;pregunta si se trata de  la interrupcion ADIF
		GOTO INTAD

		GOTO FININT			;Si ejecuta esto falta agregar el codigo de interrupcion

INTTMR0	NOP					;nop para ajustar tiempo se debe ejecutar cada 125 us
		MOVLW 0C9			;inicializacion del timer para que no afecte el codigo
		MOVWF TMR0			;siguiente en la medicion del tiempo

		MOVLW 001			;CONFIGURACION A/D ADCON0, ENCENDIENDO modulo
		MOVWF ADCON0

		BCF PIR1,ADIF		;limpiando bandera de interrupcion
		
		BSF STATUS, RP0		
		BSF PIE1,ADIE		;habilitando interrupciones de A/D
		BCF STATUS, RP0

		BSF INTCON, PEIE	;habilitando interrupciones de perifericos 
		
		BSF ADCON0,2		;Iniciando conversion


		BCF INTCON, TMR0IF  ;limpia la interrupcion de TMR0
		GOTO FININT

INTAD	MOVF ADRESH,W		;pasa conversion al grupo de trabajo
		MOVWF ESTADO		;lo guarda en la variable estado
		MOVWF PORTB			;lo muestra en el puerto B
		BSF STATUS, RP0		
		BCF PIE1,ADIE		;Inhabilita la interrupcion de AD
		BCF STATUS, RP0

FININT	SWAPF STATUS_TEMP,W ; Recupera valores de w y status
		MOVWF STATUS 
		SWAPF W_TEMP,F
		SWAPF W_TEMP,W 

		RETFIE				;regresa de la interrupcion

		END
