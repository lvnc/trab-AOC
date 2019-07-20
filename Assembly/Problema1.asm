
ORG    100h

LEA DX, msgTITULO        ; mensagem do titulo    
MOV AH, 9
INT 21h 

PUTC 0Dh                 ; pula linha
PUTC 0Ah   

PUTC 0Dh                
PUTC 0Ah

LEA DX, msg1             ; mensagem pedindo hora de inicio
MOV AH, 9
INT 21h     

CALL scan_num            ; pega a hora inserida (que esta em CX)
MOV horaINICIAL, CL      ; copia o valor pra horaINICIAL

PUTC 0Dh                 
PUTC 0Ah

LEA DX, msg2             ; mensagem pedindo hora de termino
MOV AH, 9
INT 21h
                 
CALL scan_num            ; pega a hora inserida
MOV horaFINAL, CL        ; copia o valor para horaFINAL

PUTC 0Dh
PUTC 0Ah
  
MOV AL, horaINICIAL
CMP AL, horaFINAL        ; compara hora inicial com final 

JA horaINICIALmaiorFINAL ; hora inicial > hora final
JZ horasIGUAIS           ; hora inicial = hora final
JB horaINICIALmenorFINAL ; hora final > hora inicial
  
horasIGUAIS:   
    MOV AL, 24           ; o total de horas e 24 se hora inicial = final
    JMP imprime
                 
horaINICIALmaiorFINAL:
    MOV AL, 24
    MOV BL, horaINICIAL
    SUB AL, BL
    ADD AL, horaFINAL    ; total = (24-horaINICIAL)+horaFINAL
    JMP imprime
      
      
horaINICIALmenorFINAL:         
    MOV AL, horaINICIAL
    MOV BL, horaFINAL
    SUB BL, AL           ; total = horaFINAL - horaINICIAL
    MOV AL, BL    
    

imprime:  ; imprime duracao do jogo
    MOV BL, AL          ; move o que esta em AL para BL  
    
    MOV DX, offset msgTOTAL   ; mensagem de duracao
    MOV AH, 9
    INT 21h
    
    MOV AH, 0           ; zera AH p/ valor anterior nao interferir
    
    MOV AL, BL          ; volta com o valor de BL para AL
    
    CALL print_num      ; printa o que esta em AX (duracao da partida)  
    MOV DX, offset msgHORAS        ; printa ' horas'
    MOV AH, 9
    INT 21h 

RET     ; return 

; variaveis      
horaINICIAL  DB  ?
horaFINAL    DB  ?

; mensagens  
msgTITULO DB 'Duracao da Partida de Xadrez$'
msg1 DB 'Hora de inicio: $'
msg2 DB 'Hora de fim: $'
msgTOTAL DB 'Duracao: $'
msgHORAS DB ' horas $'  
 
;------------------------------------------;   
; materia disponibilizado na sala do tempo ; 


;-----------------PUTC---------------------;
; imprime caractere em AL e avanca a posicao do cursor
PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM


;---------------PRINT NUM------------------;    
; printa numero em AX usado com PRINT_NUM_UNS para printar numeros c/ sinal
PRINT_NUM       PROC    NEAR
        PUSH    DX
        PUSH    AX

        CMP     AX, 0
        JNZ     not_zero

        PUTC    '0'
        JMP     printed

not_zero:
        ; checa sinal de AX, torna absoluto se negativo
        CMP     AX, 0
        JNS     positive
        NEG     AX

        PUTC    '-'

positive:
        CALL    PRINT_NUM_UNS
printed:
        POP     AX
        POP     DX
        RET
PRINT_NUM       ENDP



;---------PRINT NUM UNS--------------;
; printa numero sem sinal de AX
;valores permitidos: 0 a 65535 (FFFF)
PRINT_NUM_UNS   PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        ; flag pra prevenir printar zero antes do numero
        MOV     CX, 1

        ; (resultado de "/ 10000" e sempre menor ou igual a 9)
        MOV     BX, 10000       ; 2710h - divisor

        ; AX e zero?
        CMP     AX, 0
        JZ      print_zero    

begin_print:

        ; verifica divisor (se for zero da jump p/ end_print)
        CMP     BX,0
        JZ      end_print

        ; previne printar zeros antes do numero
        CMP     CX, 0
        JE      calc
        ; se AX<BX entao o resultado de DIV e zero
        CMP     AX, BX
        JB      skip
calc:
        MOV     CX, 0   ; define flag

        MOV     DX, 0
        DIV     BX      ; AX = DX:AX / BX   (DX=resto)

        ; printa ultimo digito
        ; AH e sempre ZERO, entao e ignorado
        ADD     AL, 30h    ; converte para codigo ASCII
        PUTC    AL


        MOV     AX, DX  ; pega o resto da ultima divisao

skip:
        ; calcula BX=BX/10
        PUSH    AX
        MOV     DX, 0
        MOV     AX, BX
        DIV     CS:ten  ; AX = DX:AX / 10   (DX=resto)
        MOV     BX, AX
        POP     AX

        JMP     begin_print
        
print_zero:
        PUTC    '0'
        
end_print:

        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
PRINT_NUM_UNS   ENDP  


ten             DW      10 ; usado pra multiplicar/dividir no SCAN_NUM e PRINT_NUM_UNS


;---------------------SCAN NUM-----------------------;
; pega um numero do teclado e coloca no registrador CX
SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; reseta flag
        MOV     CS:make_minus, 0

next_digit:

        ; pega caractere e coloca em AL
        MOV     AH, 00h
        INT     16h
        ; printa
        MOV     AH, 0Eh
        INT     10h

        ; verifica -
        CMP     AL, '-'
        JE      set_minus

        ; verifica se enter foi pressionado
        CMP     AL, 0Dh  
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                   ; backspace pressionado?
        JNE     backspace_checked
        MOV     DX, 0                   ; remove ultimo digito e divide por 10
        MOV     AX, CX             
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTC    ' '                     ; limpa posicao
        PUTC    8                       ; recua posicao
        JMP     next_digit
backspace_checked:


        ; apenas numeros
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8       ; backspace
        PUTC    ' '     ; limpa ultima entrada nao numerica
        PUTC    8       ; backspace        
        JMP     next_digit ; espera o proximo input      
ok_digit:


        ; multiplica CX por 10 (na primeira vez o resultado e zero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; verifica se o numero e muito grande (+16bits)
        CMP     DX, 0
        JNE     too_big

        ; converte para codigo ASCII
        SUB     AL, 30h

        ; adiciona AL a CX:
        MOV     AH, 0
        MOV     DX, CX      ; backup, se o resultado for muito grande
        ADD     CX, AX
        JC      too_big2    ; jump se o numero for muito grande

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX      ; restaura backup
        MOV     DX, 0       ; DX recebe 0
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; inverte o ultimo DX:AX = AX*10, faz AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; backspace
        PUTC    ' '     ; limpa o ultima entrada nao numerica
        PUTC    8       ; backspace        
        JMP     next_digit ; espera pelo Enter/Backspace
        
        
stop_input:
        ; verifica flag
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; usado como flag
SCAN_NUM        ENDP                             
                
                

END                   
