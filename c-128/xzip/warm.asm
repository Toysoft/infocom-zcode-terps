	PAGE
	STTL "--- WARMSTART ROUTINE ---"

	; -------------
	; ZIP WARMSTART
	; -------------

TMSG:	DB	"(Please be patient, this takes a while)"
	DB	EOL
TMSGL	EQU	$-TMSG

CMSG:	DB	EOL,EOL
	DB	"Do you want color?  "
CMSGL	EQU	$-CMSG

	; SET FCN KEYS SO THAT THEY = WHAT XZIP WANTS (MAKE RUN/STOP BEEP)
FCNKEY:	DB	0,133,134,135,136,137,138,139,140,7,143


WARM2:	LDA	#0		; CLEAR ALL Z-PAGE VARIABLES
	LDX	#ZEROPG
ST0:	STA	0,X
	INX
	CPX	#ZPGTOP
	BCC	ST0

	STA	CSFLAG		; clear ^S flag

	INC	ZSP+LO		; INIT Z-STACK POINTERS
	INC	OLDZSP+LO	; TO "1"
	INC	SCRIPT		; ENABLE SCRIPTING
	INC	SCREENF		; TURN DISPLAY ON
	INC	SIDEFLG		; SET SIDE 1

	LDA	#%00001110	; DO IT AGAIN AS JUST
	STA	BANK0		; WIPED IT OUT
	LDA	#%01111111
	STA	BANK1
	LDA	#%00111110
	STA	BANK2

	; GRAB THE FIRST BLOCK OF PRELOAD

	LDA	#>ZBEGIN	; MSB OF PRELOAD START ADDRESS
	STA	ZCODE		; FREEZE IT HERE
	STA	DBUFF+HI	; LSB IS ALWAYS ZERO
	LDA	#MAIN	
	STA	DSKBNK		; SET TO MAIN BANK
	LDA	#1		; Set ZPURE to 100 to fake
	STA	ZPURE+HI	; GETDSK out this first time through
	JSR	GETDSK		; [DBLOCK] SET TO Z-BLOCK 0
	BCC	CHKGAM
	JMP	DSKERR		; BAD DISK READ

	; EXTRACT GAME DATA FROM Z-CODE HEADER

CHKGAM:	LDA	ZBEGIN+ZVERS	; (XZIP) IS GAME AN XZIP?
	CMP	#5		; 5 means xzip
	BEQ	YESEZ		; YES, CONTINUE

; *** ERROR #16 -- NOT AN EZIP GAME ***
	LDA	#16	
	JMP	ZERROR	
YESEZ:
	LDA	ZBEGIN+ZENDLD	; MSB OF ENDLOAD POINTER
	STA	ZPURE+HI	; GOT TO FIGURE OUT FIRST PAGE
	LDA	ZBEGIN+ZENDLD+1	; of data on side 2
	STA	ZPURE+LO	; ok?

	LSR	ZPURE+HI	; SO WE NEED TO /64 TO GET IT
	ROR	ZPURE+LO	; SO DO 6 SHITS
	LSR	ZPURE+HI
	ROR	ZPURE+LO
	LSR	ZPURE+HI
	ROR	ZPURE+LO
	LSR	ZPURE+HI
	ROR	ZPURE+LO
	LSR	ZPURE+HI
	ROR	ZPURE+LO
	LSR	ZPURE+HI	; NOW IT CONTAINS FIRST PAGE ON
	ROR	ZPURE+LO	; SIDE 2 OF THE DISK

	LDA	#%00111000	; WITH UNDERLINE, MONOSPACE AND
	STA	ZBEGIN+ZMODE	; SOUND

	LDA	#XZIPID		; SET INTERPRETER ID
	STA	ZBEGIN+ZINTWD	
	LDA	#VERSID	
	STA	ZBEGIN+ZINTWD+1	
	LDA	#0		; CLEAR TOP BYTE
	STA	ZBEGIN+ZHWRD
	STA	ZBEGIN+ZVWRD
	LDA	#79		; SET SCREEN PARAMETERS
	STA	ZBEGIN+ZHWRD+1
	LDA	#24
	STA	ZBEGIN+ZVWRD+1
	LDA	#1		; EACH "PIXEL" IS 1*1
	STA	ZBEGIN+ZFWRD
	STA	ZBEGIN+ZFWRD+1
	LDA	#24		; AND SCREEN PARAMETERS
	STA	ZBEGIN+ZSCRWD	
	LDA	#79
	STA	ZBEGIN+ZSCRWD+1	
	LDA	#2		; DEFAULT COLORS
	STA	ZBEGIN+ZCLRWD	; CYAN ON BLACK
	LDA	#8
	STA	ZBEGIN+ZCLRWD+1

	LDA	ZBEGIN+ZGLOBA	; GET MSB OF GLOBAL TABLE ADDR
	CLC			; CONVERT TO
	ADC	ZCODE		; ABSOLUTE ADDRESS
	STA	GLOBAL+HI	
	LDA	ZBEGIN+ZGLOBA+1	; LSB NEEDN'T CHANGE
	STA	GLOBAL+LO	

	LDA	ZBEGIN+ZFWORD	; DO SAME FOR FWORDS TABLE
	CLC		
	ADC	ZCODE	
	STA	FWORDS+HI	
	LDA	ZBEGIN+ZFWORD+1	; NO CHANGE FOR LSB
	STA	FWORDS+LO	

	LDA	ZBEGIN+ZOBJEC	; NOT TO MENTION
	CLC			; THE OBJECT TABLE
	ADC	ZCODE	
	STA	OBJTAB+HI	
	LDA	ZBEGIN+ZOBJEC+1	; LSB SAME
	STA	OBJTAB+LO	

	LDA	ZBEGIN+ZTCHAR	; DO SAME FOR TCHARS TABLE
	ORA	ZBEGIN+ZTCHAR+1	; is it zero though?
	BEQ	INICLL

	LDA	ZBEGIN+ZTCHAR	; DO SAME FOR TCHARS TABLE
	CLC
	ADC	ZCODE
	STA	TCHARS+HI
	LDA	ZBEGIN+ZTCHAR+1	; NO CHANGE FOR LSB
	STA	TCHARS+LO

	; FIND SIZE AND NUMBER OF SAVES

INICLL:
	LDA	ZBEGIN+ZPURBT	; SIZE OF IMPURE
	CMP	#$A0		; MAXIMUM IMPURE IS $A000 (36K)
	BCC	SIZE0		; OKAY, CONTINUE

	LDA	#13
	JMP 	ZERROR		; ELSE ERROR #13 (IMPURE TOO BIG)

SIZE0:	ADC	#6		; PLUS ZSTACK &...
	STA	SAVSIZ		; HOW MANY PAGES PER SAVE

	LDX	#0
	STX	NUMSAV
SIZE1:	INC	NUMSAV		; INC NUMSAVE WITH EACH 
	CLC			; POSSIBLE SAVE
	ADC	SAVSIZ
	BCC	SIZE1
SIZE2:	INC	NUMSAV		; TOTAL SIZE IS 170K - 1, ($297)
	CLC
	ADC	SAVSIZ		; SO DO LOOP FOR 1ST & 2ND $100
	BCC	SIZE2
SIZE3:	CMP	#$97
	BCS	SIZE4		; BEYOND TOTAL DISK SIZE
	INC	NUMSAV
	CLC
	ADC	SAVSIZ
	BCC	SIZE3
SIZE4:
	LDA	NUMSAV
	CMP	#9
	BCC	SZj
	LDA	#9		; just make it 9 for ease
SZj:
	CLC
	ADC	#'0'
	STA	POSTOP		; SET POSITION MSG

	LDY	#21		; POSITION MESSAGE
	LDX	#14
	CLC
	JSR	PLOT

	LDX	#<TMSG
	LDA	#>TMSG
	LDY	#TMSGL
	JSR	DLINE

	JSR	LDFNTS		; LOAD IN ALT CHAR SETS
	JSR	INITPAG		; INIT PAGING AND LOAD IN GAME

	LDA	#CLS		; GET RID OF "LOADING" MSG
	JSR	CHROUT

	LDA	TCHARS+HI
	ORA	TCHARS+LO
	BEQ	TCHj		; no tchars table

	LDY	#$FF		; CHECK IF $FF IS IN TCHARS TBL
TCHLP:	INY
	LDA	(TCHARS),Y
	BEQ	TCHj		; NULL TERMINATED STRING
	CMP	#$FF
	BNE	TCHLP
	LDA	#1
	STA	ALLFLG		; YES, SET ALL FCN KEYS (>127) TO TERMINATORS
TCHj:
	LDX	#<CMSG		; ASK IF WANT TO USE COLOR
	LDA	#>CMSG
	LDY	#CMSGL
	JSR	DLINE
	JSR	GETYES
	BCS	OVERC		; NO, NO COLOR PLEASE
CON:
	LDA	ZBEGIN+ZMODE
	ORA	#%00000001
	STA	ZBEGIN+ZMODE
OVERC:
	LDA	ZBEGIN+ZGO	; GET START ADDRESS OF Z-CODE
	STA	ZPCM		; MSB
	LDA	ZBEGIN+ZGO+1	; AND LSB
	STA	ZPCL		; HIGH BIT ALREADY ZEROED
	JSR	VLDZPC		; MAKE ZPC VALID

	LDX	WWIDTH
	STX	XSIZE
	STX	OLDWD		; JIC

	; SET THE FUNCTION KEYS (1-9 AND HELP IS 10) TO RETURN XZIP VALUE
	; INSTEAD OF THE STRINGS FROM BASIC (HELP, RUN, DLOAD...)

	LDA	#1
	STA	I		; START WITH FCN KEY 1

LOOP:	LDA	#<FCNKEY
	CLC
	ADC	I		; HAS COUNT OF WHICH FCN KEY
	STA	$FA
	LDA	#>FCNKEY
	ADC	#0		; PICK UP CARRY IF THERE
	STA	$FB
	LDA	#1		; AND BASIC BANK REPRESENTATION
	STA	$FC		; USE BANK 1 AS THIS XZIP IS IN BANK 1

	LDA	#$FA
	LDX	I		; FCN KEY #
	LDY	#$01		; # OF CHARS IN STRING
	JSR	SETFCN		; AND CALL FCN THAT RESETS FCN KEY RETURN

	INC	I
	LDA	I
	CMP	#11
	BNE	LOOP		; USE 9 FCN KEYS, MAKE RUN/STOP JUST BEEP

	LDA	PSTAT		; CHECK IF RESTART & WERE PRINTING
	CMP	#1
	BNE	EX2		; NO
	STA	SCRIPTF		; YES, TURN SCRIPT FLAG ON
	ORA	ZBEGIN+ZSCRIP+1	; SET GAME FLAG ALSO
	STA	ZBEGIN+ZSCRIP+1	

EX2:	LDA	#CLS		; CLEAR SCREEN ...
	JSR	CHROUT

	; ... AND FALL INTO MAIN LOOP

	END
