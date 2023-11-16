	PAGE
	STTL "--- DEBUGGER: EZIP C128 ---"

	; --------------
	; C128 DEBUGGER
	; --------------

	; ENTRY: BREAKPOINT ID IN [A]

BLINE:	DB	"B:    OP:   PC:       S:   V:       1:   2:   3:   4:   5:   6:   7:   8:   9:  "
	DB	EOL
BLINL	EQU	$-BLINE


DOBUG:	;RTS

	STA	DHOLD

;	LDA	SHFLAG
;	AND	#%00000100	; CTRL KEY PRESSED?
;	BEQ	TEST2		; CONTINUE IF NOT
;	RTS			; AND EXIT

TEST2:	;LDA	DHOLD
	;CMP	#0
	;BEQ	BUGIT
	;RTS

	NOP			; ON THE FLY CHANGE SPACE
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP

BUGIT:	
;	SEC
;	JSR	PLOT		; GET GAME POSITION
;	STX	OLDX
;	STY	OLDY
;	LDX	#23
;	LDY	#0
;	CLC
;	JSR	PLOT		; AND SET DUBUG ONE

	LDA	DHOLD
	LDX	#2		; INIT "CURSOR"
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
	LDA	WBOTM
;	LDA	BONE
	JSR	HEX

	LDX	#43
	LDA	WTOP
;	LDA	BTWO
	JSR	HEX

	LDX	#48
	LDA	TOP
;	LDA	BTHREE
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

PPP:	LDX	#0
DBG1:	LDA	BLINE,X		; PRINT DEBUGGER TEXT
	JSR	CHROUT
	INX
	CPX	#BLINL
	BCC	DBG1

	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP

	LDA	#0
	STA	NDX		; CLEAR
;	JSR	GETIN
;	CMP	#0
;	BEQ	WOK		; IF NO KEY, CONTINUE
WAITT:	JSR	GETIN		; NOW WAIT FOR ANOTHER KEY
	CMP	#0
	BEQ	WAITT
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
WOK:	NOP

	CMP	#'Q'
	BNE	LLETEX
	BRK

LLETEX:	
;	LDX	OLDX
;	LDY	OLDY
;	CLC
;	JSR	PLOT		; NOW BACK TO OUR REGULARLY SCHEDULED PROGRAM
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
BSEVEN:	DB	0
BEIGHT:	DB	0
BNINE:	DB	0
DHOLD:	DB	0

	END

