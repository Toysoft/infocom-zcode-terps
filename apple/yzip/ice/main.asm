	TITLE	"Apple ][ YZIP (c)Infocom","MAIN LOOP"

MLOOP:
	lda	#0	
	sta	NARGS	; reset number of args
	sta	PAGE2SW	; just do this for the heck of it
        lda     BNK2SET
        lda     BNK2SET
        
	jsr	NEXTPC	; get op code
	sta	OPCODE	; SAVE IT HERE

	IF	0	
;
; special debugging code
;
	lda	OPCODE
	JSR	DBG1
	LDA	#' '
	JSR	DBG2
	LDA	OPCODE
	ENDIF
;
; DECODE AN OPCODE
;
	tay		; set flags
	bmi	DC0	; IF POSITIVE,
	jmp	OP2	; IT'S A 2-OP
DC0:	cmp	#$B0	
	bcs	DC1	
	jmp	OP1	; OR MAYBE A 1-OP
DC1:	cmp	#$C0	
	bcs	OPEXT	
	jmp	OP0	; PERHAPS A 0-OP

; --------------
; HANDLE AN X-OP
; --------------

OPEXT:	CMP	#236		; XCALL?
	BNE	OPX5
	JMP	OPXCLL		; YES, PROCESS SEPARATELY
OPX5:	CMP	#250		; IXCALL
	BNE	OPX6
	JMP	OPXCLL
OPX6:	JSR	NEXTPC		; GRAB THE ARGUMENT ID BYTE
	STA	ABYTE		; HOLD IT HERE
	LDX	#0
	STX	ADEX		; INIT ARGUMENT INDEX
	BEQ	OPX1		; JUMP TO TOP OF LOOP
OPX0:	LDA	ABYTE		; GET ARG BYTE
	ASL	A		; SHIFT NEXT 2 ARG BITS
	ASL	A		; INTO BITS 7 & 6
	STA	ABYTE		; HOLD FOR LATER
OPX1:	AND	#%11000000	; MASK OUT GARBAGE BITS
	BNE	OPX2
	JSR	GETLNG		; 00 = LONG IMMEDIATE
	JMP	OPXNXT
OPX2:	CMP	#%01000000	; IS IT A SHORT IMMEDIATE?
	BNE	OPX3		; NO, KEEP GUESSING
	JSR	GETSHT		; 01 = SHORT IMMEDIATE
	JMP	OPXNXT
OPX3:	CMP	#%10000000	; LAST TEST
	BNE	OPX4		; 11 = NO MORE ARGUMENTS
	JSR	GETVAR		; 10 = VARIABLE
OPXNXT:	LDX	ADEX		; RETRIEVE ARGUMENT INDEX
	LDA	VALUE+LO	; GRAB LSB OF VALUE
	STA	ARG1+LO,X	; STORE IN ARGUMENT TABLE
	LDA	VALUE+HI	; GRAB MSB OF VALUE
	STA	ARG1+HI,X	; STORE THAT, TOO
	INC	NARGS		; UPDATE ARGUMENT COUNTER
	INX
	INX
	STX	ADEX		; UPDATE INDEX
	CPX	#8		; DONE 4 ARGUMENTS YET?
	BCC	OPX0		; NO, GET SOME MORE

	; ALL X-OP ARGUMENTS READY

OPX4:	LDA	OPCODE		; IS THIS
	CMP	#$E0		; AN EXTENDED 2-OP?
	BCS	DOXOP		; NO, IT'S A REAL X-OP
	CMP	#$C0		; IS IT NEW OPCODE RANGE?
	BCC	ZEXTOP		; YES
	JMP	OP2EX		; ELSE TREAT IT LIKE A 2-OP

DOXOP:	AND	#%00011111	; ISOLATE ID BITS
	TAY
	LDA	OPTXL,Y
	STA	GOX+1+LO
	LDA	OPTXH,Y
	STA	GOX+1+HI
GOX:	JSR	$FFFF		;DUMMY
	JMP	MLOOP

	; HANDLE EXTENDED OPCODE RANGE OPS

ZEXTOP:	CMP	#EXTLEN		; OUT OF RANGE?
	BCS	BADEXT
	TAY			; OFFSET ALREADY CORRECT
	LDA	EXTOPL,Y
	STA	GOE+1+LO
	LDA	EXTOPH,Y
	STA	GOE+1+HI
GOE:	JSR	$FFFF		;DUMMY
	JMP	MLOOP

	; *** ERROR #1 -- ILLEGAL X-OP ***

BADOPX:	LDA	#1
	JMP	ZERROR

	; *** ERROR #16 -- ILLEGAL EXTENDED RANGE X-OP ***

BADEXT:	LDA	#16
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
	BNE	XCALL5
	JMP	OPX4		; DONE, GO DO IT
XCALL5:	CPX	#8		; DONE 1ST MODE BYTE?
	BNE	XCALL1		; NOT QUITE YET
	LDA	BBYTE		; SET UP FOR NEXT
	STA	ABYTE		; MODE BYTE
	JMP	XCALL2		; GO DO IT

; -------------
; HANDLE A 0-OP
; -------------

OP0:	CMP	#190		; IS IT EXTOP OP
	BEQ	EXTOP		; YES
	AND	#%00001111	; ISOLATE 0-OP ID BITS
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

	; THIS OPCODE TELLS THAT NEXT OP IS PART OF THE
	; EXTENDED RANGE OF OPCODES, GET IT AND PROCESS IT
	; (THEY ARE ALL XOPS)

EXTOP:	JSR	NEXTPC		; GO GET EXTENDED RANGE OP
	STA	OPCODE		; SAVE IT
	JMP	OPEXT		; AND HANDLE IT


; -------------
; HANDLE A 1-OP
; -------------

OP1:
	and	#%00110000	; ISOLATE ARGUMENT BITS
	bne	OP1A	
	jsr	NEXTPC		; get next byte
	tay
	jmp	OP1A1	
OP1A:	and	#%00100000	; TEST AGAIN
	bne	OP1B	
;
; 01 = SHORT IMMEDIATE
;
OP1A1:	sta	ARG1+HI	
	jsr	NEXTPC
	sta	ARG1+LO	
	inc	NARGS	
	jmp	OP1EX1	
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
;
; 0 = SHORT IMMEDIATE
;
	sta	ARG1+HI	
	jsr	NEXTPC
	sta	ARG1+LO	
	inc	NARGS	
	jmp	OP2B1	
OP2A:	jsr	GETVAR	; 1 = VARIABLE
OP2B:	jsr	V2A1	; [VALUE] TO [ARG1], UPDATE [NARGS]
OP2B1:	lda	OPCODE	; RESTORE OPCODE BYTE
	and	#%00100000	; ISOLATE 2ND ARG BIT
	bne	OP2C	
	sta	ARG2+HI	
	jsr	NEXTPC
	sta	ARG2+LO	
	jmp	OP2D1	
OP2C:	jsr	GETVAR	; 1 = VARIABLE
OP2D:	lda	VALUE+LO	; MOVE 2ND [VALUE]
	sta	ARG2+LO	; INTO [ARG2]
	lda	VALUE+HI	
	sta	ARG2+HI	
OP2D1:	inc	NARGS	; UPDATE ARGUMENT COUNT

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

