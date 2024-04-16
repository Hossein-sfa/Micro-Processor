.MODEL SMALL
.STACK 64

.DATA
n dw 2                         ; n is the number that each iteration is checked
tmp dw 0                       ; this is the number to save the reveresed number during palindromize
reversed dw 0                  ; the reversed number after palindromize
ten db 10                      ; const base 10 to divide and mul for palindromize
it dw ?                        ; this is variable 'i' that is used if for loop to check prime number
ARRAY DW 10 DUP(?)             ; result array containing palindrome prime number
flag dw 1                      ; if this gets zero during program, it means the number isn't prime or palindrome 
index dw 0                     ; index of array also number of prime palindrome number
num dw 0                       ; number of found palindrome prime number

.CODE

PALINDROME PROC                 ; PALINDROME procedure
    mov ax, n                   ;  
    mov tmp, ax                 ;   tmp = n  
    mov reversed, 0             ;
REVERSE_LOOP:                   ;   while 
    cmp tmp, 0                  ;   if (tmp > 0) 
    je REVERSE_DONE             ;   do break
    mov ax, 0                   ; 
    mov ax, [reversed]          ;   load reversed
    mul [ten]                   ; 
    mov [reversed], ax          ;   reversed = reversed * 10
    mov ax, [tmp]               ;   ax = tmp
    div ten                     ;   tmp /= 10
    mov dx, 0                   ;   dx = tmp % 10
    mov dl, ah                  ;   ah = tmp / 10 (float free)
    add [reversed], dx          ;   reversed += tmp % 10
    mov ah, 0                   ; 
    mov [tmp], ax               ;   tmp = tmp / 10
    jmp REVERSE_LOOP            ;   go back to the top of loop
REVERSE_DONE:   
    mov ax, n                   ;   ax = n
    cmp ax, reversed            ;   if reversed == n
    jne NOT_PALINDROME          ;   then number isn't palindrome
    mov flag, 1                 ;   flag = true (number is palindrome) 
    ret                         ;   return
NOT_PALINDROME: 
    mov flag, 0                 ;   flag = false (number isn't palindrome)
    ret                         ;   return
PALINDROME ENDP

PRIME PROC                      ;   PRIME procedure
    mov ax, n                   ;   ax = n
    cmp ax, 2                   ;   if n < 2
    jl NON_PRIME                ;   then number isn't prime
    mov [it], 2                 ;   i = 2
FOR_LOOP:                       ;   for loop
    mov bx, it                  ;   bx = i
    cmp bx, n                   ;   if i <= n
    je END_OF_LOOP              ;   then loop is over
    mov ax, n                   ;   ax = n
    mov dx, 0                   ;   dx = 0
    div it                      ;   divide to get reaminder (dx = n % i)
    cmp dx, 0                   ;   if n % i == 0
    je NON_PRIME                ;   then number isn't prime
    inc [it]                    ;   i++
    jmp FOR_LOOP                ;   go back to top of the loop
NON_PRIME:                      ;   
    mov flag, 0                 ;   flag = false (number isn't prime)
    ret                         ;   return
    END_OF_LOOP:                ;   
    mov flag, 1                 ;   flag = true
    ret                         ;   return
PRIME ENDP


MAIN PROC FAR
    mov ax, @data               ;   get data segment (ax = data segment)
    mov ds, ax                  ;   set ds register for data segement (ds = ax = data segment)   
    mov ax, num                 ;   ax = num
WHILE_LOOP:                     ;   while_loop
    cmp num, 10                 ;   if num < 10
    je END_WHILE                ;   then loop is over (we finally found first ten palindrome prime number) 
    mov flag, 1                 ;   flag = true (set flag to true) 
    call PALINDROME             ;   palindrome() function
    cmp flag, 0                 ;   if flag == false
    je CONTINUE                 ;   then the number isn't palindrome, next step go for next number (number++)
    call PRIME                  ;   prime() function
    cmp flag, 0                 ;   if flag == false
    je CONTINUE                 ;   then the number isn't prime, next step go for next number (number++)
    inc num                     ;   num++ (the number is both palindrome and prime, we find another, num increases 
    mov bx, OFFSET ARRAY        ;   get offset
    add bx, index               ;   index is added twice because the data is DW
    add bx, index               ;
    mov ax, n                   ;   
    mov [bx], ax                ;   array[index] = n
    inc index                   ;   index++
    CONTINUE:                   ;   iterative part 
    inc n                       ;   n++
    jmp WHILE_LOOP              ;   go back to while loop
END_WHILE:                      ;
    nop                         ;   end of the program
MAIN ENDP    

END MAIN    
