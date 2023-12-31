	PAGE	
	STTL "--- COMMODORE 128 MEMORY ACCESS RTNS ---"


	ORG	SHARED

	; THIS CODE MUST BE ACCESSIBLE FROM BOTH BANK0 AND BANK1
	; THEREFORE IT WILL BE IN THE "SHARED" SECTION OF MEMORY

	; ------
	; GETBYT
	; ------

GETBYT:	LDY	MPCBNK		;SELECT CURRENT BANK
	LDA	BANK0,Y		;ENABLE READ
	STA	CR
	LDY	MPCL
	LDA	(MPCPNT),Y	;GET THE BYTE
	LDX	BANK1		;KILL (FOR SAFTY)
	STX	CR
	INC	MPCL		;POINT TO NEXT BYTE
	BNE	GETGOT		;IF NO CROSS WE ARE STILL VALID
	JSR	CRSMPC
GETGOT:	TAY			;SET FLAGS
	RTS			;RED SLIPPER TIME


	; ------
	; NEXTPC
	; ------

	; LIKE GETBYT

NEXTPC:	LDY	ZPCBNK
	LDA	BANK0,Y
	STA	CR
	LDY	ZPCL
	LDA	(ZPCPNT),Y
	LDX	BANK1		;KILL
	STX	CR
	INC	ZPCL
	BNE	NXTGOT
	JSR	CRSZPC
NXTGOT:	TAY		
	RTS		


	; -----------
	; READ SECTOR
	; -----------

	; NOW HAVE TRACK & SECTOR, READ THE DISK

GETRES:	CLC			; CARRY CLEAR = "READ BLOCK"
	JSR	DISK		; GO DO IT!
	BCC	GOT
	RTS
	;JMP	DSKERR		; ERROR IF CARRY SET

GOT:	LDY	DSKBNK		; SET TO PROPER BANK
	LDA	BANK0,Y
	STA	CR

	LDY	#0		; MOVE CONTENTS OF [IOBUFF]
GDKL:	LDA	IOBUFF,Y	; TO THE
	STA	(DBUFF),Y	; TARGET PAGE IN [DBUFF]
	INY
	BNE	GDKL

	LDA	BANK1		; RESET TO MAIN BANK
	STA	CR

	INC	DBUFF+HI	; POINT TO NEXT PAGE
	LDA	DBUFF+HI
	CMP	#MAINEND+1	; PAST LAST MAIN RAM PAGE ?
	BCC	GDEX		; NO
	LDA	#AUXSTART	; RESET DBUFF TO FIRST AUX PAGE
	STA	DBUFF+HI	
	LDA	#AUX		; SET DSKBNK TO AUX
	STA	DSKBNK	
GDEX:	JMP	NXTDBL		; POINT TO NEXT DBLOCK, SECTOR & TRACK


	; -------------
	; KERNAL ACCESS
	; -------------

	; THESE RTNS WILL SWITCH TO BANK0 WHERE THE KERNAL
	; CAN BE ACCESSED, CALL THE WANTED RTN AND THEN
	; SWITCH BACK TO BANK1 TO RESUME WITH EZIP

CHKIN:	PHA			; SAVE [A] IN CASE IS NEEDED
	LDA	BANK0		; SET TO BANK0 WHERE CAN ACCESS KERNAL
	STA	CR
	PLA
	JSR	RCHKIN		; AND CALL KERNAL RTN
	PHA
	LDA	BANK1		; THEN SET BACK TO MAIN BANK
	STA	CR
	PLA
	RTS

CHKOUT:	PHA
	LDA	BANK0
	STA	CR
	PLA
	JSR	RCHKOUT
	PHA
	LDA	BANK1
	STA	CR
	PLA
	RTS

CHRIN:	PHA
	LDA	BANK0
	STA	CR
	PLA
	JSR	RCHRIN
	PHA
	LDA	BANK1
	STA	CR
	PLA
	RTS

CHROUT:	PHA
	LDA	BANK0
	STA	CR
	PLA
	JSR	RCHROUT
	PHA
	LDA	BANK1
	STA	CR
	PLA
	RTS

CLALL:	PHA
	LDA	BANK0
	STA	CR
	PLA
	JSR	RCLALL
	PHA
	LDA	BANK1
	STA	CR
	PLA
	RTS

CLOSE:	PHA
	LDA	BANK0
	STA	CR
	PLA
	JSR	RCLOSE
	PHA
	LDA	BANK1
	STA	CR
	PLA
	RTS

CLRCHN:	PHA
	LDA	BANK0
	STA	CR
	PLA
	JSR	RCLRCHN
	PHA
	LDA	BANK1
	STA	CR
	PLA
	RTS

GETIN:	PHA
	LDA	BANK0
	STA	CR
	PLA
	JSR	RGETIN
	PHA
	LDA	BANK1
	STA	CR
	PLA
	RTS

OPEN:	PHA
	LDA	BANK0
	STA	CR
	PLA
	JSR	ROPEN
	PHA
	LDA	BANK1
	STA	CR
	PLA
	RTS

PLOT:	PHA
	LDA	BANK0
	STA	CR
	PLA
	JSR	RPLOT
	PHA
	LDA	BANK1
	STA	CR
	PLA
	RTS

READST:	PHA
	LDA	BANK0
	STA	CR
	PLA
	JSR	RREADST
	PHA
	LDA	BANK1
	STA	CR
	PLA
	RTS

SCNKEY:	PHA
	LDA	BANK0
	STA	CR
	PLA
	JSR	RSCNKEY
	PHA
	LDA	BANK1
	STA	CR
	PLA
	RTS

SETLFS:	PHA
	LDA	BANK0
	STA	CR
	PLA
	JSR	RSETLFS
	PHA
	LDA	BANK1
	STA	CR
	PLA
	RTS

SETMSG:	PHA
	LDA	BANK0
	STA	CR
	PLA
	JSR	RSETMSG
	PHA
	LDA	BANK1
	STA	CR
	PLA
	RTS

SETNAM:	PHA
	LDA	BANK0
	STA	CR
	PLA
	JSR	RSETNAM
	PHA
	LDA	BANK1
	STA	CR
	PLA
	RTS

	; THE TWO FILE NAMES CALLED WITH SETNAM, THEY NEED
	; TO BE ACCESSIBLE FROM BANK0 FOR THE CALL

I0:	DB	"I0"
I0L	EQU	$-I0

POUND:	DB	"#"
POUNDL	EQU	$-POUND


; --------------------------------
; RETURN RANDOM BYTES IN [A] & [X]
; --------------------------------

RANDOM:	LDA	BANK0
	STA	CR
	INC	RAND		; RANDOM FROM APPLE (11/4/86 LD)
	DEC	RASTER
	LDA	RAND
	ADC	RNUM1
	TAX
	LDA	RASTER
	SBC	RNUM2
	STA	RNUM1
	STX	RNUM2
	LDY	BANK1
	STY	CR
	RTS

RNUM1:	DB	0
RNUM2:	DB	0


BOOP:	LDA	BANK0
	STA	CR

	LDA	#96	; FREQ LSB
	STA	FRELO1
	LDA	#22	; MSB
	STA	FREHI1
	LDA	#$F2
	STA	TIME
	JMP	SOUND

BEEP:	LDA	BANK0
	STA	CR

	LDA	#60	; FREQ LSB
	STA	FRELO1
	LDA	#50	; MSB
	STA	FREHI1
	LDA	#$FC
	STA	TIME

SOUND:	LDA	#%11110000
	STA	SUREL1		; FULL SUSTAIN
	LDA	#%10001111
	STA	SIGVOL		; FULL VOLUME
	LDA	#%01000001
	STA	VCREG1		; START PULSE

RAZZ:	LDA	TIME
	BNE	RAZZ

	STA	VCREG1		; STOP PULSE
	LDA	#%10000000
	STA	SIGVOL		; VOLUME OFF

	LDA	BANK1		; RESET SYSTEM
	STA	CR
	RTS


	DB	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	DB	00,00,00,00,00,00,00,00

	; FILL OUT THE SECTOR NICE NICE SO IT'S ALL ALIGNED HAPPY


	END
