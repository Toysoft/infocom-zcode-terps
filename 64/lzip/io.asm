	PAGE	
	SBTTL "--- GAME I/O: C128 ---"

; --------------
; INTERNAL ERROR
; --------------
; ENTRY: ERROR CODE IN [A]
; EXIT: HA!

ERRM:	DB	"Internal error "
ENUMB:	DB	"00.  "
ERRML	EQU	$-ERRM

ZERROR:	LDY	#1		; CONVERT ERROR BYTE IN [A]
ZERR0:	LDX	#0		; TO ASCII AT "ENUMB"
ZERR1:	CMP	#10
	BCC	ZERR2
	SBC	#10
	INX
	BNE	ZERR1
ZERR2:	ORA	#'0'
	STA	ENUMB,Y
	TXA
	DEY
	BPL	ZERR0

;	JSR	ZCRLF		; CLEAR BUFFER (LC-A)
	LDX	#LOW ERRM
	LDA	#HIGH ERRM
	LDY	#ERRML
	JSR	DLINE		; PRINT ERROR MESSAGE

	; FALL THROUGH


; ----
; QUIT
; ----

ZQUIT:	JSR	ZCRLF		; FLUSH BUFFER

	LDX	#LOW ENDM
	LDA	#HIGH ENDM
	LDY	#ENDML
	JSR	DLINE		; "END OF SESSION"
	JMP	DOWARM


; -------
; RESTART
; -------

ZSTART:	JSR	ZCRLF		; FLUSH BUFFER
DOWARM:	LDA	FAST		; FAST-READ? (LC-A...)
	BEQ	DOW0		; NO
	JSR	FOFF		; ELSE DISENGAGE

DOW0: LDA	#'1'		; NEED SIDE 1 AGAIN
	STA	DSIDE
	LDA	#1		; SET FOR SUCCESS
	STA	SIDEFLG

	JSR	ASKFOR1
	BCC	DOW1
	JMP	DSKERR		; OOPS

DOW1: LDA	ZBEGIN+ZSCRIP+1	; SET CURRENT PRINTER STATUS
	AND	#%00000001	; SO RETAINED THRU RESTART
	STA	SFLAG		; (...LC-A)
	JMP	WARM1		; AND DO WARMSTART

ENDM:	DB	"End of session."
	DB	EOL
	DB	EOL
RSTRT:	DB	"Press [RETURN] to restart."
	DB	EOL
ENDML	EQU	$-ENDM
RSTRTL	EQU	$-RSTRT


; --------------------------
; RETURN TOP RAM PAGE IN [A]
; --------------------------

MEMTOP:	LDA	#PBEGIN-$10	; FOR NOW, ASSUME LAST "BUFFER"
	RTS			; OF AUX MEMORY


; -------------------
; Z-PRINT A CHARACTER
; -------------------
; ENTRY: ASCII CHAR IN [A]
;
; COMMENT: SCRIPTING IS HANDLED IN UNBUFR AND FLUSH,
; SO CAN OUTPUT TO PRINTER AS A LINE.  TABLE AND SCREEN
; OUTPUT IS SET UP HERE, HANDLED A BYTE AT A TIME
; (DIROUT CHANGES 6/24/85)

COUT:	STA	IOCHAR	; HOLD IT A SEC
	LDX	TABLEF	; OUTPUT TO TABLE?
	BEQ	COUT4	; NO
	JMP	TBLRTN	; YES, DO IT (TBL ONLY 4.7.86 Le)
COUT4:	LDX	SCREENF	; OUTPUT TO SCREEN?
	BNE	COUT5	; YES
	LDX	SCRIPTF	; OUTPUT TO PRINTER?
	BNE	COUT5	; YES
	RTS		; NO, SO DONE
COUT5:	LDA	IOCHAR	; RETRIEVE CHAR
	LDX	BUFFLG	; UNBUFFERED OUTPUT?
	BNE	UNBUFR	; YES, PLACE ON SCREEN IMMED.
	CMP	#EOL	; IF ASCII EOL,
	BNE	COUT0	
	JMP	ZCRLF	; DO IT
COUT0:	CMP	#SPACE	; IGNORE ALL OTHER
	BCC	CEX	; CONTROLS

COUT3:	LDX	CHRCNT	; GET LINE POINTER
	STA	LBUFF,X	; ADD CHAR TO BUFFER

	LDY	LENGTH	; GET LINE LENGTH COUNTER
	LDA	SPLITF	; (LC-A)
	BNE	COUT6	; (LC-A)
	CPY	#XSIZE	; END OF SCREEN LINE?
	BCC	COUT2
	JMP	FLUSH	; YES, FLUSH THE LINE

COUT6:	CPY	#TOPSIZ	; TOP SCREEN 1 LARGER (LC-A)
	BCS	COUT2	; (LC-A)
	JMP	FLUSH	; END OF LINE (LC-A)

COUT2:	INC	LENGTH	; ELSE UPDATE
	INC	CHRCNT	
CEX:	RTS		


; --------------------------
; DIRECT, UNBUFFERED DISPLAY
; --------------------------

UNBUFR:	STA	IOCHAR	; HOLD IN CASE NEED TO PRINT
	CMP	#SPACE	; IGNORE CONTROLS
	BCC	UNBEX	

	SEC
	JSR	PLOT
	LDA	SPLITF	; CHECK WHICH WINDOW
	BEQ	UNBBOT	; BOTTOM WINDOW

	CPY	#TOPSIZ	; CHECK IF BEYOND SCREEN (40 COL TOP LC-A)
	BCS	UNBEX	; YES, LEAVE
	CPX	SLINE	; CHECK IF WITHIN WINDOW
	BCS	UNBEX	; NO, JUST LEAVE
	BCC	UNBDIS	; YES, GO DISPLAY

UNBBOT:	CPY	#XSIZE	; CHECK IF BEYOND SCREEN
	BCS	UNBEX	; YES, LEAVE
	CPX	SLINE
	BCC	UNBEX	; NOT WITHIN WINDOW, LEAVE

UNBDIS:	LDA	SCREENF	; DISPLAY TO SCREEN?
	BEQ	UNBPRN	; NO, CHECK IF PRINTING
	LDA	IOCHAR	
	JSR	LETTER	; DO VOODOO AND DISPLAY

UNBPRN:	LDA	SPLITF	; SPLIT (NON-TEXT) SCREEN
	BNE	UNBEX	; DON'T PRINT

	;SEND CHAR TO PRINTER

	LDA	#1	; SET FOR PRINT RTN
	STA	PRLEN
	LDA	IOCHAR
	STA	LBUFF
	JSR	PPRINT	; AND GO ATTEMPT IT
	LDA	#0	; MAKE SURE NO LEFTOVER
	STA	PRLEN
UNBEX:	JMP	NEWLOG	; AND DISCONNECT SCREEN LINES (LC-A)


; ---------------
; OUTPUT TO TABLE
; ---------------

TBLRTN:	TAX			; HOLD CHAR A SEC.

	;PUT BYTE IN TABLE AT CURRENT OFFSET

	LDA	DIRITM+LO	; ADD IN OFFSET
	CLC		
	ADC	DIRTBL+LO	
	STA	I+LO	
	LDA	DIRITM+HI	
	ADC	DIRTBL+HI	
	STA	I+HI	
	LDY	#0	
	TXA			; PICK UP ASCII CHAR
	STA	(I),Y		; STORE IT IN TBL @ BYTE ALIGNED @

;SET ITM OFFSET TO NEXT POSITION, INCREMENT COUNTER

	INC	DIRITM+LO	; INC OFFSET TO NEXT BYTE
	BNE	TBLRTS	
	INC	DIRITM+HI	
TBLRTS:	RTS		


; -------------------
; FLUSH OUTPUT BUFFER
; -------------------
; ENTRY: LENGTH OF BUFFER IN [X]

FLUSH:	LDA	#SPACE		; SPACE
	STX	OLDEND		; SAVE CURRENT END OF LINE
FL0:	CMP	LBUFF,X		; FIND LAST SPACE CHAR
	BEQ	FL1		; IN THE LINE
	DEX
	BNE	FL0		; IF NONE FOUND,
	LDX	#XSIZE		; FLUSH ENTIRE LINE
	LDA	SPLITF		; (LC-A)
	BEQ	FL1		; (LC-A)
	LDX	#TOPSIZ		; TOP SCREEN 40 COL! (LC-A)
FL1:	STX	OLDLEN		; SAVE OLD LINE POS HERE
	STX	CHRCNT		; MAKE IT THE NEW LINE LENGTH
	JSR	ZCRLF		; PRINT LINE UP TO LAST SPACE

; START NEW LINE WITH REMAINDER OF OLD

	LDX	OLDLEN		; GET OLD LINE POS
	LDY	#0		; START NEW LINE AT BEGINNING
FL2:	INX		
	CPX	OLDEND		; CONTINUE IF
	BCC	FL3		; INSIDE OR
	BEQ	FL3		; AT END OF LINE
	STY	LENGTH		; ELSE SET NEW LINE LENGTH
	STY	CHRCNT	
	RTS		
FL3:	LDA	LBUFF,X		; GET CHAR FROM OLD LINE
	STA	LBUFF,Y		; MOVE TO START OF NEW LINE
	INY			; UPDATE LENGTH OF NEW LINE
	BNE	FL2		; (ALWAYS)


; ---------------
; CARRIAGE RETURN
; ---------------

ZCRLF:	LDX	CHRCNT	
	LDA	SPLITF
	BEQ	ZC0		; SCROLLING SCREEN

				; SCREEN 1 (TOP)
	CPX	#TOPSIZ		; 40 COL WIDE HERE (LC-A)
	BCS	ZC1		; LET OS PUT IN <CR>
ZC0:	LDA	#EOL		; ELSE PUT IT IN 
	STA	LBUFF,X		; TO END LINE
	INC	CHRCNT		; UPDATE LINE LENGTH

ZC1:	LDA	SCREENF		; CHECK IF DISPLAYING TO SCREEN
	BEQ	CR1		; NO, GO HANDLE IF PRINTING
	LDA	SPLITF		; IN TOP SCREEN?
	BNE	ZCRLF0		; YES
	INC	LINCNT		; NEW LINE GOING OUT
ZCRLF0:	LDX	LINCNT		; IS IT TIME TO
	INX			; (A LINE FOR "MORE")
	CPX	LMAX		; PRINT "MORE" YET?
	BCC	CR1		; NO, CONTINUE

	; SCREEN FULL; PRINT "MORE"

	LDA	#0
	STA	LINCNT		; RESET LINE COUNTER
	STA	COLOR		; PRINT "MORE" IN BLACK
	STA	NDX		; CLEAR QUEUE

	SEC
	JSR	PLOT		; GET CURSOR POSITION
	STY	OLDX
	STX	OLDY

	LDX	#LOW MORE
	LDA	#HIGH MORE
	LDY	#MOREL
	JSR	DLINE		; PRINT "MORE" DIRECTLY

ZCR0:	JSR	GETIN		; GET ANY KEYPRESS
	TAX
	BEQ	ZCR0

	LDY	OLDX
	LDX	OLDY
	CLC
	JSR	PLOT		; RESTORE CURSOR

	LDA	#1
	STA	COLOR		; SWITCH BACK TO WHITE

	LDX	#LOW MCLR
	LDA	#HIGH MCLR
	LDY	#MOREL
	JSR	DLINE		; RUB OUT "MORE"

	LDY	OLDX
	LDX	OLDY
	CLC
	JSR	PLOT		; RESTORE CURSOR AGAIN

CR1:	JSR	LINOUT		; DISPLAY LINE
	LDA	#0
	STA	LENGTH		; AND RESET LINE COUNT
	STA	CHRCNT
	RTS


LINOUT:	LDY	CHRCNT	; IF BUFFER EMPTY,
	BEQ	LINEX	; DON'T PRINT ANYTHING
	STY	PRLEN	; SAVE LENGTH HERE FOR "PPRINT"
	LDA	SCREENF	; DISPLAY TO SCREEN?
	BEQ	LOUT1	; NO, GO CHECK IF PRINT

LOUT2:	LDX	#0	; SEND CONTENTS OF [LBUFF]
LOUT:	LDA	LBUFF,X	; TO SCREEN
	JSR	CHAR	
	INX		
	DEY		
	BNE	LOUT	

LOUT1:	LDA	SPLITF	; DON'T PRINT IF SPLIT (NON-TEXT) SCREEN (EZIP)
	BNE	LINEX	
	JSR	PPRINT	; PRINT [LBUFF] IF ENABLED
LINEX:	RTS		; AND RETURN


; ----------------------
; UPDATE THE STATUS LINE
; ----------------------
; NOT APPLICABLE IN EZIP.
ZUSL:	RTS		


; ------
; BUFOUT
; ------
; INPUT: ARG1 = BUFFERED (1) OR NONBUFFERED (0) OUTPUT CHOICE
; EXIT: FLAG (BUFFLG) IS SET TO TELL COUT WHICH TO DO

ZBUFOUT: LDX	ARG1+LO	
	BNE	ZBUF1	; SET TO BUFFERED OUTPUT
	JSR	LINOUT	; CLEAR BUFFER (DON'T RESET LINE COUNT)

	LDX	#0	
	STX	CHRCNT	
	INX		
	STX	BUFFLG	; SET FUTURE OUTPUT TO BE UNBUFFERED
	RTS		
ZBUF1:	DEX		
	BNE	ZBUFEX	; INVALID
	STX	BUFFLG	; SET TO BUFFERED
ZBUFEX:	RTS		


; ------
; DIROUT
; ------
; ARG1 CONTAINS VALUE OF WHICH DEVICE TO SELECT
; OR DESELECT, ARG2 = THE TABLE ADDR FOR TABLE OUTPUT
; MULTIPLE DEVICE USAGE IS POSSIBLE.

ZDIRT:	LDX	ARG1+LO
	BMI	DIRRES		; NEGATIVE VALUE, DESELECTING
	DEX
	BEQ	DIR1		; 1 = SET OUTPUT TO SCREEN
	DEX
	BEQ	DIR2		; 2 = SCRIPTING
	DEX
	BEQ	DIR3		; 3 = TABLE
	DEX
	BEQ	DIR4		; 4 = RECORDING DEVICE (NOT IMPLEMENTED)
DIR4:	RTS			; INVALID VALUE
DIRRES:	INX
	BEQ	DRES1		; -1 = RESET TO SCREEN
	INX
	BEQ	DRES2
	INX
	BEQ	DRES3
	INX
	BEQ	DRES4
DRES4:	RTS			; INVALID VALUE, JUST LEAVE

DIR1:	INX			; 1, TURN SCREEN OUTPUT ON
	STX	SCREENF
	RTS

DRES1:	STX	SCREENF		; 0, TURN SCREEN OFF
	RTS

DIR2:	INX
	STX	SCRIPTF		; SET SCRIPT FLAG ON
	LDA	ZBEGIN+ZSCRIP+1	; SET GAME FLAG ALSO
	ORA	#%00000001
	STA	ZBEGIN+ZSCRIP+1
	RTS			; YES, READY TO LEAVE

DRES2:	STX	SCRIPTF		; TURN PRINTER OFF
	LDA	ZBEGIN+ZSCRIP+1	; AND TURN OFF GAME FLAG TOO
	AND	#%11111110
	STA	ZBEGIN+ZSCRIP+1
	RTS

DIR3:	INX
	STX	TABLEF		; TURN TABLE OUTPUT FLAG ON
	LDA	ARG2+HI		; SET UP TBL
	CLC
	ADC	ZCODE
	LDX	ARG2+LO		; TO STORE CHARS IN
	STX	DIRTBL+LO
	STA	DIRTBL+HI
	LDA	#2
	STA	DIRITM+LO
	LDA	#0
	STA	DIRITM+HI
	RTS

DRES3:	LDA	TABLEF		; IF OFF ALREADY (LZIP)
	BEQ	OUT3		; LEAVE AS IS (LZIP)

	STX	TABLEF		; TURN TBL OUTPUT OFF
	LDA	DIRITM+LO	; MARK END OF CHARS IN TBL
	CLC			; WITH A NULL CHAR
	ADC	DIRTBL+LO
	STA	I+LO
	LDA	DIRITM+HI
	ADC	DIRTBL+HI
	STA	I+HI		; ALIGNED AT EOL
	LDA	#0
	TAY
	STA	(I),Y		; PLACE 0 IN TBL
	LDY	#1		; GET CHAR COUNT
	LDA	DIRITM+LO	; (2 LESS THAN [DIRITM])
	SEC
	SBC	#2
	STA	(DIRTBL),Y
	BCS	RESET0
	DEC	DIRITM+HI
RESET0:	LDA	DIRITM+HI
	DEY
	STA	(DIRTBL),Y	; STORE CHAR COUNT IN TBL
	LDA	#0		; CLEAR COUNT FOR NEXT TIME
	STA	DIRFLG		; SET OUTPUT TO SCREEN
OUT3:	RTS


; ------
; CURSET
; ------
; SET CURSOR AT LINE (ARG1) AS OFFSET FROM TOP OF WINDOW
; AND AT COLUMN (ARG2)

ZCURST:	LDA	ZBEGIN+ZMODE	
	AND	#%00010000	
	BEQ	ZCUREX	; NOT ENABLED
	LDA	SPLITF	
	BEQ	ZCUREX	; OOPS, IN SCROLLING TOP
	LDA	BUFFLG	
	BEQ	ZCUREX	; OOPS, UNBUFFERED

	LDX	ARG1+LO	; GET LINE
	DEX		; ZERO ALIGN IT
	LDY	ARG2+LO	; GET COLUMN
	DEY		; ZERO ALIGN IT
	CLC
	JSR	PLOT	; MOVE THE CURSOR
ZCUREX:	RTS


; --------------
; CURGET & DIRIN
; --------------
; NOT YET IMPLEMENTED, BUT RESERVED

ZCURGT:			
ZDIRIN:	RTS		


; ------
; HLIGHT
; ------

ZLIGHT:	LDA	ZBEGIN+ZMODE	; CHECK IF ENABLED
	AND	#%00001010	
	BEQ	ZLEX	; NOPE

	LDX	ARG1+LO	; GET CHOICE OF MODE
	BNE	ZL1	

	LDA	#146	; REVERSE OFF
	JSR	HLIGHT
	LDA	#130	; UNDERLINE OFF
	JMP	HLIGHT
ZLEX:	RTS		

ZL1:	CPX	#1	; INVERSE?
	BNE	ZL2

	LDA	#$12	; INVERSE
	JMP	HLIGHT

ZL2:	CPX	#4	; UNDERLINE?
	BNE	ZLEX	; NO OTHER ON C128

	LDA	#$02	; UNDERLINE

HLIGHT:	STA	IOCHAR		; HOLD COMMAND CHAR
	LDA	SCREENF		; IF NOT PRINTING TO
	BNE	DOLIGHT		; SCREEN OR PRINTER, SKIP THIS
	LDA	SCRIPTF
	BNE	DOLIGHT
	RTS
DOLIGHT:	LDA	IOCHAR
	LDX	BUFFLG
	BEQ	BUFFD
	JMP	CHROUT		; UNBUFFERED, CHANGE IMMEDIATELY

BUFFD:	LDX	CHRCNT		; BUFFERED, PLACE
	STA	LBUFF,X		; DISPLAY BUFFER
	INC	CHRCNT		; INC CHRCNT BUT NOT! LINE LENGTH
	RTS


; -----
; ERASE
; -----

ZERASE:	LDA	ZBEGIN+ZMODE	; ENABLED?
	AND	#%00010000	
	BEQ	ZEROUT		; NO
	LDA	ARG1+LO
	CMP	#1
	BNE	ZEROUT		; INVALID

	SEC			; CLEAR TO END OF LINE
	JSR	PLOT
	STX	OLDX
	STY	OLDY

ZERLP:	INY
	CPY	#XSIZE		; WHOLE LINE DONE?
	BCS	ZERDUN
	LDA	#SPACE
	JSR	CHROUT
	JMP	ZERLP

ZERDUN:	LDX	SPLITF		; ONE MORE FOR TOP SCREEN (LC-A)
	BEQ	ZERDUN1		; (LC-A)
	LDA	#SPACE		; (LC-A)
	JSR	CHROUT		; (LC-A)
ZERDUN1:LDX	OLDX		; RESET CURSOR
	LDY	OLDY
	CLC
	JSR	PLOT
	JMP	NEWLOG		; MAKE SURE LINES UNCONNECTED (LC-A)
ZEROUT:	RTS


; -----
; CLEAR
; -----

ZCLR:	LDA	ZBEGIN+ZMODE	
	AND	#%00000001	
	BEQ	ZEROUT	; NOT ENABLED
	LDA	ARG1+LO	; CHECK WHAT TO DO
	BEQ	CLR0	; BOTTOM SCREEN
	CMP	#1	
	BEQ	CLR1	; TOP SCREEN
	CMP	#$FF	
	BNE	ZEROUT	; INVALID

; UNSPLIT SCREEN & CLEAR IT

	JSR	NORL	; RESET TO FULL
	JMP	CLS	; & CLEAR IT

CLR0:	; CLEAR BOTTOM SCREEN

	LDX	SLINE
	LDA	LOLINE,X
	TAY			; LOW OFFSET IN Y 
	LDA	HILINE,X
	STA	I+HI
	SEC
	SBC	#HIGH SCREEN	; GET OFFSET INTO
	CLC			; COLOR RAM
	ADC	#HIGH COLRAM
	STA	J+HI

	LDA	#0
	STA	I+LO
	STA	J+LO
	STA	SPENA		; KILL CURSOR

	LDA	#YSIZE
	SEC
	SBC	SLINE
	STA	K		; K = # LINES TO CLEAR

	LDX	#XSIZE
	JSR	CLRSCR		; GO CLEAR BOTTOM SCREEN
	LDX	#YSIZE		; PLACE CURSOR AT BOTTOM OF SCREEN
	JMP	DOSCRN

CLR1:	LDA	#HIGH SCREEN	; START AT TOP
	STA	I+HI
	LDA	#HIGH COLRAM
	STA	J+HI
	LDY	#0		; Y = OFFSET
	STY	I+LO
	STY	J+LO
	STY	SPENA		; KILL CURSOR

	LDA	SLINE
	STA	K		; K = #LINES TO CLEAR

	LDX	#TOPSIZ
	JSR	CLRSCR
	LDX	SLINE
	JMP	DOSCRN

	; ENTER: [Y] SET TO STARTING PAGE OFFSET 
		    (KEEPS TRACK OF PAGE BOUNDARIES)

CLRSCR:	STX	L		; X TO KEEP TRACK OF WHERE ARE IN LINE

ALOOP:	LDA	#SPACE		; CLR LINE
	STA	(I),Y
	LDA	#1		; WHITE BACKGRND
	STA	(J),Y
	DEX
	BNE	CLROK
	DEC	K
	BEQ	CLRDUN

	LDX	L
CLROK:	INY
	BNE	ALOOP
	INC	I+HI		; NEXT PAGE
	INC	J+HI
	BNE	ALOOP		; JMP

CLRDUN:	RTS


; -----
; INPUT
; -----

ZINPUT:	LDA	ARG1+LO	
	CMP	#1		; KEYBOARD?
	BEQ	ZINP7
	JMP	RET0		; NO, INVALID

ZINP7:	LDX	#0
	STX	LINCNT		; RESET LINE COUNT
	STX	LENGTH		; SET LINE COUNT TO 0
	STX	CHRCNT
	STX	NDX		; CLEAR INPUT QUEUE
	INX
	STX	SPENA		; TURN CURSOR DMA ON (1)

	DEC	NARGS	
	BNE	ZINP8
	JMP	ZINP3		; NO TIME LIMIT

ZINP8:	LDA	ARG2+LO		; GET DELAY WANTED
	STA	I+HI	
	LDA	#0		; SET FCN IF IS ONE
	STA	J+HI	
	STA	J+LO	
	DEC	NARGS	
	BEQ	ZINP4		; NO FCN
	LDA	ARG3+LO	
	STA	J+LO	
	LDA	ARG3+HI	
	STA	J+HI	

ZINP4:	JSR	CURSON		; INIT CURSOR (LC-A)
	JSR	TIMEIN		; GO GET A KEY WITHIN TIME DELAY
	BCC	ZINP5		; OK, RETURN IT TO GAME
	JMP	RET0		; OOPS

ZINP3:	JSR	GETKEY		; OK, FIND WHICH CHAR WAS PRESSED

ZINP5:	;CHECK FOR "ARROWS", CONVERT FOR USE (EZIP)

	LDX	#ENDKEY	; GET LENGTH OF LIST
MASK0:	CMP	HAVE,X	; CHECK AGAINST LIST OF UNWANTED KEYS
	BEQ	MASK1	; FOUND IT
	DEX		
	BPL	MASK0	; CHECK THEM ALL
	BMI	MASK2	; NOT FOUND, OK
MASK1:	LDA	WANT,X	; GET KEY TO USE INSTEAD

MASK2:	LDX	#0	
	JMP	PUTBYT		; RETURN CHAR
ZINPEX:	JMP	RET0		; OOPS

HAVE:	DB	$14,$11,$1D,$91,$5E,$9D	; BACKSP,DOWN,RIGHT,UP,UP,LEFT ARROWS
WANT:	DB	08,13,07,14,14,11
ENDKEY	EQU	$-WANT-1


	; GET A KEY WITHIN A TIME FRAME

TIMEIN:	LDA	I+HI
	STA	I+LO		; RESET EA TIME THRU

TIME1:	LDA	#249		; = 7, TIME COUNTS UP
	STA	TIME
TIME2:	LDA	TIME
	BNE	TIME2

	JSR	GETIN		; GET A KEY
	CMP	#0
	BEQ	TIME3		; NO KEY YET
	JSR	GOTKEY
	JMP	TGOOD		; [A] NOW HAS PROPER CODE

TIME3:	INC	BLINK+LO	; TIME TO BLINK YET?
	BNE	NOBLNK		; NOT TILL BOTH BLINK TIMERS
	INC	BLINK+HI	; ARE ZERO
	BNE	NOBLNK

	LDA	#CYCLE		; RESET MSB OF BLINK COUNTER
	STA	BLINK+HI	; FOR SHORT BLINK INTERVAL

	LDA	CURSOR		; FLIP THE CURSOR
	EOR	#$FF		; SHAPE
	STA	CURSOR		; AND UPDATE IT

NOBLNK:	DEC	I+LO
	BNE	TIME1		; SOME TIME LEFT, TRY AGAIN

	; TIME OUT, CHECK IF THERE IS A FCN TO CALL

	LDA	J+LO		; FCN IN J IF THERE IS ONE
	ORA	J+HI
	BEQ	TBAD		; NO FCN, SEND 0 FOR FAILED
	JSR	INTCLL		; INTERNAL CALL
	LDA	VALUE+LO	; GET RESULTS
	BEQ	TIMEIN		; TRY AGAIN

TBAD:	SEC
	RTS			; ABORT
TGOOD:	CLC
	RTS



INTCLL:	LDA	#HIGH ZIRET	; SET ZRETURN TO RETURN HERE
	STA	PATCHI+HI	
	LDA	#LOW ZIRET	
	STA	PATCHI+LO	
	LDA	I+HI	; SAVE VALUES FOR CALLING RTN
	PHA		
	LDA	J+HI	
	PHA		
	LDA	J+LO	
	PHA		
	LDX	OLDZSP+LO	; STUFF TAKEN FROM CALL.
	LDA	OLDZSP+HI	
	JSR	PUSHXA	
	LDA	ZPCL	
	JSR	PUSHXA	
	LDX	ZPCM	
	LDA	ZPCH	
	JSR	PUSHXA	

; FORM QUAD ALIGNED ADDR FROM [ARG3]

	LDA	#0	
	ASL	J+LO	; *4
	ROL	J+HI	
	ROL	A		
	STA	ZPCH	
	ASL	J+LO	
	ROL	J+HI	
	ROL	ZPCH	
	LDA	J+HI	; PICK UP NEW LOW BYTES
	STA	ZPCM	
	LDA	J+LO	
	STA	ZPCL	
	JSR	VLDZPC	
	JSR	NEXTPC	; FETCH # LOCALS TO PASS
	STA	J+LO	; SAVE HERE FOR COUNTING
	STA	J+HI	; AND HERE FOR LATER REFERENCE
	BEQ	INT2	; SKIP IF NO LOCALS
	LDA	#0	
	STA	I+LO	; ELSE INIT STORAGE INDEX
INT1:	LDY	I+LO	
	LDX	LOCALS+LO,Y	; GET LSB OF LOCAL INTO [X]
	LDA	LOCALS+HI,Y	; AND MSB INTO [A]
	JSR	PUSHXA	; PUSH LOCAL IN [X/A] ONTO Z-STACK
	JSR	NEXTPC	; GET MSB OF NEW LOCAL
	STA	I+HI	; SAVE IT HERE
	JSR	NEXTPC	; NOW GET LSB
	LDY	I+LO	; RESTORE INDEX
	STA	LOCALS+LO,Y	; STORE LSB INTO [LOCALS]
	LDA	I+HI	; RETRIEVE MSB
	STA	LOCALS+HI,Y	; STORE IT INTO [LOCALS]
	INY		
	INY		; UPDATE
	STY	I+LO	; THE STORAGE INDEX
	DEC	J+LO	; ANY MORE LOCALS?
	BNE	INT1	; YES, KEEP LOOPING
INT2:	LDX	J+HI	; # OF LOCALS
	TXA		
	JSR	PUSHXA	
	LDA	ZSP+LO	
	STA	OLDZSP+LO	
	LDA	ZSP+HI	
	STA	OLDZSP+HI	
	JMP	MLOOP	; GO DO FCN

	; RETURN FROM FCN WILL COME HERE

ZIRET:	LDA	#HIGH PUTVAL	; REPAIR ZRETURN
	STA	PATCHI+HI	
	LDA	#LOW PUTVAL	
	STA	PATCHI+LO	
	PLA		; GET RID OF RTS FROM ZRET
	PLA		
	PLA		; RESTORE FOR CALLING RTN
	STA	J+LO	
	PLA		
	STA	J+HI	
	PLA		
	STA	I+HI	
	RTS		; GO BACK TO CALLER


IN:	DB	00,00,00,00,00,00,00,00,00
OUT:	DB	00,00,00,00,00,00,00,00,00

QUOT:	DB	00,00		; RDTBL1+4	; (WORD) QUOTIENT FOR DIVISION
REMAIN:	DB	00,00		; QUOT+2	; (WORD) REMAINDER FOR DIVISION
MTEMP:	DB	00,00		; REMAIN+2	; (WORD) MATH TEMPORARY REGISTER
QSIGN:	DB	00		; MTEMP+2	; (BYTE) SIGN OF QUOTIENT
RSIGN:	DB	00		; QSIGN+1	; (BYTE) SIGN OF REMAINDER
DIGITS:	DB	00		; RSIGN+1	; (BYTE) DIGIT COUNT FOR "PRINTN"
BLINK:	DB	00,00		; (WORD) COUNT CYCLE BETWEEN CURSOR BLINKS
ULINE:	DB	00		; (BYTE) UNDERLINE VALUE FOR CURSOR

XEXIST: DB	00		; (BYTE) FLAG = IF THERE IS 256K EXPANSION RAM
				; (0 = NO, 1 = YES)
RESFLG:	DB	00		; (0 = NO, 1 = YES) FLAG FOR XRAM LOAD


MORE:	DB	"[MORE]"
MOREL	EQU	$-MORE
MCLR:	DB	"      "

	END
