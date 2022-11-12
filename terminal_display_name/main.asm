CODE    SEGMENT PUBLIC 'CODE'
        ASSUME CS:CODE


DATA SEGMENT PUBLIC 'DATA'
        ASSUME DS:DATA

        d_reg = 0300h
        c_reg = 0301h

        async_w = 01h     ; 0000_0001 b
        reset_w = 40h     ; 0100_0001 b
        mode_w = 4dh      ; 0100_1101 b
        t_w = 11h         ; 0001_0001 b
        r_w = 14h         ; 0001_0100 b

        name_ db 'Ilyas Mustafazade', 0

DATA ENDS


STACK SEGMENT STACK USE16 
        DW 20 DUP(?)
        ASSUME SS:STACK
STACK ENDS


print_str proc
        push bx
        push dx

L1:     mov dx, c_reg
        in al, dx
        and al, 01h
        test al, al
        jz L1

        mov dx, d_reg
        mov al, [bx]
        test al, al
        jz end_
        out dx, al
        inc bx
        jmp L1

end_:   pop dx
        pop bx
        ret
print_str endp


START:
        ; INIT DS AND ES
        MOV AX, DATA
        MOV DS, AX
        MOV ES, AX

        mov dx, c_reg
        
        ; To send command next
        mov al, async_w
        out dx, al
        
        ; Send reset command
        mov al, reset_w
        out dx, al

        ; Send mode command after reset
        mov al, mode_w
        out dx, al

        ; Send receive command
        mov al, r_w
        out dx, al

        mov dx, c_reg
        
L2:     
        ; Wait for input
        in al, dx
        and al, 02h 
        test al, al
        jz L2

        ; Read input
        mov dx, d_reg
        in al, dx

        ; Save input
        mov cl, al
        clc 
        rcr cl, 1
        sub cl, 30h

        ; If input is zero, do not do anything
        test cl, cl
        jz endless

        ; Send transmit command
        mov dx, c_reg
        mov al, t_w
        out dx, al

        mov dx, d_reg
L3:
        ; Print newline
        mov al, 0dh
        out dx, al

        lea bx, name_
        call print_str

        loop L3

ENDLESS:
        JMP ENDLESS
        

CODE    ENDS
        END START
