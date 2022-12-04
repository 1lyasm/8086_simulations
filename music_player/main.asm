CODE    SEGMENT PUBLIC 'CODE'
        ASSUME CS:CODE


DATA SEGMENT PUBLIC 'DATA'
        ASSUME DS:DATA
    ; 220.00 Hz is written as 22000
    notes dw 22000, 22000, 22000, 17461, 26163, 22000, 17461, 26163, 22000, 32963, 32963, 32963, 34923, 26163, 20765, 17461, 26163, 22000, 44000, 22000, 22000, 44000, 41530, 39200, 36999, 32963, 34923, 0, 23308, 31113, 29366, 27718, 26163, 24694, 26163, 0, 17461, 20765, 17461, 22000
    intervals dw 4, 4, 4, 3, 1, 4, 3, 1, 8, 4, 4, 4, 3, 1, 4, 3, 1, 8, 4, 3, 1, 4, 3, 1, 1, 1, 2, 2, 2, 4, 3, 1, 1, 1, 2, 2, 2, 4, 3, 1
    note_cnt db 40

    ; addresses of 8253 registers
    cntr_0 = 0a9h
    cntr_1 = 0abh
    cntr_2 = 0adh
    control = 0afh
DATA ENDS


STACK SEGMENT STACK USE16 
        DW 20 DUP(?)
        ASSUME SS:STACK
STACK ENDS

delay proc near
    push cx
    ; 02fffh is too fast
    mov cx, 0ffffh
    L1: loop L1
    pop cx
    ret
delay endp

START:
        MOV AX, DATA
        MOV DS, AX
        MOV ES, AX
L3:
        xor si, si
L2:
        ; if end of notes, start again
        cmp si, 80
        jae L3

        ; put note to bx, interval to di
        mov bx, notes[si]
        mov di, intervals[si]

        ; if frequency is zero, pause
        test bx, bx
        jz pause

        ; else, divide 24,000,000 by note frequency (both multiplied by 100)
        mov dx, 016eh
        mov ax, 3600h
        div bx

        ; desired counter count is in ax
        mov bx, ax

        ; write counter 0 control word 
        mov al, 00110110b
        out control, al

        ; set counter value
        mov ax, bx
        out cntr_0, al
        mov al, ah
        out cntr_0, al  
pause:
        ; call delay interval times
        mov cx, di
L4:
        call delay
        loop L4
        
        add si, 2
        jmp L2

CODE    ENDS
        END START

