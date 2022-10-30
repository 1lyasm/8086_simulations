CODE    SEGMENT PUBLIC 'CODE'
        ASSUME CS:CODE


DATA    SEGMENT PUBLIC 'DATA'

        ASSUME DS:DATA

        PORT_A = 0A9H
        PORT_B = 0ABH
        PORT_C = 0ADH
        PORT_CONTROL = 0AFH

        CONTROL_WORD = 082H

        DELAY_AMT = 0C10H

        LED_ON_OFF DB 5 DUP(01H, 03H, 05H, 09H, 11H)

	    DIGITS DB 4 dup(00H, 00H, 00H, 00H)
        DIGIT_PATTERN DB 10 dup(07Eh, 00ch, 0b6h, 09eh, 0cch, 0dah, 0fah, 00eh, 0feh, 0deh)

DATA ENDS

stack segment stack use16
        dw 20 dup (?)
        assume ss:stack
stack ends


TURN_OFF_ALL proc
    MOV AL, [LED_ON_OFF]
    OUT PORT_A, AL
    ret
TURN_OFF_ALL endp


delay proc
    push cx
    mov cx, DELAY_AMT
    nop_loop:
        nop
        loop nop_loop
    pop cx
    ret
delay endp


start:
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX

    LEA BX, DIGITS
    LEA SI, LED_ON_OFF

    MOV AL, CONTROL_WORD
    OUT PORT_CONTROL, AL 

    MOV CL, 10H
ENDLESS:
    CALL TURN_OFF_ALL

    PUSH CX
    MOV CX, 4
    MOV DX, 0
    SHOW_4_DIGIT:
        PUSH DX
        ADD DX, SI
        INC DX
        PUSH BX
        MOV BX, DX
        MOV AL, [BX]
        POP BX
        POP DX
        OUT PORT_A, AL
        PUSH DX
        ADD DX, BX
        PUSH BX
        MOV BX, DX
        MOV AL, [BX]
        POP BX
        POP DX
        OUT PORT_A, AL

        CALL DELAY
        CALL TURN_OFF_ALL
        INC DX
        LOOP SHOW_4_DIGIT
    POP CX

    CMP CL, 80H
    JB L1
    AND CL, 0FH 
    ADD CL, 10H
L1: MOV AL, CL
    XOR AH, AH
    SHR AL, 1
    SHR AL, 1
    SHR AL, 1
    SHR AL, 1
    OUT PORT_C, AL
    call delay
    IN AL, PORT_B
    and al, 0fh

    MOV AH, CL
    AND AH, 0F0H
    SHR AH, 1
    SHR AH, 1
    SHR AH, 1
    SHR AH, 1

    MOV DL, CL
    AND DL, 0FH
    AND CL, 00F0H
    SHL CL, 1
    ADD CL, DL

    CMP AL, 00H
    JE ENDLESS

    CMP AX, 0108H
    JNE L4

    MOV AL, 00H
    MOV [BX], AL
    MOV [BX + 1], AL
    MOV [BX + 2], AL
    MOV [BX + 3], AL
    AND CL, 0F0H
    JMP ENDLESS

L4: PUSH AX 
    INC CL 
    XOR CH, CH 
    PUSH CX
    AND CL, 0FH 
    CMP CL, 04H
    POP CX 
    JB ENDLESS 

    AND CL, 0F0H

    MOV DI, 03H

    UPDATE_DIGITS:
        POP AX
        CMP AX, 0208H
        JNE L2

        PUSH BX
        LEA BX, DIGIT_PATTERN
        XOR AH, AH
        JMP L3

L2:     SHR AH, 1
        SHR AL, 1
        MOV DL, 03H
        MOV DH, AH
        MUL DL
        MOV AH, DH
        ADD AL, AH
        INC AL

        PUSH BX
        LEA BX, DIGIT_PATTERN
        XOR AH, AH
        ADD BX, AX
L3:     MOV AL, [BX]
        POP BX
        PUSH BX
        ADD BX, DI
        MOV [BX], AL
        POP BX
        DEC DI
        CMP DI, 4
        JB UPDATE_DIGITS
        
    JMP ENDLESS

CODE    ENDS
        END START


