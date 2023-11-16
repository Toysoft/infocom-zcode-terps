	PAGE
	SBTTL "--- Z-DOS: APPLE II ---"

	; --------------------
	; READ A VIRTUAL BLOCK
	; --------------------

	; ENTRY: V-BLOCK TO READ IN [DBLOCK]
	; 	 BUFFER ADDRESS IN [DBUFF]
	; EXIT: DATA IN [DBUFF]

GETDSK:	LDA	DBLOCK+LO	; GET LSB OF BLOCK ID
	AND	#%00001111	; MASK OFF TOP NIBBLE
	STA	DCBSEC		; TO FORM DCBSEC ID (0-15)

	LDA	DBLOCK+HI	; GET MSB OF BLOCK ID
	AND	#%00001111	; THROW AWAY TOP NIBBLE
	ASL	A		; AND SHIFT BOTTOM TO TOP
	ASL	A
	ASL	A
	ASL	A
	STA	DCBTRK		; SAVE HERE FOR A MOMENT

	LDA	DBLOCK+LO	; GET LSB
	AND	#%11110000	; SCREEN OUT BOTTOM NIBBLE
	LSR	A		; MOVE TOP TO BOTTOM
	LSR	A
	LSR	A
	LSR	A
	ORA	DCBTRK		; SUPERIMPOSE TOP OF MSB
	CLC			; Z-BLOCKS START ON
	CLD
	ADC	#03		; FIRST TRACK 
	CMP	#ZTRKL		; ANYTHING ABOVE TRACK 35
	BCS	TRKERR

	STA	DCBTRK		; THIS IS THE TRACK ID

	; "RESTORE" ENTRY (W/[DCBSEC/TRK] PRESET)

GETRES:	LDA	#0		; 0 = "READ SECTOR"
	JSR	DOS
	BCS	DSKER		; FATAL ERROR IF CARRY SET

	LDY	#0		; MOVE DATA
GDSK1:	LDA	IOBUFF,Y	; IN [IOBUFF]
	STA	(DBUFF),Y	; TO [DBUFF]
	INY
	BNE	GDSK1

	INC	DBLOCK+LO	; POINT TO NEXT
	BNE	NXTSEC		; VIRTUAL BLOCK
	INC	DBLOCK+HI

	; POINT TO NEXT SECTOR

NXTSEC:	INC	DCBSEC		; UPDATE SECTOR
	LDA	DCBSEC		; CHECK IT
	AND	#%00001111	; DID IT OVERFLOW?
	BNE	SECTOK		; NO, ALL'S WELL

	LDX	DCBTRK		; ELSE UPDATE
	INX			; TRACK ID
	CPX	#ZTRKL		; IF > 35,
	BCS	WRTERR		; SCRAM W/CARRY SET
	STX	DCBTRK		; ELSE SAVE NEW TRACK

SECTOK:	STA	DCBSEC		; AND SECTOR
	INC	DBUFF+HI	; POINT TO NEXT RAM PAGE
	CLC			; CLEAR CARRY FOR SUCCESS (WRITE ONLY)
	RTS

	; ----------------------
	; WRITE [DBLOCK] TO DISK
	; ----------------------

	; ENTRY: TRACK,SECTOR,DRIVE,SLOT ALL SET ALREADY
	;	 PAGE TO WRITE IN (DBUFF)
	; EXIT: CARRY CLEAR IF OKAY, SET IF FAILED

PUTDSK:	LDY	#0		; MOVE DATA AT [DBUFF]
PDSK0:	LDA	(DBUFF),Y	; TO [IOBUFF]
	STA	IOBUFF,Y	; FOR WRITING
	INY
	BNE	PDSK0

	LDA	#1		; 1 = "WRITE SECTOR"
	JSR	DOS		; DO IT!
	BCC	NXTSEC		; OKAY IF CARRY CLEAR
WRTERR:	RTS			; ELSE EXIT WITH CARRY SET

	; *** ERROR #12: DISK ADDRESS RANGE ***

TRKERR:	LDA	#12
	JMP	ZERROR

	; *** ERROR #14: DRIVE ACCESS ***

DSKER:	LDA	#14
	JMP	ZERROR

	; -----------------------------
	; SET UP SAVE & RESTORE SCREENS
	; -----------------------------

SAVRES:	JSR	ZCRLF		; CLEAR THE LINE BUFFER
	LDA 	#0			; USE FULL SCREEN !
	STA 	WTOP
	JSR	HOME		; AND THE SCREEN

	LDA	#0
	STA	SCRIPT		; DISABLE SCRIPTING
	STA	CH		;HOME CURSOR
	STA	EH		;(80 COL)
	STA	CV
	JMP	PISSER		;TO ACTUALLY MOVE CURSOR

	; -----------------
	; DISPLAY A DEFAULT
	; -----------------

	; ENTRY: DEFAULT (1-8) IN [A]

DEFAL:	DB	" (Default is "
DEFNUM:	DB	"*) >"
DEFALL	EQU	$-DEFAL

DODEF:	CLC
	ADC	#'1'		; CONVERT TO ASCII 0-7
	STA	DEFNUM		; INSERT IN STRING

	LDX	#LOW DEFAL
	LDA	#HIGH DEFAL
	LDY	#DEFALL
	JMP	DLINE		; PRINT THE STRING

	; -----------------------------
	; GET SAVE & RESTORE PARAMETERS
	; -----------------------------

POSIT:	DB	EOL
	DB	"Position 0-7"
POSITL	EQU	$-POSIT

WDRIV:	DB	EOL
	DB	"Drive 1 or 2"
WDRIVL	EQU	$-WDRIV

SLOT:	DB	EOL
	DB	"Slot 1-7"
SLOTL	EQU	$-SLOT

GSLOT:	DB	5		;START W/ DEFAULT SLOT 6 (YES 5 IS 6)

MIND:	DB	EOL
	DB	EOL
	DB	"Position "
MPOS:	DB	"*; Drive #"
MDRI:	DB	"*; Slot "
MSLT:	DB	"*."
	DB	EOL
	DB	"Are you sure? (Y/N) >"
MINDL	EQU	$-MIND

INSM:	DB	EOL
	DB	"Insert SAVE disk into Drive #"
SAVDRI:	DB	"*."
INSML	EQU	$-INSM

YES:	DB	"YES"
	DB	EOL
YESL	EQU	$-YES

NO:	DB	"NO"
	DB	EOL
NOL	EQU	$-NO

PARAMS:	LDX	#LOW POSIT
	LDA	#HIGH POSIT
	LDY	#POSITL
	JSR	DLINE		; "POSITION (0-7)"

	; GET GAME SAVE POSITION

	LDX	GPOSIT		; SHOW THE CURRENT
	DEX			; ALIGN TO DISPLAY 
	TXA			; CORRECTLY W/ DODEF
	JSR	DODEF		; DEFAULT POSITION

GETPOS:	JSR	GETKEY		; WAIT FOR A KEY
	CMP	#EOL		; IF [RETURN],
	BEQ	POSSET		; USE DEFAULT
	SEC
	SBC	#'0'		; ELSE CONVERT ASCII TO BINARY
	CMP	#8		; IF BELOW "8"
	BCC	SETPOS		; MAKE IT THE NEW DEFAULT
	JSR	BOOP		; ELSE RAZZ
	JMP	GETPOS		; AND TRY AGAIN

POSSET:	LDA	GPOSIT		; USE DEFAULT

SETPOS:	STA	TPOSIT		; USE KEYPRESS
	CLC
	ADC	#'0'		; CONVERT TO ASCII "0"-"7"
	STA	MPOS		; STORE IN TEMP STRING
	STA	SVPOS
	STA	RSPOS
	JSR	CHAR		; AND DISPLAY IT

	; GET DRIVE ID

	LDX	#LOW WDRIV
	LDA	#HIGH WDRIV
	LDY	#WDRIVL
	JSR	DLINE		; "DRIVE 1 OR 2"

	LDA	GDRIVE		; SHOW DEFAULT
	JSR	DODEF

GETDRV:	JSR	GETKEY		; GET A KEYPRESS
	CMP	#EOL		; IF [RETURN],
	BEQ	DRVSET		; USE DEFAULT
	SEC
	SBC	#'1'		; CONVERT TO BINARY 0 OR 1
	CMP	#2		; IF WITHIN RANGE,
	BCC	SETDRV		; SET NEW DEFAULT
	JSR	BOOP
	JMP	GETDRV		; ELSE TRY AGAIN

DRVSET:	LDA	GDRIVE		; USE DEFAULT

SETDRV:	STA	TDRIVE		; USE [A]
	CLC
	ADC	#'1'		; CONVERT TO ASCII 1 OR 2
	STA	SAVDRI		; STORE IN DRIVE STRING
	STA	MDRI		; AND IN TEMP STRING
	JSR	CHAR		; AND SHOW NEW SETTING

	;IF IIC SLOT IS 6 OTHERWISE ASK

	LDA	SIG		; CHECK IF IIc
	BNE	PREIIC		; IS NOT A IIC SO ASK WHICH SLOT

	LDA	#5		; SLOT 6
	BNE	SETSLT		; JMP

PREIIC:	LDX	#LOW SLOT 
	LDA	#HIGH SLOT 
	LDY	#SLOTL 
	JSR	DLINE		; "SLOT 1-7"

	; GET DRIVE SLOT

	LDA	GSLOT		; SHOW THE CURRENT

	JSR	DODEF		; DEFAULT SLOT

GETSLT:	JSR	GETKEY		; WAIT FOR A KEY
	CMP	#EOL		; IF [RETURN],
	BEQ	SLTSET		; USE DEFAULT
	SEC
	SBC	#'1'		; ELSE CONVERT ASCII TO BINARY
	CMP	#7		; IF "7" OR BELOW
	BCC	SETSLT		; MAKE IT THE NEW DEFAULT
BADSLT:	JSR	BOOP		; ELSE RAZZ
	JMP	GETSLT		; AND TRY AGAIN
SLTSET:	LDA	GSLOT		; USE DEFAULT

SETSLT:	STA	TSLOT 		; USE KEYPRESS
	CLC
	ADC	#'1'		; CONVERT TO ASCII "1"-"7"
	STA	MSLT		; STORE IN TEMP STRING
	LDX	SIG		; AND IF NOT IIC
	BEQ	DBLCHK
	JSR	CHAR		; DISPLAY IT

DBLCHK:	LDX	#LOW MIND	; SHOW TEMPORARY SETTINGS
	LDA	#HIGH MIND
	LDY	#MINDL
	JSR	DLINE

	; VALIDATE RESPONSES

GETYES:	JSR	GETKEY
	CMP	#'y'		; IF REPLY IS "Y"
	BEQ	ALLSET		; ACCEPT RESPONSES
	CMP	#'Y'
	BEQ	ALLSET
	CMP	#EOL		; EOL IS ALSO ACCEPTABLE
	BEQ	ALLSET

	CMP	#'n'		; IF REPLY IS "N"
	BEQ	NOTSAT		; RESTATE PARAMETERS
	CMP	#'N'
	BEQ	NOTSAT

	JSR	BOOP		; ELSE BOOP
	JMP	GETYES		; INSIST ON Y OR N

NOTSAT:	LDX	#LOW NO
	LDA	#HIGH NO
	LDY	#NOL
	JSR	DLINE		; PRINT "NO"/EOL
	JMP	PARAMS		; AND TRY AGAIN

ALLSET:	LDX	#LOW YES
	LDA	#HIGH YES
	LDY	#YESL
	JSR	DLINE		; PRINT "YES"/EOL

	LDA	TDRIVE		; MAKE THE TEMPORARY DRIVE
;	STA	GDRIVE		; THE DEFAULT DRIVE
	STA	DCBDRV		; AND SET [DRIVE] ACCORDINGLY
	INC	DCBDRV		; 1-ALIGN THE DRIVE ID

	LDX	TSLOT		; MAKE TEMP DRIVE SLOT
;	STX	GSLOT		; DEFAULT
	INX			; 1-ALIGN
	TXA
	ASL	A		; * 16 FOR # RWTS NEEDS
	ASL	A
	ASL	A
	ASL	A
	STA	DCBSLT		; AND SET SLOT ACCORDINGLY

	LDA	TPOSIT		; MAKE THE TEMP POSITION
;	STA	GPOSIT		; THE DEFAULT POSITION

	; CALC TRACK & SECTOR OF GAME POSITION
	; 64 SECTORS PER SAVE (AS PER OLD ZIP)
	; SO 4 TRACKS AT 16 SECTORS EACH

	ASL	A		; *2
	ASL	A		; POSITION * 4
	STA	DCBTRK		; GIVES THE TRACK
	LDA	#0
	STA	DCBSEC		; SECTOR ALWAYS 0 TO START

	LDX	#LOW INSM
	LDA	#HIGH INSM
	LDY	#INSML
	JSR	DLINE		; "INSERT SAVE DISK IN DRIVE X."

	; FALL THROUGH ...

	; ---------------------
	; "PRESS RETURN" PROMPT
	; ---------------------

RETURN:	LDX	#LOW RTN
	LDA	#HIGH RTN
	LDY	#RTNL
	JSR	DLINE		; SHOW PROMPT

	; ENTRY FOR QUIT/RESTART

GETRET:	JSR	GETKEY		; WAIT FOR [RETURN]
	CMP	#EOL
	BEQ	GTRT1
	JSR	BOOP		; ACCEPT NO
	JMP	GETRET		; SUBSTITUTES!

GTRT1:	RTS

RTN:	DB	EOL
	DB	"Press [RETURN] to continue."
	DB	EOL
	DB	">"
RTNL	EQU	$-RTN

	; --------------------
	; PROMPT FOR GAME DISK
	; --------------------

GAME:	DB	EOL
	DB	"Insert the STORY disk into Drive #1."
GAMEL	EQU	$-GAME

SIDE2:	LDA	DCBDRV		; HOLD LAST DRIVE USED
	PHA
	LDA	STRYDR		; MAKE SURE WE'RE ON
	LDX	STRYSL		; THE BOOT DRIVE
	STA	DCBDRV
	STX	DCBSLT

	PLA			; DID THEY USE DR.2
	CMP	#2
	BEQ	SIDEX		; YES, DON'T PROMPT

SIDEL:	LDX	#LOW GAME
	LDA	#HIGH GAME
	LDY	#GAMEL
	JSR	DLINE		; "INSERT STORY DISK"

	JSR	RETURN		; "PRESS [RETURN] TO CONTINUE:"

	; COMPARE 2ND PAGE OF INTERPRETER WITH 
	; CORRESPONDING SECTOR ON DISK TO 
	; VERIFY THAT STORY DISK WAS RE-INSERTED

	LDX	#1		; READ IN TRK 0, SEC 1
	STX	DCBSEC		; (PART OF INTERPRETER)
	DEX
	STX	DCBTRK

	TXA			; [0] - READ SECTOR
	JSR	DOS
	BCC	CHK1
	JMP	DSKER		; OOPS

CHK1:	LDA	#HIGH IOBUFF
	STA	I+HI
	LDA	#LOW IOBUFF
	STA	I+LO
	LDX	#HIGH ZIP
	INX			; 2ND PAGE WANTED
	STX	J+HI
	LDA	#LOW ZIP
	STA	J+LO

	LDY	#0		; COMPARE PAGE ON DISK
CHK2:	LDA	(I),Y		; WITH ONE IN MEMORY
	CMP	(J),Y
	BNE	SIDEL		; NO MATCH
	INY
	BNE	CHK2		; WHEN EQUAL MATCHED OK

SIDEX:	LDA	#$FF		; ENABLE
	STA	SCRIPT		; SCRIPTING
	RTS


	; -------------------------
	; SET UP PHONEY STATUS LINE
	; -------------------------

	; ENTRY: TEXT SET UP FOR "DLINE"

;SROOM:	JSR	DLINE		; PRINT LINE IN [X/Y/A]
;
;	LDX	#39		; INVERT & BLACKEN TOP LINE
;SRLP:	LDA	SCREEN,X
;	ORA	#%10000000
;	STA	SCREEN,X
;	DEX
;	BPL	SRLP
;	RTS

	; ---------
	; SAVE GAME
	; ---------

SAV:	DB	"Save Position"
	DB	EOL
SAVL	EQU	$-SAV

SVING:	DB	EOL
	DB	EOL
	DB	"Saving position "
SVPOS:	DB	"* ..."
	DB	EOL
SVINGL	EQU	$-SVING

ZSAVE:	LDA	WTOP		; SAVE CURRENT SCREEN TOP
	PHA
	JSR	SAVRES		; SET UP SCREEN

	LDX	#LOW SAV
	LDA	#HIGH SAV
	LDY	#SAVL
	JSR	DLINE		; "SAVE POSITION"

	JSR	PARAMS		; GET PARAMETERS

	LDX	#LOW SVING
	LDA	#HIGH SVING
	LDY	#SVINGL
	JSR	DLINE		; "SAVING POSITION X ..."

	; SAVE GAME PARAMETERS IN [BUFSAV]

	LDA	ZBEGIN+ZID	; MOVE GAME ID
	STA	BUFSAV+0	; INTO 1ST 2 BYTES
	LDA	ZBEGIN+ZID+1	; OF THE AUX LINE BUFFER
	STA	BUFSAV+1

	LDA	ZSP		; MOVE [ZSP]
	STA	BUFSAV+2	; TO 3RD BYTE
	LDA	OLDZSP		; MOVE [OLDZSP]
	STA	BUFSAV+3	; TO 4TH

	LDX	#2		; MOVE CONTENTS OF [ZPC]
ZPCSAV:	LDA	ZPC,X		; TO BYTES 5-7
	STA	BUFSAV+4,X	; OF [BUFSAV]
	DEX
	BPL	ZPCSAV

	; WRITE [LOCALS]/[BUFSAV] PAGE TO DISK

	LDA	#HIGH LOCALS
	STA	DBUFF+HI	; POINT TO THE PAGE
	JSR	PUTDSK		; AND WRITE IT OUT
	BCC	WSTACK		; IF SUCCEEDED, WRITE STACK

BADSAV:	JSR	SIDE2		; ELSE REQUEST STORY DISK
	PLA			; GET CURRENT SCREEN TOP
	STA	WTOP
	JSR	CLS
	JMP	PREDF		; AND FAIL

	; WRITE CONTENTS OF Z-STACK TO DISK

WSTACK:	LDA	#HIGH ZSTAKL	; POINT TO 1ST PAGE
	STA	DBUFF+HI
	JSR	PUTDSK		; WRITE 1ST AND
	BCS	BADSAV
	JSR	PUTDSK		; 2ND PAGE OF Z-STACK
	BCS	BADSAV

	; WRITE ENTIRE GAME PRELOAD TO DISK

	LDA	ZCODE		; POINT TO 1ST PAGE
	STA	DBUFF+HI	; OF PRELOAD

	LDX	ZBEGIN+ZPURBT	; GET # IMPURE PAGES
	INX			; USE FOR INDEXING
	STX	I+LO

LSAVE:	JSR	PUTDSK
	BCS	BADSAV
	DEC	I+LO
	BNE	LSAVE

	JSR	SIDE2		; PROMPT FOR GAME DISK
	LDA	TDRIVE		; OK, SUCCESSFUL, SO
	STA	GDRIVE		; SAVE PARAMS FOR
	LDA	TSLOT		; NEXT TIME
	STA	GSLOT
	LDA	TPOSIT
	STA	GPOSIT

	PLA			; GET CURRENT SCREEN TOP
	STA	WTOP
	JSR	CLS
	JMP	PREDS		; ELSE PREDICATE SUCCEEDS

	; ------------
	; RESTORE GAME
	; ------------

RES:	DB	"Restore Position"
	DB	EOL
RESL	EQU	$-RES

RSING:	DB	EOL
	DB	EOL
	DB	"Restoring position "
RSPOS:	DB	"* ..."
	DB	EOL
RSINGL	EQU	$-RSING

ZREST:	LDA	WTOP		;SAVE CURRENT SCREEN TOP
	PHA
	JSR	SAVRES

	LDX	#LOW RES
	LDA	#HIGH RES
	LDY	#RESL
	JSR	DLINE		; "RESTORE POSITION"

	JSR	PARAMS		; GET PARAMETERS

	LDX	#LOW RSING
	LDA	#HIGH RSING
	LDY	#RSINGL
	JSR	DLINE		; "RESTORING POSITION X ..."

	; SAVE LOCALS IN CASE OF ERROR

	LDX	#31
LOCSAV:	LDA	LOCALS,X	; COPY ALL LOCALS
	STA	$0100,X		; TO BOTTOM OF MACHINE STACK
	DEX
	BPL	LOCSAV

	LDA	#HIGH LOCALS
	STA	DBUFF+HI
	JSR	GETRES		; RETRIEVE 1ST BLOCK OF PRELOAD
	BCS	WRONG		; BAD DISK READ IF CARRY CLEAR

	LDA	BUFSAV+0	; DOES 1ST BYTE OF SAVED GAME ID
	CMP	ZBEGIN+ZID	; MATCH THE CURRENT ID?
	BNE	WRONG		; WRONG DISK IF NOT

	LDA	BUFSAV+1	; WHAT ABOUT THE 2ND BYTE?
	CMP	ZBEGIN+ZID+1
	BEQ	RIGHT		; CONTINUE IF BOTH BYTES MATCH

	; HANDLE RESTORE ERROR

WRONG:	LDX	#31		; RESTORE ALL SAVED LOCALS
WR0:	LDA	$0100,X
	STA	LOCALS,X
	DEX
	BPL	WR0

	JSR	SIDE2		; PROMPT FOR GAME DISK
	PLA			; RETRIEVE CURRENT SCREEN TOP
	STA	WTOP
	JSR	CLS
	JMP	PREDF		; PREDICATE FAILS

	; CONTINUE RESTORE

RIGHT:	LDA	ZBEGIN+ZSCRIP	; SAVE BOTH FLAG BYTES
	STA	I+LO
	LDA	ZBEGIN+ZSCRIP+1
	STA	I+HI

	LDA	#HIGH ZSTAKL	; RETRIEVE OLD CONTENTS OF
	STA	DBUFF+HI	; Z-STACK
	JSR	GETRES		; GET 1ST BLOCK OF Z-STACK
	BCS	WRONG
	JSR	GETRES		; AND 2ND BLOCK
	BCS	WRONG

	LDA	ZCODE
	STA	DBUFF+HI
	JSR	GETRES		; GET 1ST BLOCK OF PRELOAD
	BCS	WRONG

	LDA	I+LO		; RESTORE THE STATE
	STA	ZBEGIN+ZSCRIP	; OF THE FLAG WORD
	LDA	I+HI
	STA	ZBEGIN+ZSCRIP+1

	LDA	ZBEGIN+ZPURBT	; GET # PAGES TO LOAD
	STA	I+LO

LREST:	JSR	GETRES		; FETCH THE REMAINDER
	BCS	WRONG
	DEC	I+LO		; OF THE PRELOAD
	BNE	LREST

	; RESTORE THE STATE OF THE SAVED GAME

	LDA	BUFSAV+2	; RESTORE THE [ZSP]
	STA	ZSP
	LDA	BUFSAV+3	; AND THE [OLDZSP]
	STA	OLDZSP

	LDX	#2		; RESTORE THE [ZPC]
RESZPC:	LDA	BUFSAV+4,X
	STA	ZPC,X
	DEX
	BPL	RESZPC

	LDA	#0
	STA	ZPCFLG		; INVALIDATE [ZPC]

	JSR	SIDE2		; PROMPT FOR GAME DISK
	LDA	TDRIVE		; OK, SUCCESSFUL, SO
	STA	GDRIVE		; SAVE PARAMS FOR
	LDA	TSLOT		; NEXT TIME
	STA	GSLOT
	LDA	TPOSIT
	STA	GPOSIT

	PLA			; RETRIEVE CURRENT SCREEN TOP
	STA	WTOP
	JSR	CLS
	JMP	PREDS		; PREDICATE SUCCEEDS

	END

