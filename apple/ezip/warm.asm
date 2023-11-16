	PAGE	
	SBTTL "--- WARMSTART ROUTINE ---"


	; ---------------
	; WARMSTART ENTRY
	; ---------------

WARM:	LDA	DCBPSL		;SAVE STORY DRIVE AND SLOT
	LDX	DCBPDR		;IN CASE CHANGED BY "SAVE"
	STA	STRYSL	
	STX	STRYDR	
	JSR	CLS	


	; -------------
	; ZIP WARMSTART
	; -------------

WARM1:	LDA	#10	;CENTER DISPLAY
	STA	CV	
	LDA	#27	
	STA	CHZ	
	STA	EHZ	
	JSR	BASCAL	
	LDA	#>STRYM	;DISP. "THE STORY IS LOADING..."
	LDX	#<STRYM	
	LDY	#STRYML	
	JSR	DLINE	
	LDA	#0		; CLEAR ALL Z-PAGE VARIABLES
	LDX	#ZEROPG	
WL0:	STA	0,X	
	INX		
	BNE	WL0	
	INC	ZSP+LO		; INIT Z-STACK POINTERS
	INC	OLDZSP+LO	; TO "1"
	INC	SCRIPT		; ENABLE SCRIPTING
	INC	SCREENF		; TURN DISPLAY ON
	INC	SIDEFLG		;SET SIDE 1

	; GRAB THE FIRST BLOCK OF PRELOAD

	LDA	#>ZBEGIN	; MSB OF PRELOAD START ADDRESS
	STA	ZCODE		; FREEZE IT HERE
	STA	DBUFF+HI	; LSB IS ALWAYS ZERO
	LDA	#MAIN	
	STA	DSKBNK		;SET TO MAIN BANK
	JSR	GETDSK		; [DBLOCK] SET TO Z-BLOCK 0

	; EXTRACT GAME DATA FROM Z-CODE HEADER

	LDA	ZBEGIN+ZVERS	; (EZIP) IS GAME AN EZIP?
	CMP	#4	
	BEQ	YESEZ		; YES, CONTINUE

; *** ERROR #15 -- NOT AN EZIP GAME ***
	LDA	#15	
	JMP	ZERROR	

; *** ERROR #0 -- INSUFFICIENT RAM ***
NORAM:	LDA	#5	
	STA	CV	
	JSR	BASCAL	
	LDA	#0	
	JMP	ZERROR	

YESEZ:	LDA 	ZBEGIN+ZPURBT	; CHECK PURBOT POINTER
	CMP	#$AD		; MAXIMUM IMPURE IS $AD00 (43K)
	BCC	YZ1		; OKAY, CONTINUE

	LDA	#13
	JMP 	ZERROR		; ELSE ERROR #13 (IMPURE TOO BIG)

YZ1:	CMP	#$80		; IMPURE > 32K?
	BCC	YZ2		; NO, USE 4 SAVES PER DISK

	LDA	#3		; ELSE USE ONLY 3
	BNE	YZ3

YZ2:	LDA	#4
YZ3:	STA	NUMSAV		; REMEMBER MAXIMUM # SAVES PER DISK
	CLC
	ADC	#'0'		; CONVERT TO ASCII
	STA	SAVASC		; SAVE IN STRING

	LDX	ZBEGIN+ZENDLD	; MSB OF ENDLOAD POINTER
	INX			; ADD 1 TO GET
	STX	ZPURE		; 1ST "PURE" PAGE OF Z-CODE
	LDA	ZBEGIN+ZMODE	; ENABLE SPLIT-SCREEN,
	ORA	#%00110011	; INVERSE, CURSOR CONTROL,
	STA	ZBEGIN+ZMODE	; SOUND (EZIP)
	LDA	#EZIPID		; SET INTERPRETER ID
	STA	ZBEGIN+ZINTWD	
	LDA	#VERSID	
	STA	ZBEGIN+ZINTWD+1	
	LDA	#$18		; AND SCREEN PARAMETERS
	STA	ZBEGIN+ZSCRWD	
	LDA	#80	
	STA	ZBEGIN+ZSCRWD+1	
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
	JSR	INITPAG	
	JSR	CLS		; GET RID OF "LOADING" MSG
	LDA	ZBEGIN+ZGO	; GET START ADDRESS OF Z-CODE
	STA	ZPCM		; MSB
	LDA	ZBEGIN+ZGO+1	; AND LSB
	STA	ZPCL		; HIGH BIT ALREADY ZEROED
	JSR	VLDZPC		;MACKE ZPC VALID
	LDX	WWIDTH		; SET XSIZE TO 1 LESS
	DEX		
	STX	XSIZE	
	LDA	PSTAT		; CHECK IF RESTART & WERE PRINTING
	BPL	EX2		; NO
	LDA	#1		; YES
	STA	PSTAT		; RESET PSTAT FOR NEXT TIME
	STA	SCRIPTF		; TURN SCRIPT FLAG ON
	ORA	ZBEGIN+ZSCRIP+1	; SET GAME FLAG ALSO
	STA	ZBEGIN+ZSCRIP+1	
EX2:	JSR	CLS		; CLEAR SCREEN ...


	; ... AND FALL INTO MAIN LOOP

	END
