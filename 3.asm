	EXPORT __main
	AREA MYCODE, CODE, READONLY
__main PROC
	MOV R1, #0x2     	; Start number 
	MOV R2, #0x0     	; Counter
LOOP				 	; Main loop of program
	MOV R3, #0x2     	; Start from 2 for prime checking
PRIME_LOOP
	CMP R1, #0x2	 	; Number 2 is prime and palidnrome
	BEQ YES			 	; Save into memory
	MOV R4, R1		 	; Save value of R1 into R4
DIV					 	; Checks for ramaining of division with subtraction
	SUB R4, R3
	CMP R4, #0x0
	BEQ NO			 	; Not prime
	BGT DIV
	ADD R3, #0x1	 	; Increase the number for prime checking
	CMP R3, R1
	BLT PRIME_LOOP	 	; While the number is less than 
	MOV R5, #0x0		; Make R5 zero
	MOV R4, R1
	MOV R6, R1		 	; Save R1 into R4, R6
	CMP R4, #0xA
	BLT YES			 	; Numbers less than 10 are palindrome
PAL
	CMP R4, #0xA
	BLT HERE
	SUB R4, #0xA
	B PAL				; Get last digit	 
HERE	
	MOV R7, #0xA     	; Store 10 in R7
	SDIV R6, R6, R7
	MLA R5, R5, R7, R4
	MOV R4, R6
	CMP R6, #0x0	 	; Chwcks if everse of number is computed
	BNE PAL
	CMP R1, R5			; Check the number equals to it's reverse
	BNE NO				; Not palindrome
YES
	PUSH {R1}	  	 	; Save to stack
	ADD R2, #0x1	 	; Increase number for finding 
	CMP R2, #0xA     	; 10 numbers condition
	BEQ FINISH		 	; 10 Prime and palindrome numbers are found
NO
	ADD R1, #0x1	 	; Increase number
	B LOOP
FINISH 			     	; End of program
	ENDP	
END
		
