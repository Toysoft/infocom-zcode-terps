	PAGE	
	SBTTL "--- MAIN LOOP ---"

MLOOP:	LDA	#0	
	STA	NARGS	; RESET # ARGUMENTS
	JSR	NEXTPC
	STA	OPCODE	; SAVE IT HERE

	IF	DEBUG
	LDA	ZPCPNT+HI
	STA	BONE
	LDA	ZPCPNT+LO
	STA	BTWO
	LDA	MPCPNT+HI
	STA	BTHREE
	LDA	MPCPNT+LO
	STA	BFOUR
	LDA	#0	; BREAKPOINT #0
	JSR	DOBUG	
	LDA	OPCODE	
	TAY		
	ENDIF		

	; DECODE AN OPCODE

	BMI	DC0	; IF POSITIVE,
	JMP	OP2	; IT'S A 2-OP
DC0:	CMP	#$B0	
	BCS	DC1	
	JMP	OP1	; OR MAYBE A 1-OP
DC1:	CMP	#$C0	
	BCS	OPEXT	
	JMP	OP0	; PERHAPS A 0-OP


; --------------
; HANDLE AN X-OP
; --------------

OPEXT:	CMP	#236	; XCALL?
	BEQ	OPXCLL	; YES, PROCESS SEPARATELY
	JSR	NEXTPC	; GRAB THE ARGUMENT ID BYTE
	STA	ABYTE	; HOLD IT HERE
	LDX	#0	
	STX	ADEX	; INIT ARGUMENT INDEX
	BEQ	OPX1	; JUMP TO TOP OF LOOP
OPX0:	LDA	ABYTE	; GET ARG BYTE
	ASL	A	; SHIFT NEXT 2 ARG BITS
	ASL	A	; INTO BITS 7 & 6
	STA	ABYTE	; HOLD FOR LATER
OPX1:	AND	#%11000000	; MASK OUT GARBAGE BITS
	BNE	OPX2	
	JSR	GETLNG	; 00 = LONG IMMEDIATE
	JMP	OPXNXT	
OPX2:	CMP	#%01000000	; IS IT A SHORT IMMEDIATE?
	BNE	OPX3	; NO, KEEP GUESSING
	JSR	GETSHT	; 01 = SHORT IMMEDIATE
	JMP	OPXNXT	
OPX3:	CMP	#%10000000	; LAST TEST
	BNE	OPX4	; 11 = NO MORE ARGUMENTS
	JSR	GETVAR	; 10 = VARIABLE
OPXNXT:	LDX	ADEX	; RETRIEVE ARGUMENT INDEX
	LDA	VALUE+LO	; GRAB LSB OF VALUE
	STA	ARG1+LO,X	; STORE IN ARGUMENT TABLE
	LDA	VALUE+HI	; GRAB MSB OF VALUE
	STA	ARG1+HI,X	; STORE THAT, TOO
	INC	NARGS	; UPDATE ARGUMENT COUNTER
	INX		
	INX		
	STX	ADEX	; UPDATE INDEX
	CPX	#8	; DONE 4 ARGUMENTS YET?
	BCC	OPX0	; NO, GET SOME MORE

	; ALL X-OP ARGUMENTS READY

OPX4:	LDA	OPCODE	; IS THIS
	CMP	#$E0	; AN EXTENDED 2-OP?
	BCS	DOXOP	; NO, IT'S A REAL X-OP
	JMP	OP2EX	; ELSE TREAT IT LIKE A 2-OP
DOXOP:	AND	#%00011111	; ISOLATE 0-OP ID BITS
	TAY		
	LDA	OPTXL,Y	
	STA	GOX+1+LO	
	LDA	OPTXH,Y	
	STA	GOX+1+HI	
GOX:	JSR	$FFFF	;DUMMY
	JMP	MLOOP	

	; *** ERROR #1 -- ILLEGAL X-OP ***

BADOPX:	LDA	#1	
	JMP	ZERROR	

	; HANDLE AN XCALL OPCODE

OPXCLL:	JSR	NEXTPC	; GET 2 MODE BYTES
	STA	ABYTE	
	JSR	NEXTPC	
	STA	BBYTE	
	LDA	ABYTE	; ONE TO START WITH
	LDX	#0	
	STX	ADEX	; INIT ARGUMENT INDEX
	BEQ	XCALL2	; ALWAYS JUMP TO TOP OF LOOP
XCALL1:	LDA	ABYTE	; GET ARG BYTE
	ASL	A	; SHIFT NEXT 2 BITS
	ASL	A	; INTO BITS 7 & 6
	STA	ABYTE	; HOLD FOR LATER
XCALL2:	AND	#%11000000	; MASK OUT GARBAGE
	BNE	XCALL3	
	JSR	GETLNG	; 00 = LONG IMMEDIATE
	JMP	XCNXT	
XCALL3:	CMP	#%01000000	; SHORT IMMED?
	BNE	XCALL4	; NO, TRY ANOTHER
	JSR	GETSHT	; 01 = SHORT IMMED.
	JMP	XCNXT	
XCALL4:	CMP	#%10000000	; LAST TEST
	BNE	OPX4	; 11 = NO MORE ARGS
	JSR	GETVAR	; 10 = VARIABLE
XCNXT:	LDX	ADEX	
	LDA	VALUE+LO	
	STA	ARG1+LO,X	
	LDA	VALUE+HI	
	STA	ARG1+HI,X	
	INC	NARGS	
	INX		
	INX		
	STX	ADEX	
	CPX	#16	
	BEQ	OPX4	; DONE, GO DO IT
	CPX	#8	; DONE 1ST MODE BYTE?
	BNE	XCALL1	; NOT QUITE YET
	LDA	BBYTE	; SET UP FOR NEXT
	STA	ABYTE	; MODE BYTE
	JMP	XCALL2	; GO DO IT



; -------------
; HANDLE A 0-OP
; -------------

OP0:	AND	#%00001111	; ISOLATE 0-OP ID BITS
	TAY		
	LDA	OPT0L,Y	
	STA	GO0+1+LO	
	LDA	OPT0H,Y	
	STA	GO0+1+HI	
GO0:	JSR	$FFFF	;DUMMY
	JMP	MLOOP	

	; *** ERROR #2 -- ILLEGAL 0-OP ***

BADOP0:	LDA	#2	
	JMP	ZERROR	



; -------------
; HANDLE A 1-OP
; -------------

OP1:	AND	#%00110000	; ISOLATE ARGUMENT BITS
	BNE	OP1A	

	;JSR GETLNG ; 00 = LONG IMMEDIATE

	JSR	NEXTPC
	JMP	OP1A1	
OP1A:	AND	#%00100000	; TEST AGAIN
	BNE	OP1B	

	;JSR GETSHT ; 01 = SHORT IMMEDIATE

OP1A1:	STA	ARG1+HI	
	JSR	NEXTPC
	STA	ARG1+LO	
	INC	NARGS	
	JMP	OP1EX1	
OP1B:	JSR	GETVAR	; 10 = VARIABLE
OP1EX:	JSR	V2A1	; MOVE [VALUE] TO [ARG1], UPDATE [NARGS]
OP1EX1:	LDA	OPCODE	
	AND	#%00001111	; ISOLATE 0-OP ID BITS
	TAY		
	LDA	OPT1L,Y	
	STA	GO1+1+LO	
	LDA	OPT1H,Y	
	STA	GO1+1+HI	
GO1:	JSR	$FFFF	;DUMMY
	JMP	MLOOP	

; *** ERROR #3 -- ILLEGAL 1-OP ***

BADOP1:	LDA	#3	
	JMP	ZERROR	



; -------------
; HANDLE A 2-OP
; -------------

OP2:	AND	#%01000000	; ISOLATE 1ST ARG BIT
	BNE	OP2A	

	;JSR GETSHT ; 0 = SHORT IMMEDIATE

	STA	ARG1+HI	
	JSR	NEXTPC
	STA	ARG1+LO	
	INC	NARGS	
	JMP	OP2B1	
OP2A:	JSR	GETVAR	; 1 = VARIABLE
OP2B:	JSR	V2A1	; [VALUE] TO [ARG1], UPDATE [NARGS]
OP2B1:	LDA	OPCODE	; RESTORE OPCODE BYTE
	AND	#%00100000	; ISOLATE 2ND ARG BIT
	BNE	OP2C	

	;JSR GETSHT ; 0 = SHORT IMMEDIATE

	STA	ARG2+HI	
	JSR	NEXTPC
	STA	ARG2+LO	
	JMP	OP2D1	
OP2C:	JSR	GETVAR	; 1 = VARIABLE
OP2D:	LDA	VALUE+LO	; MOVE 2ND [VALUE]
	STA	ARG2+LO	; INTO [ARG2]
	LDA	VALUE+HI	
	STA	ARG2+HI	
OP2D1:	INC	NARGS	; UPDATE ARGUMENT COUNT

	; EXECUTE A 2-OP OR EXTENDED 2-OP

OP2EX:	LDA	OPCODE	
	AND	#%00011111	; ISOLATE 0-OP ID BITS
	TAY		
	LDA	OPT2L,Y	
	STA	GO2+1+LO	
	LDA	OPT2H,Y	
	STA	GO2+1+HI	
GO2:	JSR	$FFFF	;DUMMY
	JMP	MLOOP	

; *** ERROR #4 -- ILLEGAL 2-OP ****

BADOP2:	LDA	#4	
	JMP	ZERROR	



; --------------------------------------
; MOVE [VALUE] TO [ARG1], UPDATE [NARGS]
; --------------------------------------

V2A1:	LDA	VALUE+LO
	STA	ARG1+LO
	LDA	VALUE+HI
	STA	ARG1+HI
	INC	NARGS
	RTS

	END
