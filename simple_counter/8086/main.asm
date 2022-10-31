CODE    SEGMENT PUBLIC 'CODE'
        ASSUME CS:CODE


DATA SEGMENT PUBLIC 'DATA'
        ASSUME DS:DATA

        PORT_A = 0300H
        PORT_B = 0302H
        PORT_C = 0304H
        PORT_CONTROL = 0306H

        CONTROL_WORD = 90H

        DELAY_AMT1 = 09000H
        DELAY_AMT2 = 06000H

        DIGIT_PATTERN DB 5 dup(0C0H, 79H, 24H, 30H, 19H)
DATA ENDS


STACK SEGMENT STACK USE16 
        DW 20 DUP(?)
        ASSUME SS:STACK
STACK ENDS


WAIT_BUTTON proc
    push cx
    mov cx, DELAY_AMT1
    nop_loop:
        nop
        loop nop_loop
    pop cx
    ret
WAIT_BUTTON endp


NO_LIGHT_DELAY proc
    push cx
    mov cx, DELAY_AMT2
    nop_loop:
        nop
        loop nop_loop
    pop cx
    ret
NO_LIGHT_DELAY endp



START:
        ; INIT DS AND ES
        MOV AX, DATA
        MOV DS, AX
        MOV ES, AX

        ; WRITE CONTROL WORD
        MOV AL, CONTROL_WORD
        MOV DX, PORT_CONTROL
        OUT DX, AL
        
        LEA BX, DIGIT_PATTERN

        ; START WITH 1
        MOV CL, 1

ENDLESS:

        ; CHECK IF IT IS LAST ELEMENT
        CMP CL, 4

        ; JUMP TO DISPLAY IT
        JBE L1

        ; START AGAIN WITH ONE
        MOV CL, 1  

L1:    
        ; TEMPORARILY SAVE BX
        MOV SI, BX

        ; ADD ARRAY OFFSET
        ADD BX, CX

        ; LOAD ARRAY ELEMENT TO AL
        MOV AL, [BX]

        ; LOAD PREVIOUS VALUE OF BX
        MOV BX, SI

        MOV DX, PORT_B
        
        ; DISPLAY DIGIT
        OUT DX, AL

        ; READ INPUT
        MOV DX, PORT_A
        IN AL, DX

        ; WAIT TILL BUTTON EXCITATION FADES
        CALL WAIT_BUTTON

        ; CHECK IF ANYTHING IS PRESSED
        CMP AL, 0EEH
        JE ENDLESS

        ; CHECK IF RESET IS PRESSED
        CMP AL, 0FEH
        JE RESET

        ; COUNTER_INCREMENT IS PRESSED
        ; DIGIT WILL BE CHANGED, TURN OFF PREVIOUS ONE FOR 
        ; BETTER DISPLAY
        MOV DX, PORT_B
        MOV AL, 0FFH 
        OUT DX, AL
        CALL NO_LIGHT_DELAY

        INC CL

        JMP ENDLESS

RESET: 
        ; RESET TO ZERO
        XOR CL, CL

        JMP ENDLESS

CODE    ENDS
        END START
