	PAGE
	SBTTL "--- DEBUGGER: APPLE ---"

	; --------------
	; APPLE DEBUGGER
	; --------------

	; ENTRY: BREAKPOINT ID IN [A]

	; SMALL DEBUGGER DBG1 (CONVERTS) DBG2 (JUST DISPLAYS) [A]

DLCNT:	DB	0

DBG1:
	INC	DLCNT
	BNE	DBG1m
	PHA
	JSR	GETKEY
	PLA
DBG1m:
	PHA
	LSR	A
	LSR	A
	LSR	A
	LSR	A
	JSR	NIB1
	PLA

NIB1:	AND	#%00001111
	TAY
	LDA	HCHARS,Y
	JSR	MCOUT
	RTS

DBG2:
;	CMP	#' '
;	BEQ	DBG3
;	JSR	MCOUT
;	LDA	#' '
DBG3:	JSR	MCOUT
	RTS

HCHARS:	DB	"0123456789ABCDEF"

	END

BLINE:	DB	"B:    OP:   PC:       S:   V:       1:   2:   3:   4:   5:   6:   7:   8:   9:  "
	DB	EOL
BLINL	EQU	$-BLINE

BUGLIN	EQU	LSTLNE

DOBUG:	LDX	KBD		; WAS CTRL-S PRESSED?
	CPX	#$13
	BNE	DO1
	RTS			; YES, SO LEAVE

DO1:	CMP	#0
	BEQ	BUGIT
	RTS

	NOP			; ON THE FLY CHANGE SPACE
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP

BUGIT:	LDX	#2		; INIT "CURSOR"
	JSR	HEX		; SHOW BREAKPOINT

	LDA 	OPCODE
	BMI	ITQ0
	LDA	#'2'
	BNE	SHOWOP

ITQ0:	CMP	#$B0
	BCS	ITQ1
	LDA	#'1'
	BNE	SHOWOP

ITQ1:	CMP	#$C0
	BCS	ITQ2
	LDA	#'0'
	BNE	SHOWOP

ITQ2:	CMP	#$E0
	BCS	ITQ3
	LDA	#'E'
	BNE	SHOWOP

ITQ3:	LDA	#'X'

SHOWOP:	LDX	#5		; SET CURSOR
	STA	BLINE,X

	LDX	#9		; CURSOR FOR OP ID
	LDA	OPCODE
	JSR	HEX

	LDX	#15		; CURSOR FOR PC
	LDA	ZPCH
	JSR	HEX
	LDA	ZPCM
	JSR	HEX
	LDA	ZPCL
	JSR	HEX

	LDX	#24		; CURSOR FOR [ZSP]
	LDA	ZSP
	JSR	HEX

	LDX	#29		; CURSOR FOR [MPC]
	LDA	MPCH
	JSR	HEX
	LDA	MPCM
	JSR	HEX
	LDA	MPCL
	JSR	HEX

	LDX	#38
	LDA	BONE
	JSR	HEX

	LDX	#43
	LDA	BTWO
	JSR	HEX

	LDX	#48
	LDA	BTHREE
	JSR	HEX

	LDX	#53
	LDA	BFOUR
	JSR	HEX

	LDX	#58
	LDA	BFIVE
	JSR	HEX

	LDX	#63
	LDA	BSIX
	JSR	HEX

	LDX	#68
	LDA	BSEVEN
	JSR	HEX

	LDX	#73
	LDA	BEIGHT
	JSR	HEX

	LDX	#78
	LDA	BNINE
	JSR	HEX

;	TO SEND TO PRINTER IF WANTED
;	LDA	CSW+LO
;	PHA
;	LDA	CSW+HI
;	PHA
;	LDA	EH
;	PHA
;	LDA	ALTCSW+LO
;	STA	CSW+LO
;	LDA	ALTCSW+HI
;	STA	CSW+HI
;
;	LDA	PSTAT
;	BNE	PPP
;
;	LDA	#$C1
;	STA	CSW+HI
;	LDA	#$00
;	STA	CSW+LO
;
;	LDA	#$89
;	JSR	MCOUT
;	LDA	CSW+HI
;	STA	ALTCSW+HI
;	LDA	CSW+LO
;	STA	ALTCSW+LO
;	LDA	#$B8
;	JSR	MCOUT
;	LDA	#$B0
;	JSR	MCOUT
;	LDA	#$CE
;	JSR	MCOUT
;	LDA	#$8D
;	JSR	MCOUT

PPP:	LDX	#2
DBUG1:	LDA	BLINE,X		; PRINT DEBUGGER TEXT
;	JSR	MCOUT
	JSR	CHAR
	INX
	CPX	#BLINL
	BCC	DBUG1

;	PLA
;	STA	EH
;	PLA	
;	STA	CSW+HI
;	PLA
;	STA	CSW+LO

;	BIT	KBD
;	BPL	LETEX		; NO KEY PRESSED

	BIT	ANYKEY		; CLEAR IT
BUGWAT:	BIT	KBD		; WAIT FOR A KEY
	BPL	BUGWAT

	LDA	KBD
	CMP	#$8D
	BNE	LETEX
	BRK

LETEX:	BIT	ANYKEY		; CLEAR FOR NEXT ONE
	RTS

	; CONVERT [A] TO HEX & PRINT

HEX:	PHA
	LSR	A
	LSR	A
	LSR	A
	LSR	A
	JSR	NIB
	PLA

NIB:	AND	#%00001111
	TAY
	LDA	HCHARS,Y
	ORA	#%10000000
	STA	BLINE,X
	INX
	RTS

HCHARS:	DB	"0123456789ABCDEF"

BONE:	DB	0
BTWO:	DB	0
BTHREE:	DB	0
BFOUR:	DB	0
BFIVE:	DB	0
BSIX:	DB	0
BSEVEN: DB	0
BEIGHT:	DB	0
BNINE:	DB	0

	END

