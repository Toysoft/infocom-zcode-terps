	PAGE	
	SBTTL "--- MEMORY ORGANIZATION ---"


TRUE	EQU	$FF	
FALSE	EQU	0	
LO	EQU	0	
HI	EQU	1	

; SEE "HARDEQ.ASM" FOR APPLE II MEMORY MAP
; ---------------------
; Z-CODE HEADER OFFSETS
; ---------------------

ZVERS	EQU	0	; VERSION BYTE
ZMODE	EQU	1	; MODE SELECT BYTE
ZID	EQU	2	; GAME ID WORD
ZENDLD	EQU	4	; START OF NON-PRELOADED Z-CODE
ZGO	EQU	6	; EXECUTION ADDRESS
ZVOCAB	EQU	8	; START OF VOCABULARY TABLE
ZOBJEC	EQU	10	; START OF OBJECT TABLE
ZGLOBA	EQU	12	; START OF GLOBAL VARIABLE TABLE
ZPURBT	EQU	14	; START OF "PURE" Z-CODE
ZSCRIP	EQU	16	; FLAG WORD
ZSERIA	EQU	18	; 3-WORD DB	II SERIAL NUMBER
ZFWORD	EQU	24	; START OF FWORDS TABLE
ZLENTH	EQU	26	; LENGTH OF Z-PROGRAM IN WORDS
ZCHKSM	EQU	28	; Z-CODE CHECKSUM WORD
ZINTWD	EQU	30	; INTERPRETER ID WORD (SUPPLIED BY EZIP)
ZSCRWD	EQU	32	; SCREEN PARAMETER WORD ( "     "   "  )


	PAGE	
	SBTTL "--- ZIP Z-PAGE VARIABLES ---"


ZEROPG	EQU	$56		; FIRST FREE Z-PAGE LOCATION
OPCODE	EQU	ZEROPG		; (BYTE) CURRENT OPCODE
NARGS	EQU	OPCODE+1	; (BYTE) # ARGUMENTS
ARG1	EQU	OPCODE+2	; (WORD) ARGUMENT #1
ARG2	EQU	OPCODE+4	; (WORD) ARGUMENT #2
ARG3	EQU	OPCODE+6	; (WORD) ARGUMENT #3
ARG4	EQU	OPCODE+8	; (WORD) ARGUMENT #4
ARG5	EQU	OPCODE+10	; (WORD)
ARG6	EQU	OPCODE+12	; (WORD)
ARG7	EQU	OPCODE+14	; (WORD)
ARG8	EQU	OPCODE+16	; (WORD)
ABYTE	EQU	OPCODE+18	; (BYTE) X-OP ARGUMENT BYTE
BBYTE	EQU	OPCODE+19	; (BYTE) XCALL ARG BYTE (EZIP)
ADEX	EQU	OPCODE+20	; (BYTE) X-OP ARGUMENT INDEX
VALUE	EQU	OPCODE+21	; (WORD) VALUE RETURN REGISTER
I	EQU	VALUE+2		; (WORD) GEN-PURPOSE REGISTER #1
J	EQU	VALUE+4		; (WORD) GEN-PURPOSE REGISTER #2
K	EQU	VALUE+6		; (WORD) GEN-PURPOSE REGISTER #3
L	EQU	VALUE+8		; (WORD) GEN-PURPOSE REGISTER #4
ZPC	EQU	VALUE+10	;ZSP+4  ; (3 BYTES) ZIP PROGRAM COUNTER
ZPCL	EQU	ZPC		; (BYTE) LOW 8 BITS OF [ZPC]
ZPCM	EQU	ZPC+1		; (BYTE) MIDDLE 8 BITS OF [ZPC]
ZPCH	EQU	ZPC+2		; (BYTE) HIGH BIT OF [ZPC]
ZPCPNT	EQU	ZPC+3		; (3 BYTES) ABS POINTER TO CURRENT Z-PAGE
ZPNTL	EQU	ZPCPNT		; FIRST 2 BYTES = SAME AS FOR ZIP (EZIP)
ZPNTH	EQU	ZPCPNT+1	; (BYTE)
ZPCBNK	EQU	ZPCPNT+2	; (BYTE) INDICATES AUXILIARY MEMORY
MPC	EQU	ZPCPNT+3	; (3 BYTES) MEMORY PROGRAM COUNTER
MPCL	EQU	MPC		; (BYTE) LOW 8 BITS OF [MPC]
MPCM	EQU	MPC+1		; (BYTE) MIDDLE 8 BITS OF [MPC]
MPCH	EQU	MPC+2		; (BYTE) HIGH BIT OF [MPC]
MPCPNT	EQU	MPC+3		; (3 BYTES) ABS POINTER TO CURRENT M-PAGE
MPNTL	EQU	MPCPNT		; FIRST 2 BYTES = SAME AS FOR ZIP (EZIP)
MPNTH	EQU	MPCPNT+1	; (BYTE)
MPCBNK	EQU	MPCPNT+2	; (BYTE) INDICATES AUXILIARY MEMORY
ZCODE	EQU	MPCPNT+3	; (BYTE) 1ST ABSOLUTE PAGE OF PRELOAD
ZPURE	EQU	ZCODE+1		; (BYTE) 1ST VIRTUAL PAGE OF "PURE" Z-CODE
GLOBAL	EQU	ZCODE+2		; (WORD) GLOBAL VARIABLE POINTER
VOCAB	EQU	GLOBAL+2	; (WORD) VOCAB TABLE POINTER
FWORDS	EQU	GLOBAL+4	; (WORD) F-WORDS TABLE POINTER
OBJTAB	EQU	GLOBAL+6	; (WORD) OBJECT TABLE POINTER

; Z-STRING MANIPULATION VARIABLES

IN	EQU	GLOBAL+8	; (9 BYTES) INPUT BUFFER
OUT	EQU	IN+9		; (9 BYTES) OUTPUT BUFFER
SOURCE	EQU	OUT+9		; (BYTE) SOURCE BUFFER POINTER
RESULT	EQU	SOURCE+1	; (BYTE) RESULT TABLE POINTER
LINLEN	EQU	SOURCE+2	; (BYTE) LENGTH OF CURRENT LINE
WRDLEN	EQU	SOURCE+3	; (BYTE) LENGTH OF CURRENT WORD
ENTRY	EQU	SOURCE+4	; (WORD) ADDR OF CURRENT RESULT ENTRY
NENTS	EQU	SOURCE+6	; (WORD) # ENTRIES IN VOCAB TABLE
ESIZE	EQU	SOURCE+8	; (BYTE) SIZE OF VOCAB TABLE ENTRIES
PSET	EQU	SOURCE+9	; (BYTE) PERMANENT CHARSET
TSET	EQU	SOURCE+10	; (BYTE) TEMPORARY CHARSET
ZCHAR	EQU	SOURCE+11	; (BYTE) CURRENT Z-CHAR
OFFSET	EQU	SOURCE+12	; (BYTE) F-WORD TABLE OFFSET
ZFLAG	EQU	SOURCE+13	; (BYTE) Z-WORD ACCESS FLAG
ZWORD	EQU	SOURCE+14	; (WORD) CURRENT Z-WORD
CONCNT	EQU	SOURCE+16	; (BYTE) Z-STRING SOURCE COUNTER
CONIN	EQU	SOURCE+17	; (BYTE) CONVERSION SOURCE INDEX
CONOUT	EQU	SOURCE+18	; (BYTE) CONVERSION DEST INDEX
DBLOCK	EQU	SOURCE+19	; (WORD) Z-BLOCK TO READ
DBUFF	EQU	DBLOCK+2	; (WORD) RAM PG TO ACCESS (LSB = 0)
PAGEOT	EQU	DBLOCK+4	; (WORD) ZPCH,M OF 1ST VIRTUAL PAGE

; THAT WILL HAVE TO GO IN PAGENG

DIRFLG	EQU	PAGEOT+2	; (BYTE) OUTPUT TO SCREEN (0) TABLE (1) FLAG
DIRTBL	EQU	PAGEOT+3	; (WORD) CONTAINS TBLE TO STORE CHARS TO
DIRITM	EQU	PAGEOT+5	; (WORD) OFFSET IN OUTPUT TBL (DIRTBL)
DIRCNT	EQU	PAGEOT+7	; (WORD) COUNT OF CHARS IN TBL (DIRTBL)
BUFFLG	EQU	PAGEOT+9	; (BYTE) DISPLAY BUFFERED (0) UNBUFFERED (1)
CHRMAX	EQU	PAGEOT+10	; (BYTE) # CHARS CAN INPUT FROM KEYBOARD
XSIZE	EQU	PAGEOT+11	; (BYTE) SCREEN WIDTH FOR TESTS
RAND1	EQU	XSIZE+1		; (BYTE)
RAND2	EQU	XSIZE+2		; (BYTE) RANDOM #
SPLITF	EQU	XSIZE+3		; (BYTE) WHICH WINDOW TO WRITE IN
RDTBL1	EQU	XSIZE+4		; (WORD) READ TABLE 1 (ABSOLUTE- EZIP)
RDTBL2	EQU	RDTBL1+2	; (WORD) READ TABLE 2
QUOT	EQU	RDTBL1+4	; (WORD) QUOTIENT FOR DIVISION
REMAIN	EQU	QUOT+2		; (WORD) REMAINDER FOR DIVISION
MTEMP	EQU	REMAIN+2	; (WORD) MATH TEMPORARY REGISTER
QSIGN	EQU	MTEMP+2		;(BYTE) SIGN OF QUOTIENT
RSIGN	EQU	QSIGN+1		; (BYTE) SIGN OF REMAINDER
DIGITS	EQU	RSIGN+1		; (BYTE) DIGIT COUNT FOR "PRINTN"
LENGTH	EQU	DIGITS+1	; (BYTE) CHAR POSITION ON THE SCREEN
CHRCNT	EQU	LENGTH+1	; (BYTE) CHAR POSITION IN [LBUFF]
OLDLEN	EQU	CHRCNT+1	; (BYTE) OLD LINE LENGTH
OLDEND	EQU	OLDLEN+1	; (BYTE) OLD LAST CHAR IN [LBUFF]
SCRIPT	EQU	OLDEND+1	; (BYTE) SCRIPT ENABLE FLAG
LINCNT	EQU	SCRIPT+1	; (BYTE) LINE COUNTER
LMAX	EQU	LINCNT+1	; (BYTE) MAX # LINES/SCREEN
IOCHAR	EQU	LMAX+1		; (BYTE) CHARACTER BUFFER
SLINE	EQU	IOCHAR+1	; (BYTE) BORDERLINE FOR SPLIT
SPSTAT	EQU	SLINE+1		; (BYTE) SPLIT SCREEN STATUS FLAG
LFROM	EQU	SPSTAT+1	; (WORD) "FROM" LINE ADDRESS
LTO	EQU	LFROM+2		; (WORD) "TO" LINE ADDRESS
PRLEN	EQU	LTO+2		; (BYTE) SCRIPT LINE LENGTH
SECTOR	EQU	PRLEN+1		; (WORD) TARGET SECTOR
GPOSIT	EQU	SECTOR+2	; (BYTE) DEFAULT SAVE POSITION
GDRIVE	EQU	GPOSIT+1	; (BYTE) DEFAULT SAVE DRIVE
TPOSIT	EQU	GDRIVE+1	; (BYTE) TEMP SAVE POSITION
TDRIVE	EQU	TPOSIT+1	; (BYTE) TEMP SAVE DRIVE
TSLOT	EQU	TDRIVE+1	; (BYTE) TEMP SAVE SLOT
DRIVE	EQU	TSLOT+1		; (BYTE) CURRENT DRIVE
SIDEFLG	EQU	DRIVE+1		; (BYTE) =1 IF WE ARE ON SIDE 1 2 IF SIDE 2
SRHOLD	EQU	SIDEFLG+1	; (BYTE)
TIMER	EQU	SRHOLD+1	; (WORD) TIMED INPUT COUNTER
ZSP	EQU	TIMER+2		; (WORD)
OLDZSP	EQU	ZSP+2		; (WORD)
DBLK	EQU	OLDZSP+2	; (WORD)
SCREENF	EQU	DBLK+2		; (BYTE) DIROUT FLAG FOR SCREEN OUTPUT
SCRIPTF	EQU	SCREENF+1	; (BYTE) DIROUT FLAG FOR PRINTER OUTPUT
TABLEF	EQU	SCRIPTF+1	; (BYTE) DIROUT FLAG FOR TABLE OUTPUT
VOCEND	EQU	TABLEF+1	; (3 BYTES) HOLDS MPC IN VOCAB SEARCH
TSTVAL	EQU	TABLEF+4	; (BYTE) FOR MEMCHECK DONE AT START
LASTZP	EQU	TABLEF+5	; CHECK FOR OVER ZERO PAGE

	END
