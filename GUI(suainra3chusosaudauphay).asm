.model small
.stack 100h
.data          
    line1 db  "*--------------------------------------------*$"
    linea db  "|  _    ___    __ _     __       _ ___ _  _  |$"
    line2 db  "| |_)|V| |    /  |_||  /  | ||  |_| | / \|_) |$"
    line3 db  "| |_)| |_|_   \__| ||__\__|_||__| | | \_/| \ |$"
    line4 db  "|                                            |$"
    lineb db  "*--------------------------------------------*$"
    
    intro_line db "Nhan phim tuong ung hoac click chuot de tuong tac$"
    
    line5a db  "+----------------------------------------------+$"
    line5 db   "|           1. Tinh chi so BMI                 |$"
    line5b db  "+----------------------------------------------+$"
    line6 db   "|           2. Gioi thieu                      |$"
    line6a db  "+----------------------------------------------+$"
    line7 db   "|           3. Danh sach thanh vien nhom       |$"
    line7a db  "+----------------------------------------------+$"
    line8 db   "|           4. Thoat                           |$"
    line8a db  "+----------------------------------------------+$"
 
    blank1 db "                                                                                $"
    gthieu db  "Danh sach thanh vien trong nhom $"
    TV1 db  "1. Nguyen Tuan Anh$"        
    TV2 db  "2. Tran Tuan Duong$"
    TV3 db  "3. Trinh Quoc Dat$"
    TV4 db  "4. Pham Duy Cuong$"
    quit db  "Nhan phim bat ki de quay tro ve man hinh chinh$"
    
    
    ; Messages for user input
   
    weightPrompt    db "Nhap can nang (kg): $"
    heightPrompt    db "Nhap chieu cao (cm): $"
    genderPrompt    db "Nhap gioi tinh (M/W): $"
    invalidGender   db "Gioi tinh khong hop le ! Vui long nhap lai.", 0Dh, 0Ah, "$"
    errorMsg        db "Loi: Dau vao khong hop le hoac phep chia loi!", 0Dh, 0Ah, "$"
    
    ; BMI result messages
    bmiResult       db "Chi so BMI cua ban: $"
    bmiDecimal      db ".$"
    
    ; BMI classification messages (WHO standard)
    underweightMsg  db "Phan loai: Thieu can$"
    normalMsg       db "Phan loai: Binh thuong$"
    overweightMsg   db "Phan loai: Thua can$"
    obeseClass1Msg  db "Phan loai: Beo phi do I$"
    obeseClass2Msg  db "Phan loai: Beo phi do II$"
    obeseClass3Msg  db "Phan loai: Beo phi do III$"
    
    ; Afterward
    continue db "Nhap so 1 de tinh toan lai$"
    return db "Nhap cac phim con lai de quay tro ve man hinh chinh$"
    
    ; Gioi thieu
    dong1 db "Chi so BMI (Body Mass Index - Chi so khoi co the) la mot cong cu pho bien dung de danh gia tinh trang cua mot nguoi dua tren chieu cao va can nang$"
    dong2 db "Cong thuc tinh BMI: BMI = Can nang (kg) / (Chieu cao(m))^2 $"
    dong3 db "Bang phan loai dua tren chi so BMI:$"
    dong4 db "Duoi 18.5: Thieu can$"
    dong5 db "18.5 - 24.9: Binh thuong$"
    dong6 db "25 - 29.9: Thua can$"
    dong7 db "30 - 34.9: Beo phi do I$"
    dong8 db "35 - 39.9: Beo phi do II$"
    dong9 db "40+: Beo phi do III$"
    
    ; Variables for calculation
    ; Variables for calculation
    weight          dw 1    ; Weight in kg (default 1 to avoid div by zero)
    height          dw 1    ; Height in cm (default 1 to avoid div by zero)
    bmi             dw 0    ; BMI result (integer part)
    bmiDecimalPart  dw 0    ; BMI decimal part
    gender          db 'M'  ; 'M' or 'W' (default M)
    
    ; Buffer for number input
    invalidNumberMsg db "                 Loi: Vui long chi nhap so! BAM PHIM BAT KI DE NHAP LAI.$"
    inputBuffer     db 6 dup(0)  ; Buffer d? luu chu?i nh?p v o
    isValidNumber   db 1          ; Flag d? ki?m tra c  ph?i s? h?p l? hay kh ng
    
    ; New line
    newLine         db 0Dh, 0Ah, "$"
.code

gotoxy macro x y
    mov ah, 02h
    mov bh, 00h
    mov dl,x  ; Cot
    mov dh,y  ; Dong
    int 10h
endm


clrscr macro topleft,bottomRight,attr
    mov ah,06h
    mov al,0
    mov bh,attr ; Mau nen - Mau chu
    mov cx,topLeft
    mov dx,bottomRight
    
    int 10h
endm

check_click macro x1, x2, y1, y2, label_if_inside, label_out ; Kiem tra click chuot
    mov ax, cx
    shr ax, 3       
    mov si, ax       

    mov ax, dx
    shr ax, 3       
    mov di, ax       

    cmp si, x1
    jb label_out     
    cmp si, x2
    ja label_out     

    cmp di, y1
    jb label_out     
    cmp di, y2
    ja label_out     

    jmp label_if_inside 

endm



printColoredString proc
    push ax
    push cx
    push si

    mov si, dx       
printCharLoop:
    mov al, [si]     
    cmp al, '$'      
    je endPrintColored

    mov ah, 09h      
    mov bh, 0        
    mov cx, 1        ; In 1 k? t?
    int 10h          ; In k? t? v?i m?u trong BL

    
    mov ah, 03h      ; L?y v? tr? con tr? hi?n t?i
    int 10h          ; S? d?ng int 10h thay v? int 21h
    inc dl           ; Tang c?t (di chuy?n sang ph?i)
    mov ah, 02h      ; ??t v? tr? con tr?
    int 10h

    inc si           ; Chuy?n d?n k? t? ti?p theo
    jmp printCharLoop

endPrintColored:
    pop si
    pop cx
    pop ax
    ret
printColoredString endp

readNumberWithValidation proc
    ; Luu v? tr  ban d?u c?a con tr?
    mov ah, 03h      ; L?y v? tr  con tr? hi?n t?i
    mov bh, 0        ; Trang hi?n th?
    int 10h
    push dx          ; Luu v? tr  (DL=c?t, DH=d ng)

readNumberStart:
    ;  ?t l?i con tr? v? v? tr  ban d?u
    pop dx
    push dx          ; L?y v  luu l?i v? tr  ban d?u
    mov ah, 02h      ;  ?t v? tr  con tr?
    mov bh, 0        ; Trang hi?n th?
    int 10h
    
    ; X a d?n cu?i d ng (t? v? tr  hi?n t?i)
    mov ah, 09h
    mov al, ' '      ; K  t? kho?ng tr?ng
    mov bh, 0        ; Trang hi?n th?
    mov bl, 1Fh      ; M u (nhu trong code c?a b?n)
    mov cx, 30       ; S? lu?ng k  t? d? x a (c  th? di?u ch?nh)
    int 10h
    
    ;  ?t l?i con tr? v? v? tr  ban d?u
    pop dx
    push dx          ; L?y v  luu l?i v? tr  ban d?u
    mov ah, 02h      ;  ?t v? tr  con tr?
    mov bh, 0        ; Trang hi?n th?
    int 10h
    
    mov di, offset inputBuffer  ; Kh?i t?o con tr? d?n buffer
    mov cx, 0                   ;  ?m s? k  t? d  nh?p
    mov byte ptr [isValidNumber], 1  ; M?c d?nh gi? s? d?u v o h?p l?
    
    ; X a buffer tru?c khi nh?p d? li?u m?i
    push cx
    push di
    mov cx, 6
    xor al, al
clearBuffLoop:
    mov [di], al
    inc di
    loop clearBuffLoop
    pop di
    pop cx

readCharLoop:
    ;  ?c m?t k  t? t? b n ph m
    mov ah, 01h
    int 21h
    
    ; Ki?m tra n?u l  ph m Enter
    cmp al, 13
    je endReadInput
    
    ; Luu k  t? v o buffer
    mov [di], al
    inc di
    inc cx
    
    ; Ki?m tra xem k  t? c  ph?i l  s? hay kh ng
    cmp al, '0'
    jb markInvalid
    cmp al, '9'
    ja markInvalid
    
    ; Gi?i h?n s? lu?ng k  t? nh?p v o t?i da l  5
    cmp cx, 5
    jl readCharLoop
    jmp endReadInput

markInvalid:
    mov byte ptr [isValidNumber], 0  ;   nh d?u d?u v o kh ng h?p l?
    jmp readCharLoop

endReadInput:
    ; Ki?m tra t nh h?p l?
    cmp byte ptr [isValidNumber], 0
    je invalidInput
    
    ; N?u h?p l?, chuy?n d?i chu?i th nh s?
    mov di, offset inputBuffer
    xor ax, ax  ; K?t qu? s? = 0
    xor cx, cx  ;  ?m s? digit

convertToNumber:
    mov bl, [di]  ; L?y k  t? t? buffer
    cmp bl, 0     ; Ki?m tra k?t th c chu?i
    je conversionDone
    cmp bl, 13    ; Ki?m tra k  t? Enter
    je conversionDone
    
    ; Chuy?n ASCII th nh s?
    sub bl, '0'
    
    ; Nh n k?t qu? hi?n t?i v?i 10
    mov dx, 10
    mul dx    ; AX = AX * 10
    
    ; Ki?m tra tr n s?
    jc invalidInput
    
    ; C?ng digit m?i v o k?t qu?
    xor bh, bh
    add ax, bx
    
    ; Ki?m tra tr n s?
    jc invalidInput
    
    inc di
    inc cx
    jmp convertToNumber

conversionDone:
    ; Ki?m tra n?u kh ng c  digit n o
    cmp cx, 0
    je invalidInput
    
    ; K?t qu? h?p l? n?m trong AX
    pop dx  ; Lo?i b? v? tr  con tr? d  luu t? stack
    ret

invalidInput:
    lea dx, newLine
    call printString
    
    ; Hien thong bao loi
    lea dx, invalidNumberMsg
    call printString 
    
    ; Xuong dong sau thong bao loi
    lea dx, newLine
    call printString
    
    ; Quay l?i d? nh?p l?i
    jmp readNumberStart

readNumberWithValidation endp

main:
    mov ax,@data
    mov ds,ax
           
    ; An con tro       
    mov ah,01h
    mov cx,2607h
    int 10h
    
    ; Thiet lap color cho background
    call intro_screen
    

intro_screen:
    clrscr 0000h,074Fh,1Eh
    clrscr 0800h,184Fh,1Fh
    
    
    gotoxy 19 2
    mov ah,9
    lea dx,line1
    int 21h
    
    gotoxy 19 3
    mov ah,9
    lea dx,linea
    int 21h
    
    
    gotoxy 19 4
    mov ah,9
    lea dx,line2
    int 21h
    
    
    gotoxy 19 5
    mov ah,9
    lea dx,line3
    int 21h
    
    gotoxy 19 6
    mov ah,9
    lea dx,line4
    int 21h
    
    gotoxy 19 7
    mov ah,9
    lea dx,lineb
    int 21h
    
    gotoxy 18 9
    mov ah,9
    lea dx,intro_line
    int 21h
    
    gotoxy 18 11
    mov ah,9
    lea dx,line5a
    int 21h
    
    gotoxy 18 12
    mov ah,9
    lea dx,line5
    int 21h
    
    gotoxy 18 13
    mov ah,9
    lea dx,line5b
    int 21h
    
    gotoxy 18 14
    mov ah,9
    lea dx,line6
    int 21h
    
    gotoxy 18 15
    mov ah,9
    lea dx,line6a
    int 21h
    
    gotoxy 18 16
    mov ah,9
    lea dx,line7
    int 21h
    
    gotoxy 18 17
    mov ah,9
    lea dx,line7a
    int 21h
    
    gotoxy 18 18
    mov ah,9
    lea dx,line8
    int 21h
    
    gotoxy 18 19
    mov ah,9
    lea dx,line8a
    int 21h
    
    
    jmp wait_input

wait_input: 
    mov ah,01h
    int 16h
    jnz key_pressed
    
    ; Kiem tra click chuot
    mov ax,0003h
    int 33h
    test bx,1       ; ki?m tra bit 0 c?a BX (chu?t tr?i)
    jz wait_input   ; n?u kh?ng click th? ti?p t?c ch?
    
    call mouse_clicked
    jmp wait_input  ; sau khi x? l? click, quay l?i ch? ti?p

key_pressed:
    jmp input_case


mouse_clicked:
    check_click 26,45,11,13, CASE1, check2
    
check2:
    check_click 26,45,13,15, CASE2, check3
    
check3:
    check_click 26,45,15,17, CASE3, check4
    
check4:
    check_click 26,45,17,19, CASE4, no_click
    

no_click:
    jmp wait_input
     

input_case:
    mov ah,08h
    int 21h
    
    cmp al, '1'
    jb input_case
    
    cmp al, '9'
    ja input_case
    
    cmp al,'1'
    je CASE1
    
    cmp al,'2'
    je CASE2
    
    cmp al,'3'
    je CASE3
    
    cmp al,'4'
    je CASE4
    
    
CASE1:
    clrscr 0000h,184Fh,1Fh

weightInput:
    ; Nh?p c n n?ng
    gotoxy 17 3
    
    clrscr 0400h,044Fh,1Ch
    
    lea dx, weightPrompt
    call printString
    call readNumberWithValidation
    
    ; Ki?m tra gi  tr? tr? v?
    cmp ax, 0
    je weightInput  ; N?u l  0 (d?u v o kh ng h?p l?), y u c?u nh?p l?i
    
    mov weight, ax
    
    gotoxy 17 4
    mov ah,9
    lea dx,blank1
    int 21h
    
    
    
heightInput:    
    ; Nh?p chi?u cao
    gotoxy 17 5
    
    clrscr 0600h,064Fh,1Ch
    
    lea dx, heightPrompt
    call printString
    call readNumberWithValidation
    
    ; Ki?m tra gi  tr? tr? v?
    cmp ax, 0
    je heightInput  ; N?u l  0 (d?u v o kh ng h?p l?), y u c?u nh?p l?i
     
    mov height, ax
     
    gotoxy 17 6
    mov ah,9
    lea dx,blank1
    int 21h
    
    



getGenderInput:
    ; Position the cursor for gender prompt
    gotoxy 17 7
    lea dx, genderPrompt
    call printString

    ; Read 1 character from keyboard with echo
    mov ah, 01h
    int 21h
    mov bl, al        ; Save the entered character
    
    ; Convert to uppercase if lowercase
    cmp bl, 'a'
    jb checkGenderValid
    cmp bl, 'z'
    ja checkGenderValid
    sub bl, 32       ; Convert to uppercase
    
checkGenderValid:
    cmp bl, 'M'
    je validGender
    cmp bl, 'W'
    je validGender


    gotoxy 17 9
    clrscr 0900h,094Fh,1Ch
    lea dx, invalidGender
    call printString
    
    gotoxy 17 7
    lea dx, blank1 
    call printString
    
    jmp getGenderInput
    
validGender:
    mov gender, bl  
    
    lea dx, newLine
    call printString
    
    ; Tính BMI = (10000 / height) * weight / height
 mov bx, height
cmp bx, 0
je errorHandler     

mov ax, height
mul height         
                    

test dx, dx
jnz errorHandler  


mov cx, ax          

mov ax, weight
mov bx, 10000      


mul bx             

cmp dx, 0
je perform_division 

cmp dx, cx
jae errorHandler    

perform_division:

div cx             


mov bmi, ax


mov ax, dx     
mov bx, 10000      
mul bx             


test dx, dx
jnz decimal_overflow


div cx           
jmp save_decimal

decimal_overflow:

mov ax, 9999       

save_decimal:
mov bmiDecimalPart, ax


gotoxy 17 11
lea dx, bmiResult
call printString


mov ax, bmi
call printNumber


lea dx, bmiDecimal
call printString


mov ax, bmiDecimalPart


mov bx, 1000        
xor dx, dx
div bx
mov dl, al          
add dl, '0'        
push dx             


mov ax, dx         
mov bx, 100
xor dx, dx
div bx
mov dl, al       
add dl, '0'        
push dx             


mov ax, dx          
mov bx, 10
xor dx, dx
div bx
mov dl, al        
add dl, '0'        
push dx            

mov dl, dl         
add dl, '0'        


pop ax
mov dl, al
mov ah, 02h
int 21h

pop ax
mov dl, al
mov ah, 02h
int 21h


pop ax
mov dl, al
mov ah, 02h
int 21h


mov dl, dl
mov ah, 02h
int 21h
    
    ; Display BMI classification based on WHO standards
    ; Different standards for males and females
    gotoxy 17 13
    mov al, gender
    cmp al, 'M'
    je maleBMIClassification
    
    ; Female BMI classification
    mov ax, bmi
    cmp ax, 18    ; Less than 18.5 (using integer comparison)
    jl underweight
    cmp ax, 25    ; 18.5 - 24.9
    jl normal
    cmp ax, 30    ; 25 - 29.9
    jl overweight
    cmp ax, 35    ; 30 - 34.9
    jl obeseClass1
    cmp ax, 40    ; 35 - 39.9
    jl obeseClass2
    jmp obeseClass3  ; 40+
    
maleBMIClassification:
    ; Male BMI classification (same thresholds as female according to WHO)
    mov ax, bmi
    cmp ax, 18    ; Less than 18.5
    jl underweight
    cmp ax, 25    ; 18.5 - 24.9
    jl normal
    cmp ax, 30    ; 25 - 29.9
    jl overweight
    cmp ax, 35    ; 30 - 34.9
    jl obeseClass1
    cmp ax, 40    ; 35 - 39.9
    jl obeseClass2
    jmp obeseClass3  ; 40+
    
underweight:
    clrscr 0D00h,0D4Fh,1Ch
              
    lea dx,underweightMsg
    call printString
    
    lea dx, newLine
    call printString ; In d?ng m?i v?i m?u m?c d?nh
    
    call afterward
    ret
    
    
normal:
    clrscr 0D00h,0D4Fh,1Ah
              
    lea dx,normalMsg
    call printString
    
    lea dx, newLine
    call printString 
    
    call afterward
    ret
    
overweight:
    clrscr 0D00h,0D4Fh,1Eh
             
    lea dx, overweightMsg
    call printString
    
    lea dx, newLine
    call printString 
    
    jmp afterward
    
    
obeseClass1:
    clrscr 0D00h,0D4Fh,16h
    
    lea dx, obeseClass1Msg
    call printString
    
    lea dx, newLine
    call printString 
    
    jmp afterward
     
    
obeseClass2:
    clrscr 0D00h,0D4Fh,1Ch
    
    lea dx, obeseClass2Msg
    call printString
    
    lea dx, newLine
    call printString 
    
    jmp afterward
    
    
obeseClass3:
    clrscr 0D00h,0D4Fh,14h
              
    lea dx, obeseClass3Msg
    call printString
    
    lea dx, newLine
    call printString 
    
    jmp afterward
    
    
errorHandler:
    mov bl,1Ch
    lea dx, errorMsg
    call printColoredString
    jmp afterward
    
    
; Procedure to print a string
printString proc
    mov ah, 09h
    int 21h
    ret
printString endp

; Procedure to read a number from keyboard
readNumber proc
    xor bx, bx       ; Clear BX for accumulation
    xor cx, cx
readNumber endp       ; Clear digit counter
    
readLoop:
    ; Read character
    mov ah, 01h
    int 21h
    
    ; Check for Enter key
    cmp al, 13
    je endReadNumber
    
    ; Check if digit
    cmp al, '0'
    jb readLoop      ; If below '0', ignore
    cmp al, '9'
    ja readLoop      ; If above '9', ignore
    
    ; Convert to digit and add to result
    sub al, '0'
    xor ah, ah       ; Clear AH
    
    ; Save current value
    push ax
    
    ; Multiply current result by 10
    mov ax, 10
    mul bx           ; DX:AX = BX * 10
    
    ; Check for overflow
    cmp dx, 0
    jne readOverflow
    
    mov bx, ax       ; BX = old value * 10
    
    ; Add new digit
    pop ax
    add bx, ax
    
    ; Check for overflow or negative value (carry bit)
    jc readOverflow
    
    ; Increment digit counter
    inc cx
    cmp cx, 5        ; Max 5 digits
    jge endReadNumber
    
    jmp readLoop
    
readOverflow:
    ; Handle overflow - clear stack and return max value
    cmp cx, 0
    je clearStack
    pop ax
    
clearStack:
    mov bx, 9999     ; Return max safe value
    jmp endReadNumber
    
endReadNumber:
    mov ax, bx       ; Return value in AX
    ret


; Procedure to print a number
printNumber proc
   ; Save registers
    push bx
    push cx
    push dx
    
    mov bx, 10       ; Divisor
    mov cx, 0        ; Digit counter
    
    ; Handle zero specially
    test ax, ax
    jnz convertLoop
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp finishPrintNumber
    
convertLoop:
    ; Check if number is zero
    test ax, ax
    jz printLoop
    
    ; Divide by 10
    mov dx, 0
    div bx           ; AX = quotient, DX = remainder
    
    ; Convert remainder to ASCII and push to stack
    push dx
    inc cx           ; Increment digit counter
    
    jmp convertLoop
printLoop:
    ; Pop digits from stack and print
    test cx, cx
    jz finishPrintNumber
    
    pop dx
    add dl, '0'      ; Convert to ASCII
    mov ah, 02h
    int 21h
    
    dec cx
    jmp printLoop
    
finishPrintNumber:
    ; Restore registers
    pop dx
    pop cx
    pop bx
    ret
printNumber endp
    ret
    
afterward:
    gotoxy 17 19
    mov ah,9
    lea dx, continue
    int 21h
    
    gotoxy 17 21
    mov ah,9
    lea dx,return
    int 21h
    
.wait_input_case1:
    
    mov ah, 01h
    int 16h
    jnz .key_pressed_case1

    
    mov ax, 0003h
    int 33h
    test bx, 1            
    jz .wait_input_case1

    
    check_click 17, 44 , 18, 20, CASE1 , .check1
.check1:
    check_click 17, 65 , 21, 22, intro_screen, .wait_input_case1
    
    jmp .wait_input_case1
    
.key_pressed_case1:
    mov ah, 00h
    int 16h
    
    cmp al,'1'
    je CASE1
    
    jmp intro_screen
    
    ret

    
CASE2:
    clrscr 0000h,184Fh,1Fh
    
    gotoxy 1 1
    mov ah,9
    lea dx,dong1
    int 21h
    
    gotoxy 1 5
    mov ah,9
    lea dx,dong2
    int 21h
    
    gotoxy 1 8
    mov ah,9
    lea dx,dong3
    int 21h
    
    
    clrscr 0A00h,0A4Fh,1Ch
    gotoxy 15 10
    mov ah,9
    lea dx,dong4
    int 21h
    
    clrscr 0C00h,0C4Fh,1Ah
    gotoxy 15 12
    mov ah,9
    lea dx,dong5
    int 21h
    
    clrscr 0E00h,0E4Fh,1Eh
    gotoxy 15 14
    mov ah,9
    lea dx,dong6
    int 21h
    
    clrscr 1000h,104Fh,16h
    gotoxy 15 16
    mov ah,9
    lea dx,dong7
    int 21h
    
    clrscr 1200h,124Fh,1Ch
    gotoxy 15 18
    mov ah,9
    lea dx,dong8
    int 21h
    
    
    clrscr 1400h,144Fh,14h
    gotoxy 15 20
    mov ah,9
    lea dx,dong9
    int 21h
    
    gotoxy 20 23
    mov ah,9
    lea dx,quit
    int 21h
    
.wait_input_case2:
    
    mov ah, 01h
    int 16h
    jnz .key_pressed_case2

    
    mov ax, 0003h
    int 33h
    test bx, 1            
    jz .wait_input_case2

    
    check_click 20, 67 , 22, 24, intro_screen , .wait_input_case2

    jmp .wait_input_case2

.key_pressed_case2:
    mov ah, 00h
    int 16h
    jmp intro_screen
    
    ret    

CASE3:
    clrscr 0000h,184Fh,1Fh
    
    gotoxy 22 5
    mov ah,9
    lea dx,gthieu
    int 21h
    
    gotoxy 27 8
    mov ah,9  
    lea dx,TV1
    int 21h
    
    gotoxy 27 11
    mov ah,9
    lea dx,TV2
    int 21h
    
    gotoxy 27 14
    mov ah,9
    lea dx,TV3
    int 21h
    
    gotoxy 27 17
    mov ah,9
    lea dx,TV4
    
    int 21h
    
    gotoxy 20 22
    mov ah,9
    lea dx,quit
    int 21h
    
.wait_input_case3:
    
    mov ah, 01h
    int 16h
    jnz .key_pressed_case3

    
    mov ax, 0003h
    int 33h
    test bx, 1            
    jz .wait_input_case3

    
    check_click 20, 67 , 21, 23, intro_screen , .wait_input_case3

    jmp .wait_input_case3

.key_pressed_case3:
    mov ah, 00h
    int 16h
    
    jmp intro_screen
    
    ret
    
    
CASE4:
    mov ah,4ch
    int 21h
        
    
end main 

