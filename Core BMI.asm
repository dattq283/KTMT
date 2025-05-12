.model small
.stack 100h
.data
    msg_weight     db 'Nhap can nang (kg): $'
    msg_height     db 13,10,'Nhap chieu cao (cm): $'
    msg_result     db 13,10,'Chi so BMI: $'
    msg_under      db 13,10,'Phan loai: Thieu can$'
    msg_normal     db 13,10,'Phan loai: Binh thuong$'
    msg_over       db 13,10,'Phan loai: Thua can$'
    msg_obese      db 13,10,'Phan loai: Beo phi$'
    msg_invalid_input db 13,10,'Input khong hop le$'

    input_buf      db 6, 0      ; max 6 chars, actual length = 0
                     db 6 dup(0)

    weight         dw ?
    height         dw ?
    bmi            dw ?
    remainder      dw ?

.code
start:
    mov ax, @data
    mov ds, ax

; Input weight
    lea dx, msg_weight
    mov ah, 09h
    int 21h

    lea dx, input_buf
    mov ah, 0Ah
    int 21h

    lea si, input_buf + 2
    call str2int
    mov weight, ax

    ; Kiểm tra nếu trọng lượng không hợp lệ (không âm)
    cmp ax, 0
    jl invalid_input

; Input height
    lea dx, msg_height
    mov ah, 09h
    int 21h

    lea dx, input_buf
    mov ah, 0Ah
    int 21h

    lea si, input_buf + 2
    call str2int
    mov height, ax

    ; Kiểm tra nếu chiều cao không hợp lệ (không âm)
    cmp ax, 0
    jl invalid_input

; Calculate height^2
    mov ax, height
    mul ax
    mov bx, ax        ; BX = height^2

; BMI = weight * 10000 / height^2
    mov ax, weight
    mov cx, 10000
    mul cx            ; DX:AX = weight * 10000
    div bx            ; AX = BMI, DX = remainder
    mov bmi, ax
    mov remainder, dx

; Display BMI result
    lea dx, msg_result
    mov ah, 09h
    int 21h

    mov ax, bmi
    call print_number

    mov dl, '.'
    mov ah, 02h
    int 21h

    ; Show 1 decimal digit, with rounding
    mov ax, remainder
    mov cx, 10
    mul cx
    add ax, 5        ; rounding
    div bx
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h

; Classify BMI
    mov ax, bmi
    cmp ax, 185    ; 18.5 * 10
    jl show_under

    cmp ax, 249    ; 24.9 * 10
    jl show_normal

    cmp ax, 299    ; 29.9 * 10
    jl show_over

    jmp show_obese

show_under:
    lea dx, msg_under
    jmp print_result
show_normal:
    lea dx, msg_normal
    jmp print_result
show_over:
    lea dx, msg_over
    jmp print_result
show_obese:
    lea dx, msg_obese

print_result:
    mov ah, 09h
    int 21h

    mov ah, 4Ch
    int 21h

; -----------------------------
; Convert input string to integer
; SI -> points to input string
; Returns AX = number
str2int:
    xor ax, ax
    xor cx, cx
.next_digit:
    mov cl, [si]
    cmp cl, 13
    je .done
    cmp cl, 0
    je .done
    cmp cl, '0'
    jb .done
    cmp cl, '9'
    ja .done
    sub cl, '0'
    mov bx, ax
    shl ax, 1
    shl bx, 2
    add ax, bx
    add ax, cx
    inc si
    jmp .next_digit
.done:
    ret

; -----------------------------
; Print AX as decimal number
print_number:
    mov bx, 10
    xor cx, cx
.next:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .next
.print:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop .print
    ret

invalid_input:
    lea dx, msg_invalid_input
    mov ah, 09h
    int 21h
    jmp exit_program

exit_program:
    mov ah, 4Ch
    int 21h
