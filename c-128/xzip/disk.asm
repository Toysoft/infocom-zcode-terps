	PAGE
	STTL "--- DISK ACCESS: CBM64 ---"

	; --------------
	; OPEN DRIVE [A]
	; --------------

	; ENTRY: DISK ID (8 OR 9 BINARY) IN [A]

DOPEN:	STA	DRIVE		; SAVE DRIVE ID HERE
	JSR	DCLOSE		; CLOSE COMMAND & DATA CHANNELS

	LDA	#15		; LOGICAL FILE #
	TAY			; SECONDARY ADDRESS
	LDX	DRIVE		; DEVICE # (8 OR 9)
	JSR	SETLFS		; SET UP LOGICAL FILE

	LDX	#<I0		; POINT TO FILENAME
	LDY	#>I0		; "I0:"
	LDA	#I0L		; LENGTH OF FILENAME
	JSR	SETNAM

	JMP	OPEN		; OPEN THE DISK (CARRY CLEAR IF OK)

	; --------------------------
	; OPEN DIRECT ACCESS CHANNEL
	; --------------------------

AOPEN:
;	LDA	#0
;	STA	SPENA		; SHUT OFF CURSOR DMA

	JSR	ACLOSE		; CLOSE FIRST

	LDA	#2		; D/A CHANNEL ID
	TAY			; SECONDARY ID
	LDX	DRIVE
	JSR	SETLFS

	LDX	#<POUND		; POINT TO FILENAME
	LDY	#>POUND		; "#"
	LDA	#POUNDL
	JSR	SETNAM

	JMP	OPEN		; OPEN CHANNEL (CARRY CLEAR IF OK)

	; -------------------
	; CLOSE CURRENT DRIVE
	; -------------------

DCLOSE:	LDA	#15		; CLOSE COMMAND CHANNEL
	JSR	CLOSE

	; FALL THROUGH ...

	; ---------------------
	; CLOSE THE D/A CHANNEL
	; ---------------------

ACLOSE:	LDA	#2		; AND THE
	JMP	CLOSE		; DATA CHANNEL

	; ----------------
	; DIVIDE [A] BY 10
	; ----------------

	; EXIT: QUOTIENT IN [X], REMAINDER IN [A]

DIV10:	LDX	#0		; START WITH ZERO QUOTIENT

D10L:	CMP	#10		; IF DIVISOR < 10,
	BCC	D10EX		; WE'RE DONE
	SBC	#10		; ELSE SUBTRACT ANOTHER 10
	INX			; UPDATE QUOTIENT
	BNE	D10L		; BRANCH ALWAYS

D10EX:	RTS

	; ---------------
	; SEND Ux COMMAND
	; ---------------

	; ENTRY: ASCII "1" OR "2" IN [A]

COMLIN:	DB	"U"
DCOMM:	DB	"*"
	DB	":2,0,"
DTRAK:	DB	"***,"
DSECT:	DB	"***"
	DB	EOL
CMLL	EQU	$-COMLIN

SENDU:	STA	DCOMM		; INSERT COMMAND ("1" OR "2") IN STRING

	; CONVERT [TRACK] AND [SECTOR] TO ASCII IN [COMLIN]

	LDA	TRACK
	LDY	#2
TCON:	JSR	DIV10		; DIVIDE BY 10
	ORA	#'0'		; CONVERT TO ASCII
	STA	DTRAK,Y		; STORE INTO STRING
	TXA			; GET QUOTIENT INTO [A]
	DEY			; ZERO-FILL USUSED BYTES
	BPL	TCON

	LDA	SECTOR		; SAME FOR SECTOR ID
	LDY	#2
SCON:	JSR	DIV10
	ORA	#'0'
	STA	DSECT,Y
	TXA
	DEY
	BPL	SCON

	; SEND COMMAND

	JSR	CLRCHN
	LDX	#15		; OUTPUT TO THE
	JSR	CHKOUT		; COMMAND CHANNEL
	BCS	UEX		; EXIT W/CARRY SET IF ERROR

	LDY	#0
SCM0:	LDA	COMLIN,Y	; SEND THE COMMAND LINE
	JSR	CHROUT		; TO THE DRIVE CHANNEL
	INY			; A BYTE AT A TIME
	CPY	#CMLL
	BCC	SCM0
	CLC			; SUCCESS!
UEX:	RTS

	; ----------------------
	; SET THE BUFFER POINTER
	; ----------------------

BPLINE:	DB	"B-P:2,0"
	DB	EOL
BPLL	EQU	$-BPLINE

SETBP:	JSR	CLRCHN
	LDX	#15		; OUTPUT TO
	JSR	CHKOUT		; COMMAND CHANNEL
	BCS	BEX		; CARRY SET IF ERROR

	LDY	#0
SBPL:	LDA	BPLINE,Y
	JSR	CHROUT
	INY
	CPY	#BPLL
	BCC	SBPL
	CLC
BEX:	RTS

	; ------------------------------
	; READ/WRITE A BLOCK TO [IOBUFF]
	; ------------------------------

	; ENTRY: [TRACK] = TRACK # (1-35)
	;        [SECTOR] = SECTOR # (0-15)
	;        [DRIVE] = DRIVE ID (8 OR 9)
	;        CARRY CLEAR TO READ, CARRY SET TO WRITE

DISK:	BCS	DWRITE		; WRITE IF CARRY SET

	; READ A DISK BLOCK

	JSR	AOPEN		; OPEN THE ACCESS CHANNEL
	BCS	BADISK

	LDA	#'1'		; SEND A "U1" COMMAND
	JSR	SENDU
	BCS	BADISK		; CARRY SET IF ERROR

	JSR	SETBP		; SET THE BUFFER POINTER
	BCS	BADISK		; CARRY SET IF ERROR

	JSR	CLRCHN
	LDX	#2		; INPUT FROM
	JSR	CHKIN		; DATA CHANNEL
	BCS	BADISK

	LDY	#0
READ1:	JSR	CHRIN		; GET A BYTE
	STA	IOBUFF,Y	; MOVE TO I/O BUFFER
	INY
	BNE	READ1		; DO 256 BYTES

	BEQ	SHUTD		; THEN EXIT

	; WRITE A BLOCK

DWRITE:	JSR	AOPEN		; OPEN THE ACCESS CHANNEL
	BCS 	BADISK

	JSR	SETBP		; SET THE BUFFER POINTER
	BCS	BADISK		; CARRY SET IF ERROR

	JSR	CLRCHN
	LDX	#2		; OUTPUT TO
	JSR	CHKOUT		; DATA CHANNEL
	BCS	BADISK		; CARRY SET IF ERROR

	LDY	#0
WRITE1:	LDA	IOBUFF,Y	; SEND CONTENTS OF [IOBUFF]
	JSR	CHROUT		; TO THE DRIVE
	INY
	BNE	WRITE1		; WRITE 256 BYTES

	LDA	#'2'		; ISSUE A "U2" COMMAND
	JSR	SENDU
	BCS	BADISK		; CARRY SET IF ERROR

	JSR	TALKTO
	BCS	COMPLAIN	; tell about error then
SHUTD:
	JSR	CLRCHN
	CLC
	RTS			; CARRY CLEAR FOR SUCCESS
COMPLAIN:
	JSR	CLRCHN
	LDX	#<TALKBUF
	LDA	#>TALKBUF
	LDY	TALKLEN
	JSR	DLINE
BADISK:
	JSR	CLRCHN
	SEC
	RTS			; OR SET IF ERROR
;
; ask the disk how things are going
;
TALKTO:
	LDA	SAVDRI		; get save drive
	LDX	#15
	JSR	TALK

	JSR	LISTEN
	CMP	#'0'		; IS FIRST BYTE A ZERO?
	BEQ	TALKG
	BCC	TALKG		; waiting for 0-9!
	CMP	#'9'+1
	BCS	TALKG		; don't know what it is saying
	
	JSR	LISTEN
	JSR	LISTEN

	LDY	#1
LLOOP:
	JSR	LISTEN
	CMP	#','
	BEQ	TALKEX
	STA	TALKBUF,Y
	INY
	CPY	#30
	BNE	LLOOP
TALKEX:
	LDA	#EOL
	STA	TALKBUF,Y
	INY
	STA	TALKBUF,Y
	STY	TALKLEN
	JSR	UNTALK
	SEC
	RTS
TALKG:
	JSR	UNTALK
	CLC
	RTS

TALKBUF: DB 	EOL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
TALKLEN: DB 0

	END




