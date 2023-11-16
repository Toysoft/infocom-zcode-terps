	PAGE
	SBTTL "--- 0-OPS ---"

	; -----
	; RTRUE
	; -----

	; SIMULATE A "RETURN 1"

ZRTRUE:	LDX	#1

ZRT0:	LDA	#0

ZRT1:	STX	ARG1+LO		; GIVE TO
	STA	ARG1+HI		; [ARG1]
	JMP	ZRET		; AND DO THE RETURN

	; ------
	; RFALSE
	; ------

	; SIMULATE A "RETURN 0"

ZRFALS:	LDX	#0
	BEQ	ZRT0

	; ------
	; PRINTI
	; ------

	; PRINT Z-STRING FOLLOWING THE OPCODE

ZPRI:	LDA	ZPCH		; MOVE [ZPC] INTO [MPC]
	STA	MPCH
	LDA	ZPCM
	STA	MPCM
	LDA	ZPCL
	STA	MPCL

	LDA	#0
	STA	MPCFLG		; [MPC] NO LONGER VALID

	JSR	PZSTR		; PRINT THE Z-STRING AT [MPC]

	LDX	#5		; COPY STATE OF [MPC]
PRIL:	LDA	MPC,X		; INTO [ZPC]
	STA	ZPC,X
	DEX
	BPL	PRIL
	RTS

 	; ------
	; PRINTR
	; ------

	; DO A "PRINTI," FOLLOWED BY "CRLF" AND "RTRUE"

ZPRR:	JSR	ZPRI
	JSR	ZCRLF
	JMP	ZRTRUE

	; ------
	; RSTACK
	; ------

	; "RETURN" WITH VALUE ON STACK

ZRSTAK:	JSR	POPVAL		; GET VALUE INTO [X/A]
	JMP	ZRT1		; AND GIVE IT TO "RETURN"

	; ------
	; VERIFY
	; ------

	; VERIFY GAME CODE ON DISK

ZVER:	JSR	VERNUM 		; DISPLAY VERSION NUMBER, GET SIDE 1

	LDX	#3
	LDA	#0
ZVR:	STA	J+LO,X		; CLEAR [J], [K]
	STA	MPC,X		; [MPC] AND [MPCFLG]
	DEX
	BPL	ZVR

	LDA	#64		; POINT [MPC] TO Z-ADDRESS $00040
	STA	MPCL		; 1ST 64 BYTES AREN'T CHECKED

	LDA	ZBEGIN+ZLENTH	; GET MSB
	STA	I+HI		; AND
	LDA	ZBEGIN+ZLENTH+1	; LSB OF Z-CODE LENGTH IN BYTES
	ASL	A		; MULTIPLY BY
	STA	I+LO		; TWO
	ROL	I+HI		; TO GET # BYTES
	ROL	K+LO		; IN GAME

	IF	0

	LDA	#K+HI		; PATCH THE "GETBYT" ROUTINE
	STA	PATCH		; TO USE [K+HI]=0 INSTEAD OF [ZPURE]

VSUM:	JSR	GETBYT		; GET A Z-BYTE INTO [A]
	CLC
	ADC	J+LO		; ADD IT TO SUM
	STA	J+LO		; IN [J]
	BCC	VSUM0
	INC 	J+HI

VSUM0:	LDA	MPCL		; END OF Z-CODE YET?
	CMP	I+LO		; CHECK LSB
	BNE	VSUM

	LDA	MPCM		; MIDDLE BYTE
	CMP	I+HI
	BNE	VSUM

	LDA	MPCH		; AND HIGH BIT
	CMP	K+LO
	BNE	VSUM

	LDA	#ZPURE		; UNPATCH "GETBYT"
	STA	PATCH

	ENDIF


	LDA	#0		; START AT BEGINNING
	STA	DBLOCK+LO
	STA	DBLOCK+HI
	JMP	READIN		; READ FIRST BLOCK IN

VSUM:	LDA	MPCL		; IF 0, NEED ANOTHER PAGE
	BNE	VSUM2
READIN:	LDA	#HIGH IOBUFF	; FAKE GETDSK OUT SO
	STA	DBUFF+HI	; IT DOESN'T MOVE BUFFER
	JSR	GETDSK		; GO READ A PAGE

VSUM2:	LDY	MPCL		; GET THIS BYTE
	LDA	IOBUFF,Y
	INC	MPCL		; SET FOR NEXT BYTE
	BNE	VSUM3
	INC	MPCM
	BNE	VSUM3
	INC	MPCH

VSUM3:	CLC
	ADC	J+LO		; ADD IT TO SUM
	STA	J+LO		; IN [J]
	BCC	VSUM0
	INC 	J+HI

VSUM0:	LDA	MPCL		; END OF Z-CODE YET?
	CMP	I+LO		; CHECK LSB
	BNE	VSUM

	LDA	MPCM		; MIDDLE BYTE
	CMP	I+HI
	BNE	VSUM

	LDA	MPCH		; AND HIGH BIT
	CMP	K+LO
	BNE	VSUM

	LDA	ZBEGIN+ZCHKSM+1	; GET LSB OF CHECKSUM
	CMP	J+LO		; DOES IT MATCH?
	BNE	BADVER		; NO, PREDICATE FAILS

	LDA	ZBEGIN+ZCHKSM	; ELSE CHECK MSB
	CMP	J+HI		; LOOK GOOD?
	BNE	BADVER		; IF MATCHED,
	JMP	PREDS		; GAME IS OKAY

BADVER:	JMP	PREDF

	END
