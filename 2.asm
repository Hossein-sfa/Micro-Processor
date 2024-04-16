.MODEL SMALL
.STACK 64

.DATA               
    BUF1       DB     10, ?, 10 DUP(24H)  ; Name 
    BUF2       DB     5, ?, 5 DUP(36)     ; Number
    BUF3       DB     5, ?, 5 DUP(36)     ; Number 2 
    BUF4       DB     4, ?, 5 DUP(0)      ; Input
    BUF5       DB     5, ?, 5 DUP(0)      ; User score in string
    BUF6       DB     7, ?, 7 DUP(24H)    ; Result in buffer
    TWO        DW     2                   ; 2  
    FLAG       DB     0                   ; For sign 
    SEED       DW     ?                   ; User seed
    SCORE      DW     0                   ; User score    
    HEART      DW     3                   ; User heart
    TEN        DB     0AH                 ; 10
    TEN_WORD   DW     10D                 ; 10 in word 
    RESULT     DW     0                   ; Result of the operation     
    NUM1       DW     ?                   ; First random number 
    NUM2       DW     ?                   ; Second random number
    COUNTER    DW     0                   ; Counter for input  
    TEMP_NUM   DW     0                   ; Temp input
    CURSOR_I   DB     10                  ; Store last cursor for input 
    CURSOR_P   DB     0                   ; Store last cursor for progress bar
    CNT        DW     0

.CODE
    MAIN PROC FAR
        MOV AX, @DATA
        MOV DS, AX                        ; Initialize DS   
        CALL INPUT_SEED                   ; Input seed
        MOV SEED, BX  
        CALL NEXT_LINE     
        MOV AH, 0AH                       ; Input a name from keyboard
        MOV DX, OFFSET BUF1               ; Address of the buffer
        INT 21H
        CALL NEXT_LINE        
        TRUE:                             ; While true
        MOV COUNTER, 0
        MOV TEMP_NUM, 0
        MOV SI, OFFSET BUF4
        MOV [SI], 0
        MOV [SI+1], 0 
        MOV [SI+2], 0  
        MOV [SI+3], 0
        MOV SI, OFFSET BUF6
        MOV [SI], 24H
        MOV [SI+1], 24H 
        MOV [SI+2], 24H 
        MOV [SI+3], 24H
        MOV [SI+4], 24
        MOV CNT, 0  
        MOV CURSOR_I, 10
        MOV CURSOR_P, 0
        MOV FLAG, 0                       ; Clear variables
        CALL RANDOM                       ; Generate first random number
        MOV NUM1, DX
        MOV BX, OFFSET BUF2               ; Save first random number to buffer
        CALL SAVE_TO_BUFFER                      
        CALL RANDOM                       ; Generate second random
        MOV NUM2, DX
        MOV BX, OFFSET BUF3               ; Save second random number to buffer
        CALL SAVE_TO_BUFFER  
        CALL PRINT_SCORE                  ; Print user score
        MOV DX, OFFSET BUF2               ; First random number
        CALL PRINT_STRING                 ; Print first random number
        MOV AX, SEED 
        SUB DX, DX                        ; Clear DX
        DIV TWO
        CMP DX, 00
        JNE NEGATIVE
        MOV AX, NUM1
        ADD AX, NUM2
        MOV RESULT, AX
        MOV DL, '+'                       ; ASSCI code of +
        CALL PRINT_CHAR
        JMP AFTER
        NEGATIVE:
        MOV AX, NUM1
        SUB AX, NUM2
        MOV RESULT, AX
        MOV DL, '-'                       ; ASCII code of -
        CALL PRINT_CHAR                   ; Print - or + randomly
        AFTER: 
        MOV DX, OFFSET BUF3               ; Print second random number
        CALL PRINT_STRING              
        MOV DL, '='                       ; ASCII code of =
        CALL PRINT_CHAR 
        TURN:
        MOV AH, 01                        ; Checks if a key is pressed
        INT 16h
        JNZ INPUT                         ; Input user number
        BACK:
        CALL PROGRESS_BAR                 ; Print progress bar
        JMP TURN:
        CHECK_RESULT:                     ; Checks if user input is true
        MOV BX, TEMP_NUM    
        CMP FLAG, 1                       ; Foe negeative input
        JNE OK             
        NEG BX
        OK:                             
        CMP BX, RESULT
        JE CORRECT                        ; Check correctness of input
        DEC HEART                         ; Lose 1 heart if incorrect
        CALL GET_CURSOR
        MOV DL, 10
        CALL SET_CURSOR                   ; Set cursor to left for incorrect answer
        CALL PRINT_WRONG                  ; Make user input red
        CALL PRINT_ANSWER                 ; Print correct answer                          
        JMP THERE
        CORRECT:
        CALL GET_CURSOR
        MOV DL, 10
        CALL SET_CURSOR                   ; Set cursor to left for incorrect answer
        CALL PRINT_RIGHT                  ; Make user input green              
        ADD SCORE, 40
        MOV SI, CNT
        SUB SCORE, SI                     ; Calculate score depend on time
        THERE:       
        CALL NEXT_LINE 
        CALL GET_CURSOR
        CMP DH, 24  
        JNE NEED
        CALL SCROLL                       ; Scroll screen if needed
        NEED:
        CMP HEART, 0 
        JLE ENDPROG                       ; When user loses
        JMP TRUE  
        ENDPROG:
        MOV AH,4CH
        INT 21H                           ; End of program
    MAIN ENDP      
    
    INPUT PROC                            ; Char is in AL    
        MOV AH, 0                         ; Checks what key is pressed
        INT 16h    
        CMP AL, 08                        ; ASCII code of backspace     
        MOV DL, AL
        CALL PRINT_CHAR          
        SUB CX, CX                        ; Reset CX
        SUB BX, BX                        ; Reset BX
        SUB AH, AH                        ; Reset AH
        CMP AL, 0DH                       ; ASCII code of enter
        JE ENDINPUT 
        CMP AL, '-'
        JNE GO_BACK:
        MOV FLAG, 1
        INC CURSOR_I
        JMP WHILE
        GO_BACK:
        CMP AL, 08H                       ; ASCII code of backspace
        JNE GET
        CMP COUNTER, 0
        JNE POSITIVE
        MOV FLAG, 0 
        CALL GET_CURSOR         
        CALL SET_CURSOR         
        MOV DL, ' '                                 
        CALL PRINT_CHAR  
        CALL GET_CURSOR    
        DEC DL
        DEC CURSOR_I                   
        CALL SET_CURSOR
        JMP WHILE
        POSITIVE:       
        CALL GET_CURSOR 
        CALL SET_CURSOR 
        MOV DL, ' '                       ; Remove number           
        CALL PRINT_CHAR
        CALL GET_CURSOR    
        DEC DL   
        DEC CURSOR_I                 
        CALL SET_CURSOR
        MOV SI, OFFSET BUF4
        ADD SI, COUNTER
        MOV AX, [SI]
        ADD CX, TEMP_NUM
        SUB CX, AX
        ADD CX, 30H
        MOV AX, TEMP_NUM   
        SUB DX, DX
        DIV TEN_WORD
        MOV CX, AX  
        MOV TEMP_NUM, CX
        DEC COUNTER 
        DEC SI 
        MOV [SI], 00H
        JMP WHILE
        GET:           
        MOV SI, OFFSET BUF4 
        ADD SI, COUNTER
        MOV [SI], AX
        INC COUNTER
        MOV CX, TEMP_NUM
        MOV AX, CX 
        MUL TEN_WORD
        MOV SI, OFFSET BUF4
        ADD SI, COUNTER
        DEC SI
        ADD AX, [SI]
        SUB AX, 30H
        MOV CX, AX 
        MOV TEMP_NUM, CX 
        INC CURSOR_I 
        JMP WHILE
        ENDINPUT:
        JMP CHECK_RESULT
        ENDPROC:
        MOV BX, TEMP_NUM
        WHILE:
        JMP BACK
    INPUT ENDP                            ; Input is in BX
    
    INPUT_SEED PROC                       ; Char is in AL  
        SUB CX, CX                        ; Reset CX
        WHILE_S:
        SUB BX, BX    
        MOV AH, 01                        ; Input one char
        INT 21H
        SUB AH, AH                        ; Reset AH
        CMP AL, 0DH                       ; ASCII code of enter
        JE ENDINPUT_S 
        CMP AL, '-'                       ; ASCII code of -
        JNE BACK_S:
        MOV FLAG, 1
        JMP WHILE_S
        BACK_S:
        CMP AL, 08H                       ; ASCII code of backspace
        JNE GET_S
        CMP COUNTER, 0
        JNE POSITIVE_S
        MOV FLAG, 0 
        CALL GET_CURSOR         
        CALL SET_CURSOR         
        MOV DL, ' '                                 
        CALL PRINT_CHAR  
        CALL GET_CURSOR    
        DEC DL                    
        CALL SET_CURSOR
        JMP WHILE_S
        POSITIVE_S:                   
        MOV TEMP_NUM, CX
        CALL GET_CURSOR 
        MOV CX, TEMP_NUM
        CALL SET_CURSOR 
        MOV CX, TEMP_NUM
        MOV TEMP_NUM, CX
        MOV DL, ' '                       ; Remove number           
        CALL PRINT_CHAR
        MOV TEMP_NUM, CX
        CALL GET_CURSOR 
        MOV CX, TEMP_NUM  
        DEC DL                    
        CALL SET_CURSOR
        MOV SI, OFFSET BUF4
        ADD SI, COUNTER
        MOV AX, [SI]
        ADD CX, TEMP_NUM
        SUB CX, AX
        ADD CX, 30H
        MOV AX, TEMP_NUM   
        SUB DX, DX
        DIV TEN_WORD
        MOV CX, AX  
        MOV TEMP_NUM, CX
        DEC COUNTER 
        DEC SI 
        MOV [SI], 00H
        JMP WHILE_S
        GET_S:           
        MOV SI, OFFSET BUF4 
        ADD SI, COUNTER
        MOV [SI], AX
        INC COUNTER
        MOV CX, TEMP_NUM
        MOV AX, CX 
        MUL TEN_WORD
        MOV SI, OFFSET BUF4
        ADD SI, COUNTER
        DEC SI
        ADD AX, [SI]
        SUB AX, 30H
        MOV CX, AX 
        MOV TEMP_NUM, CX  
        JMP WHILE_S
        ENDINPUT_S:
        CMP FLAG, 1
        JNE ENDPROC_S
        MOV BX, TEMP_NUM  
        NEG BX
        RET
        ENDPROC_S:
        MOV BX, TEMP_NUM
        RET
    INPUT_SEED ENDP                       ; Input is in BX
    
    RANDOM PROC                           ; Random number is in DX
        MOV AX, SEED   
        MOV CX, 11021D                    ; Multiplier
        MOV DX, 2213D                     ; Increment
        MOV BX, 5000h                     ; Modulus
        MUL CX                            ; Ax = Ax * Cx
        ADD AX, DX      
        SUB DX, DX                        ; Rest DX
        DIV BX                            ; (Remainder is the random number) DX between 0 and 7FFF
        MOV SEED, DX                      ; Update seed
        MOV AX, DX
        MOV BX, 10000D                    ; random num between 0-10000
        SUB DX, DX                         ; Reset DX
        DIV BX  
        RET
    RANDOM ENDP
    
    NEXT_LINE PROC                        ; Move cursor to next line
        CALL GET_CURSOR
        INC DH                            ; Go to nex row
        SUB DL, DL                        ; Column zero
        CALL SET_CURSOR
        RET
    NEXT_LINE ENDP  

    PRINT_CHAR PROC                       ; Print char in DL without color 
        MOV AH, 02                        ; Write character
        INT 21H
        RET       
    PRINT_CHAR ENDP
    
    PRINT_CHAR_COLOR PROC                 ; Print character in AL with color
        MOV AH, 09                        ; Write character
        MOV BH, 00                        ; Page 0                             
        MOV CX, 1                         ; Repeat 1 times
        INT 10H 
        CALL GET_CURSOR
        INC DL
        CALL SET_CURSOR                   ; Move curosr to forward
        RET   
    PRINT_CHAR_COLOR ENDP
    
    PRINT_RIGHT PROC                      ; Print user answer in Green color
        CMP RESULT, 0                     ; For negeative result
        JG HE                             
        MOV AL, '-'
        MOV BL, 02                        ; Green color  
        CALL PRINT_CHAR_COLOR
        HE: 
        MOV BX, OFFSET BUF6     
        MOV DX, TEMP_NUM  
        CALL SAVE_TO_BUFFER_2             ; Save user input in buffer
        MOV SI, OFFSET BUF6
        MOV BL, 02                        ; Green color      
        PLOOP:      
        MOV AL, [SI]                      ; ASCII code
        CALL PRINT_CHAR_COLOR 
        INC SI          
        CMP [SI], 24h
        JE END       
        JMP PLOOP 
        END:
        CALL NEXT_LINE      
        RET
    PRINT_RIGHT ENDP

    PRINT_WRONG PROC                 
        CMP FLAG, 1                       ; For negeative input
        JNE NOPE   
        MOV AL, '-' 
        MOV Bl, 04                        ; Red color
        CALL PRINT_CHAR_COLOR
        NOPE: 
        MOV BX, OFFSET BUF6
        MOV DX, TEMP_NUM  
        CALL SAVE_TO_BUFFER_2 
        MOV SI, OFFSET BUF6               ; Save user input to buffer
        MOV BL, 04                        ; Red color        
        MYLOOP:      
        MOV AL, [SI]
        CALL PRINT_CHAR_COLOR 
        INC SI          
        CMP [SI], 24h
        JE MYEND       
        JMP MYLOOP 
        MYEND:        
        RET
    PRINT_WRONG ENDP
    
    PRINT_ANSWER PROC                     ; Print correct answer in yellow
        CALL GET_CURSOR
        MOV DL, 30
        CALL SET_CURSOR
        CMP RESULT, 0                     ; For negative result
        JG NO
        NEG RESULT 
        MOV AL, '-' 
        MOV Bl, 14                        ; Yellow color
        CALL PRINT_CHAR_COLOR
        NO:   
        MOV BX, OFFSET BUF6 
        MOV DX, RESULT  
        CALL SAVE_TO_BUFFER_2             ; Save result to buffer
        MOV SI, OFFSET BUF6
        MOV BL, 14                        ; Yellow color        
        WH:      
        MOV AL, [SI]                      ; ASCII code
        NOO:
        CALL PRINT_CHAR_COLOR 
        INC SI          
        CMP [SI], 24h
        JE FINISH       
        JMP WH 
        FINISH:
        CALL NEXT_LINE       
        RET
    PRINT_ANSWER ENDP
    
    PRINT_STRING PROC
        MOV AH, 09                        ; Display a string
        INT 21H
        RET
    PRINT_STRING ENDP 
        
    PRINT_SCORE PROC
        CALL GET_CURSOR
        MOV DL, 60
        CALL SET_CURSOR                   ; Move cursor to right
        MOV DX, OFFSET BUF1
        ADD DX, 2
        CALL PRINT_STRING                 ; Print name of user
        CALL GET_CURSOR
        MOV DL, [BUF1 + 1]                ; Size of name
        ADD DL, 60  
        CALL SET_CURSOR       
        MOV DL, ':'                       
        CALL PRINT_CHAR  
        MOV DX, SCORE
        MOV BX, OFFSET BUF5               ; Save score to buffer
        CALL SAVE_TO_BUFFER
        MOV DX, OFFSET BUF5
        CALL PRINT_STRING                 ; Print score
        CALL GET_CURSOR
        SUB DL, DL                        ; Reset DL
        CALL SET_CURSOR                   ; Move cursor to first of the line
        RET
    PRINT_SCORE ENDP
    
    SAVE_TO_BUFFER PROC                
        MOV AX, DX
        MOV CX, 1000D
        SUB DX, DX
        DIV CX     
        ADD AX, 30H
        MOV [BX], AX
        MOV AX, DX
        MOV CX, 100D
        SUB DX, DX
        DIV CX
        ADD AX, 30H 
        MOV [BX] + 1, AX
        MOV AX, DX
        MOV CX, 10D
        SUB DX, DX
        DIV CX  
        ADD AX, 30H
        MOV [BX] + 2, AX  
        ADD DX, 30H
        MOV [BX] + 3, DX
        MOV [BX] + 4, 36D
        RET
    SAVE_TO_BUFFER ENDP
    
    SAVE_TO_BUFFER_2 PROC
        MOV AX, DX
        MOV CX, 10000D
        SUB DX, DX
        DIV CX     
        ADD AX, 30H
        MOV [BX], AX
        MOV AX, DX
        MOV CX, 1000D
        SUB DX, DX
        DIV CX     
        ADD AX, 30H
        MOV [BX] + 1, AX
        MOV AX, DX
        MOV CX, 100D
        SUB DX, DX
        DIV CX
        ADD AX, 30H 
        MOV [BX] + 2, AX
        MOV AX, DX
        MOV CX, 10D
        SUB DX, DX
        DIV CX  
        ADD AX, 30H
        MOV [BX] + 3, AX  
        ADD DX, 30H
        MOV [BX] + 4, DX
        MOV [BX] + 5, 36D
        RET
    SAVE_TO_BUFFER_2 ENDP
    
    GET_CURSOR PROC                       ; DH, DL are row, column
        MOV AH, 03                        ; Get cursor position
        MOV BH, 00                        ; Page number
        INT 10H
        RET
    GET_CURSOR ENDP  

    SET_CURSOR PROC                       ; DH, DL are row, column
        MOV AH, 02                        ; Set cursor position
        MOV BH, 00                        ; Page number
        INT 10H
        RET
    SET_CURSOR ENDP
    
    PROGRESS_BAR PROC     
        CALL GET_CURSOR              
        MOV DL, CURSOR_P                  ; Last cursor of progress bar
        INC DH 
        CALL SET_CURSOR       
        MOV AL, '#'                    
        CMP CNT, 13     
        JBE GREEN
        CMP CNT, 26
        JBE YELLOW
        MOV BL, 04                        ; Red
        JMP END_IF
        YELLOW:
        MOV BL, 06                        ; Yellow
        JMP END_IF
        GREEN:
        MOV BL, 02                        ; Green  
        END_IF:
        CALL PRINT_CHAR_COLOR
        MOV CX, 40                        ; Delay loop counter
        DELAY_LOOP:
        LOOP DELAY_LOOP                   ; Decrement CX and loop until CX = 0
        INC CNT
        INC CURSOR_P
        CMP CNT, 40
        INC DL                            ; Column  
        CALL GET_CURSOR 
        MOV DL, CURSOR_I                  ; Restore cursor of input
        DEC DH
        CALL SET_CURSOR 
        JB END_PROG
        DEC HEART                         ; Timeout 
        CALL PRINT_ANSWER 
        JMP THERE   
        END_PROG:    
        RET    
    PROGRESS_BAR ENDP  
    
    SCROLL PROC
        MOV AH, 06                        ; Scrolls a specified window upward a number of lines
        MOV AL, 2                         ; Number of lines to scroll (00: entire screen)
        MOV BH, 07                        ; Display attribute for blank lines (color)
        MOV CH, 00                        ; Row number of upper left corner
        MOV CL, 00                        ; Column number of upper left corner
        MOV DH, 24                        ; Row number of lower right corner
        MOV DL, 79                        ; Column number of lower right corner
        INT 10H  
        CALL GET_CURSOR
        MOV DH, 22                        ; Set cursor to last empty line
        CALL SET_CURSOR   
        RET
    SCROLL ENDP
    
END MAIN
