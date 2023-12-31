
* ___________________________________________________________________________
* 
* XZIP INTERPRETER FOR THE ATARI ST
* 
* INFOCOM, INC. COMPANY CONFIDENTIAL -- NOT FOR DISTRIBUTION
*
* WRITTEN BY DUNCAN BLANCHARD
* ___________________________________________________________________________
* 

* XZIP MODIFICATION HISTORY:
* 
*    02 FEB 87	DBB	MODIFIED EZIP 
*    21 MAY 87	DBB	ADDED LOWCORE, MOUSE VARS
*    02 JUN 87	DBB	MOVED DUPNAM CHECK (_exist_file) INTO C
*    25 JUN 87	DBB	CHANGED OPFONT TO IGNORE REDUNDANT FONT CHANGES
*			FIXED STACK BUG, RESTORE VS. TIMER INTERRUPT
*    13 JUL 87	DBB	BUFFER FLUSHED IN OPSCRN, OPDIRO, OPERASE, OPCLEAR
*			CHKDSK MODIFIED FOR FULL PRELOAD SITUATION,
*			RESTART, $VER MAKE SPECIAL CHECKS FOR GAME DISK
*    17 SEP 87  DBB	OPCLEAR (W0) RESETS LINES(A6) FOR SCROLLING
*			OPREST PRESERVES COLOR BIT, OTHER SCREEN VARS
*			SCRIPT IN W1 SUPPRESSED IN SCRCHR
*			XZIP A	FROZEN
*     8 FEB 88  DBB	FIXED COPYT, PRINTT (BZ PAGING BUG)
*			FIXED 'HINT DISPLAY' FOLDING BUG (OPINPUT -> PUTLIN1)
*     1 MAR 88	DBB	ADDED SOUND DRIVER, SOUND INTERRUPTS
*			MOVED 'UNDO' ALLOCATION BEFORE PRELOAD
*			ADJUSTED PUTLIN/PUTLIN1 calls
*			XZIP B FROZEN
*
* IDEAS FOR FURTHER OVERHAUL
*
* -  MAKE ALL OPERATORS TAKE ARGS IN SLOTS (INDEXED OFF A6, NOT A0) RATHER 
*    THAN REGISTERS, NOW THAT SO MANY ARE OPTIONALS.  PASS A1 -> FIRST ARG 
*    FOR CONVENIENCE ((A1)++).  REDUCES NEED TO SAVE/RESTORE ARGS, SIMPLIFIES
*    USAGE.
*
* ZIP/EZIP MODIFICATION HISTORY:
* 
*    02 AUG 85	ZIP A	FROZEN
*    09 AUG 85		CLSGAM CHECKS WHETHER GAME FILE WAS OPENED
*    09 AUG 85		REBUILT OBJECT FILE WITH NEW LIBRARIES,
*			  INCREASED MACHINE STACK TO 2K (IN ZIPSTART)
*    09 AUG 85	ZIP B	FROZEN
*    		EZIP A	FROZEN
*    10 FEB 86		PURE PRELOAD MAY EXCEED 32K (PUT, PUTB, PTSIZE)
*			OPSPLT (EZIP) NO LONGER CLEARS SCREEN
*    10 APR 86		CHANGED PUTCHR (SPECIAL HANDLING FOR TABLE OUTPUT)
*			ADDED SCRNAM, SCRIPTS SAVE/RESTORE FILENAMES
*    18 APR 86		CHANGED NXTLIN/BUFOUT/LINOUT.  BUFOUT CALLS NXTLIN
*			  SO [MORE] IS TIMED CORRECTLY DURING BOLDFACE, ETC
*			CHANGED OPATTR AND DQUE INIT, FOR ITALICS HACK
*			FIXED GETMEM, PREVENTS ST BUG WITH ODD MEM REQUEST
*    08 MAY 86		FIXED QUECHR (QCX2A), ALLOW FOR EMPTY [DUMPED] BUFFER 
*			CHANGED OPREAD, ONLY OVERFLOW WORDS ARE FLUSHED
*    13 MAY 86		LINES(A6) NOW NORMALLY RESET TO ZERO, UPDATED INCHR
*			OPINPUT CHECKS VOBUFF(A6)
*			OPSPLIT CHECKS MAXIMUM SIZE OF split_row
*			NXTLIN TURNS OFF HIGHLIGHTING BEFORE PRINTING [MORE]
*			COMBINED READLN AND INCHR
*		EZIP B  FROZEN
*

* ---------------------------------------------------------------------------
* REGISTER CONVENTIONS
* ---------------------------------------------------------------------------

* GENERALLY, SINGLE ARGUMENTS ARE PASSED IN D0 OR A0.  SINGLE VALUES ARE
* LIKEWISE RETURNED IN D0 OR A0.  IN ANY CASE, THESE ARE SCRATCH REGISTERS
* AND NEED NOT BE PRESERVED.  ALL OTHER REGISTERS, EXCEPT WHERE OTHERWISE
* SPECIFIED, MUST BE PRESERVED ACROSS EACH SUBROUTINE CALL.  NOTE THAT
* TOP-LEVEL ROUTINES, OPx ROUTINES, ARE EXCLUDED FROM THIS RESTRICTION.

* DEDICATED REGISTERS:
*   A7 = SYSTEM SP
*   A6 = FRAME POINTER FOR ZIP VARIABLES	  *** STATIC ***
*   A5 = unused in this version
*   A4 = VIRTUAL SP

* ---------------------------------------------------------------------------
* ASSEMBLY FLAGS
* ---------------------------------------------------------------------------

* XZIP: SOURCES CAN'T BE CONDITIONALLY ASSEMBLED AS EZIP OR CLASSIC ZIP

EZIP	EQU	0	* XZIP: ALWAYS ON (0)
CZIP	EQU	-1	* XZIP: ALWAYS OFF (-1)
DEBUG	EQU	-1	* ASSEMBLES DEBUGGING CODE WHEN CLEAR

* ---------------------------------------------------------------------------
* INDEXING BASE FOR THE DISPATCH TABLE
* ---------------------------------------------------------------------------

ZBASE	NOP

    DATA		* ST LATTICE: BEGIN THE DATA SEGMENT
	DC.W	0	*   (KLUGE TO AVOID AN OBSCURE LINKER BUG ASSOCIATED
    TEXT		* WITH SUCCEEDING 'DC' STATEMENTS)

* ---------------------------------------------------------------------------
* GENERAL MACRO DEFINITIONS
* ---------------------------------------------------------------------------

* MACRO   ZERO
*	  MOVEQ   #0,%1		* CLEAR A REGISTER QUICKLY (BOTH WORDS)
* ENDM

* MACRO   SOB			* SUBTRACT ONE AND BRANCH IF NOT ZERO
*	  SUBQ.W  #1,%1
*	  BNE.S	  %2
* ENDM

* ---------------------------------------------------------------------------
* GENERAL EQUATES
* ---------------------------------------------------------------------------

ARG1	EQU	2	* ARGUMENT OFFSETS IN ARGUMENT BLOCK
ARG2	EQU	4
ARG3	EQU	6
ARG4	EQU	8

    IFEQ EZIP

VCHARS  EQU	9	* MAX CHARS IN AN EZIP VOCAB WORD
ZCHARS	EQU	6	* EZIP: BYTES PER ZWORD

OPLEN	EQU	63*2	* OBJECT PROPERTY DEFAULT TABLE LENGTH
OLEN	EQU	14	* OBJECT LENGTH

LOC	EQU	6	* PARENT
NEXT	EQU	8	* NEXT SIBLING
FIRST	EQU	10	* FIRST CHILD
PROP	EQU	12	* PROPERTY TABLE POINTER

PMASK	EQU	$003F	* PROPERTY NUMBER IS LOW 6 BITS (OF FIRST ID BYTE)
PLBIT	EQU	6	* PROPERTY LENGTH BIT (IF LENGTH IS TWO OR ONE)

    ENDC
    IFEQ CZIP

VCHARS  EQU	6	* MAX CHARS IN A ZIP VOCAB WORD
ZCHARS	EQU	4	* CZIP: BYTES PER ZWORD

OPLEN	EQU	31*2	* OBJECT PROPERTY DEFAULT TABLE LENGTH
OLEN	EQU	9	* OBJECT LENGTH

LOC	EQU	4	* PARENT
NEXT	EQU	5	* NEXT SIBLING
FIRST	EQU	6	* FIRST CHILD
PROP	EQU	7	* PROPERTY TABLE POINTER

PMASK	EQU	$001F	* PROPERTY NUMBER IS LOW 5 BITS (OF SINGLE ID BYTE)
PLBIT	EQU	5	* PROPERTY LENGTH BIT (LOWEST OF 3 LENGTH BITS)

    ENDC

* ---------------------------------------------------------------------------
* EXTERNALLY DEFINED VARIABLES
* ---------------------------------------------------------------------------

    XREF	_mono		* monochrome 
    XREF	_w0font
    XREF	_w1font
    XREF	_wind1
    XREF	_marg_left
    XREF	_marg_right

    XREF	_columns	* TOTAL COLUMNS IN DISPLAY
    XREF	_cur_column	* 0 .. COLUMNS -1 
    XREF	_rows		* TOTAL ROWS IN DISPLAY
    XREF	_cur_row	* 0 .. ROWS -1
    XREF	_split_row	* FIRST ROW IN SCROLLING WINDOW
    XREF	_xmouse		* mouse position (char units, zero origin)
    XREF	_ymouse

    XREF	_filename
    XREF	_fullname
    XREF	_v_italic

    XREF	_clear_eol
    XREF	_clear_lines
    XREF	_clear_screen
    XREF	_highlight
    XREF	_op_color
    XREF	_op_picinf
    XREF	_op_display

    XREF	_event_in	/* was _char_in */
    XREF	_char_out
    XREF	_line_out
    XREF	_do_input
    XREF	_time200

    XREF	_zalloc
    XREF	_file_select
    XREF	_new_default
    XREF	_exist_file

    XREF	_open_game		* LONG open_game ()
    XREF	_close_game		* LONG close_game (refnum)
    XREF	_create_file
    XREF	_open_file
    XREF	_read_file
    XREF	_write_file
    XREF	_close_file
    XREF	_delete_file

    XREF	_end_title

* ---------------------------------------------------------------------------
* ZIP VARIABLES - INDEXED OFF A6
* ---------------------------------------------------------------------------

ZORKID  EQU	0-2		* UNIQUE GAME AND VERSION ID
TIMEMD  EQU	ZORKID-2	* HOURS/MINUTES MODE FLAG
ENDLOD  EQU	TIMEMD-2	* END OF PRELOAD (FIRST PAGED BLOCK NUMBER)
PURBOT  EQU	ENDLOD-2	* END OF IMPURE (FIRST PURE BLOCK NUMBER)

VOCTAB  EQU	PURBOT-4	* VOCABULARY TABLE POINTER
OBJTAB  EQU	VOCTAB-4	* OBJECT TABLE POINTER
GLOTAB  EQU	OBJTAB-4	* GLOBAL TABLE POINTER
WRDTAB  EQU	GLOTAB-4	* FREQUENT WORD TABLE POINTER

RBRKS	EQU	WRDTAB-4	* POINTER TO STRING OF READ-BREAK CHARS
ESIBKS  EQU	RBRKS-4		* END OF SELF-INSERTING BREAK CHARS (+1)

VWLEN	EQU	ESIBKS-2	* NUMBER OF BYTES IN A VOCAB WORD ENTRY
VWORDS  EQU	VWLEN-2		* NUMBER OF VOCABULARY WORDS
VOCBEG  EQU	VWORDS-4	* POINTER TO FIRST VOCAB WORD
VOCEND  EQU	VOCBEG-4	* POINTER TO LAST VOCAB WORD

PAGTAB  EQU	VOCEND-4	* POINTER TO PAGE INFORMATION TABLE
PAGES	EQU	PAGTAB-4	* POINTER TO START OF PAGE BUFFERS

PAGTOT  EQU	PAGES-2		* NUMBER OF PAGE BUFFERS
MAXLOD	EQU	PAGTOT-2	* TOTAL BLOCKS IN GAME
MAXFLG	EQU	MAXLOD-2	* FLAG SET IF GAME FILE IS WHOLLY PRELOADED

TOPSP	EQU	MAXFLG-4	* TOP OF SYSTEM STACK
STKBOT  EQU	TOPSP-4		* BOTTOM OF GAME STACK

ZPC1	EQU	STKBOT-2	* ZORK PC, BLOCK POINTER (RELATIVE ADDRESS)
ZPC2	EQU	ZPC1-2		* ZORK PC, BYTE POINTER
NARGS	EQU	ZPC2-2		* (LOW BYTE) OPTIONAL ARG COUNT
ZLOCS	EQU	NARGS-4		* POINTER TO LOCALS (ABSOLUTE ADDRESS)

RSEED1  EQU	ZLOCS-2		* RANDOM NUMBER SEED, HIGH WORD
RSEED2  EQU	RSEED1-2	* LOW WORD
RCYCLE  EQU	RSEED2-2	* ZERO MEANS NORMAL, OTHERWISE TOP OF SEQUENCE
RCONST	EQU	RCYCLE-2	* CURRENT PLACE IN SEQUENCE

BUFFER  EQU	RCONST-4	* START OF PRELOADED GAME CODE
ARGBLK  EQU	BUFFER-18	* 8 ARGS MAX FOR EZIP, PLUS COUNT
DEFBLK	EQU	ARGBLK-10	* DEFAULT ARGUMENT BLOCK  (4 ARGS + COUNT)

***

RDWSTR  EQU	DEFBLK-10	* ASCIZ STRING BUFFER (9 CHARS MAX FOR EZIP)
RDZSTR  EQU	RDWSTR-6	* ZSTR BUFFER (3 WORDS MAX FOR EZIP)

RDBOS	EQU	RDZSTR-4	* BEGINNING OF INPUT STRING BUFFER
RDEOS	EQU	RDBOS-4		* END OF INPUT STRING BUFFER (+1)
RDRET	EQU	RDEOS-4		* RETURN TABLE

VWSORT	EQU	RDRET-2		* FLAG: SET IF VOCTAB SORTED
VWBOFF	EQU	VWSORT-2	* INITIAL OFFSET FOR BINARY SEARCH

WRDOFF  EQU	VWBOFF-2	* OFFSET INTO WORD TABLE FOR CURRENT SET

* VIRTUAL I/O DEVICES

VOCONS	EQU	WRDOFF-2	* SET FOR SCREEN OUTPUT
VOPRNT	EQU	VOCONS-2	* SET FOR SCRIPTING
VOSTAT	EQU	VOPRNT-2	* SET FOR STATUS LINE OUTPUT
VOTABL	EQU	VOSTAT-2	* SET FOR TABLE OUTPUT
VOFILE	EQU	VOTABL-2	* SET FOR FILE OUTPUT

VIKEYB	EQU	VOFILE-2	* SET FOR KEYBOARD INPUT
VIFILE	EQU	VIKEYB-2	* SET FOR FILE INPUT

VOBUFF	EQU	VIFILE-2	* SET IF OUTPUT TO SCREEN IS BUFFERED
VIECHO	EQU	VOBUFF-2	* SET IF INPUT IS ECHOED

DQUE	EQU	VIECHO-4	* DISPLAY QUE PARAMETER BLOCK
SQUE	EQU	DQUE-4		* SCRIPT QUE PARAMETER BLOCK

TABOUT  EQU	SQUE-4		* POINTS TO CURRENT TABLE OUTPUT BUFFER (EZIP)
TABPTR  EQU	TABOUT-4	* POINTS TO NEXT TABLE POSITION

CURPAG  EQU	TABPTR-4	* CURRENT PAGE (WHERE ZPC IS) POINTER
CURBLK  EQU	CURPAG-2	* CURRENT BLOCK, USUALLY SAME AS ZPC1
CURTAB  EQU	CURBLK-4	* CURRENT PAGE TABLE POINTER

RTIME	EQU	CURTAB-4	* REFERENCE TIME, NOW USES 2 WORDS
LPAGE	EQU	RTIME-2		* LAST REFERENCED PAGE NUMBER
LPLOC	EQU	LPAGE-4		* AND ITS CORE LOCATION
LPTAB	EQU	LPLOC-4		* AND ITS TABLE POINTER

TDELAY	EQU	LPTAB-2		* DELAY, IN 1/10'S SEC, BETWEEN TIMEOUTS
TFUNC	EQU	TDELAY-2	* FUNCTION TO CALL UPON TIMEOUT
TSNAP	EQU	TFUNC-4		* TIME (ACTUAL) WHICH TRIGGERS NEXT TIMEOUT

SFUNC	EQU	TSNAP-2		* FUNCTION TO CALL UPON SOUND-END
SCOUNT	EQU	SFUNC-2		* #OPS TO WAIT BEFORE NEXT SOUND-END CHECK

***

WIND1	EQU	SCOUNT-2	* NON-ZERO IF IN WINDOW 1
ROW0	EQU	WIND1-2		* WINDOW 0 (SAVED) CURSOR POSITION
COL0	EQU	ROW0-2
ROW1	EQU	COL0-2		* WINDOW 1 (SAVED) CURSOR POSITION
COL1	EQU	ROW1-2

LINES	EQU	COL1-2		* LINES DISPLAYED SINCE LAST INPUT
INLAST  EQU	LINES-2		* INPUT SETS IT, OUTPUT CLEARS IT, QUIT CHECKS
CHRTOT	EQU	INLAST-2	* TOTAL CHARS INPUT SO FAR DURING OPREAD

GAMFIL  EQU	CHRTOT-2	* REF NUMBER OF OPENED GAME FILE
SAVFIL  EQU	GAMFIL-2	* REF NUMBER OF OPENED SAVE FILE

MSAVEB	EQU	SAVFIL-4	* PTR TO A RAM BUFFER FOR ISAVE/IRESTORE
MSAVEF	EQU	MSAVEB-2	* FLAG, SET FOR ISAVE/IRESTORE

***

FONT	EQU	MSAVEF-2	* NONZERO WHEN USING SPECIAL (MONOSPACED) FONT
MACBUF  EQU	FONT-4		* NEW VALUE FOR ENDBUF WHEN FONTSIZE CHANGES

APPARM  EQU	MACBUF-4	* HANDLE TO APPLICATION PARAMETERS
SHOWVE  EQU	APPARM-4	* POINTER TO "VERSION" STRING, ZERO IF NONE

***

DBZPC1  EQU	SHOWVE-2	* HALT WHEN ZPC REACHES THIS ADDRESS
DBZPC2  EQU	DBZPC1-2
DBINST  EQU	DBZPC2-2	* HALT WHEN NEXT INSTRUCTION HAS THIS VALUE

DBTOT1  EQU	DBINST-4	* TOTAL EXECUTION COUNT
DBTOT2  EQU	DBTOT1-4	* DESIRED EXECUTION COUNT

***

ZVLEN	EQU	0-DBTOT2	* TOTAL LENGTH OF ZIP'S VARIABLES FRAME

* ---------------------------------------------------------------------------
*  ZIP DEBUGGING -- INCLUDE FOR DEVELOPMENT ONLY
* ---------------------------------------------------------------------------

* GO UNTIL ONE OF THE FOLLOWING CONDITIONS OCCURS:
*   () ZPC REACHES A GIVEN ADDRESS
*   () ZPC POINTS TO A GIVEN INSTRUCTION
*   () A GIVEN NUMBER OF INSTRUCTIONS ARE EXECUTED

    IFEQ DEBUG

DBTEST  RTS

    ENDC		    * END OF CONDITIONAL ASSEMBLY


	PAGE
* ---------------------------------------------------------------------------
* INITIALIZATIONS
* ---------------------------------------------------------------------------

* LOW-CORE GAME VARIABLES

PVERS1  EQU	0		* ZVERSION VERSION BYTE
PVERS2  EQU	1		* ZVERSION MODE BYTE
PZRKID  EQU	2		* ZORK ID
PENDLD  EQU	4		* ENDLOD (BYTE OFFSET)
PSTART  EQU	6		* START
PVOCTB  EQU	8		* VOCTAB
POBJTB  EQU	10		* OBJTAB
PGLOTB  EQU	12		* GLOTAB
PPURBT  EQU	14		* PURBOT
PFLAGS  EQU	16		* USER FLAGS WORD
PSERNM  EQU	18		* SERIAL NUMBER (6 BYTES)
PWRDTB  EQU	24		* WRDTAB
PLENTH  EQU	26		* LENGTH (EZIP QUADS, ZIP WORDS)
PCHKSM  EQU	28		* CHECKSUM (ALL BYTES STARTING WITH BYTE 64)
PINTWD  EQU	30		* INTERPRETER ID/VERSION
PSCRWD  EQU	32		* SCREEN SIZE, ROWS/COLUMNS

* FOR XZIP:

PHWRD	EQU	2*17		* WIDTH OF DISPLAY, IN PIXEL UNITS
PVWRD	EQU	2*18		* HEIGHT OF DISPLAY, IN PIXEL UNITS
PFWRD	EQU	2*19		* FONT HEIGHT, WIDTH
PLMRG	EQU	2*20		* LEFT MARGIN, IN PIXEL UNITS
PRMRG	EQU	2*21		* RIGHT MARGIN, IN PIXEL UNITS
PCLRWRD	EQU	2*22		* COLOR, BACKGROUND/FOREGROUND
PTCHARS	EQU	2*23		* BYTE PTR, TABLE OF TERMINATING CHARACTERS
PCRCNT	EQU	2*24		* CR COUNTER
PCRFUNC	EQU	2*25		* CR FUNCTION
PCHRSET	EQU	2*26		* BYTE PTR, CHAR SET TABLE
PLCTBL	EQU	2*27		* BYTE PTR, LOW-CORE VARS EXTENSION TABLE 

* LOW CORE EXTENSION TABLE VARIABLES 
*   (WORD OFFSETS -- ACCESS THROUGH 'LOWCORE' ROUTINE)

PLCLEN	EQU	0		* TABLE LENGTH, IN WORDS
PMLOCX	EQU	1		* MOUSE LOCATION WHEN LAST CLICKED
PMLOCY	EQU	2

* "PFLAGS" BIT DEFINITIONS

FSCRI	EQU	0		* INTERPRETER CURRENTLY SCRIPTING
FFIXE	EQU	1		* FIXED-WIDTH FONT NEEDED
FSTAT	EQU	2		* REQUEST FOR STATUS-LINE REFRESH
FDISP	EQU	3		* GAME USES DISPLAY OPS
FUNDO	EQU	4		* GAME USES UNDO
FMOUS	EQU	5		* GAME USES MOUSE
FCOLO	EQU	6		* GAME USES COLOR
FSOUN	EQU	7		* GAME USES (SPECIAL) SOUND
	
* MICRO'S ID CODE, INTERPRETER VERSION LETTER (SEE ALSO OPVERI)

    DATA
INTWRD	DC.B	5	* MACHINE ID FOR ATARI ST
	DC.B	'B'	* XZIP INTERPRETER VERSION
SUBVER	DC.W	0	* INTRPRETER SUB-VERSION, ZERO TO DISABLE
    TEXT

* INITIAL SET OF READ BREAK CHARS -- SPACE, TAB, CR, <.>, <,>, <?>

    DATA
IRBRKS	DC.B	$20,$09,$0D,$2E,$2C,$3F,0	 * ASCIZ
    TEXT

ZMVERS  EQU	5		* XZIP Z-MACHINE VERSION NUMBER
STKLEN  EQU	512*2		* LENGTH OF GAME STACK  (MULTIPLE OF 512)
PAGMIN	EQU	2		* MINIMUM # PAGES (NEEDED BY $VER)

* ----------------------
* _ZSTART
* ----------------------

	XDEF	_ZSTART

_ZSTART	LINK	A6,#-ZVLEN	* CREATE A FRAME FOR ZIP VARIABLES
	MOVE.L  A6,A0		* TOP OF FRAME

	MOVE.W  #ZVLEN/2,D0
STRX1	CLR.W	-(A0)		* ALL INITIAL VALUES ARE ZERO
	SUBQ.W  #1,D0
	BNE	STRX1

	MOVE.L  SP,TOPSP(A6)	* SAVE THE SP FOR RESTARTS
	LEA	ZVARS,A0
	MOVE.L  A6,(A0)		* COPY A6 FOR EXTERNAL CALLS INTO ZIP ROUTINES

*** careful about error msgs before screen & buffers are initialized ...

	MOVE.W	#1,VOCONS(A6)	* OUTPUT ERRORS TO SCREEN FOR NOW (NO BUFFER)
	MOVE.W	#1,VIECHO(A6)	* INPUT IS NORMALLY ECHOED

	MOVE.W	#1,WIND1(A6)	* AVOID PUTCHR/SCRIPTING BUG DURING INIT
	BSR	SYSIN1		* OPEN GAME FILE, WINDOW, ETC

*** READ GAME BLOCK 0 INTO A TEMP STACK BUFFER  ...

	SUBA.W  #512,SP		* CREATE THE BUFFER
	MOVE.L  SP,A4		* SAVE POINTER HERE FOR NOW

	MOVE.L  A4,A0
	CLR.W	D0		* BLOCK 0
	BSR	GETBLK		* GET IT

*** CHECK FOR ID CODE ...

	CMPI.B  #ZMVERS,(A4)	* PROPER Z-MACHINE VERSION?
	BEQ.S	STRX3		* YES

	CLR.W	D0		* SOMETHING WRONG, DIE
	LEA	MSGZMV,A0
	BRA	FATAL		* 'Wrong Z-machine'
    DATA
MSGZMV	DC.B	'Wrong Z-machine version',0
    TEXT

STRX3	MOVE.W  PZRKID(A4),ZORKID(A6)  * UNIQUE GAME ID, CHECKED BY "RESTORE"

	MOVEQ	#0,D0
	MOVE.W  PPURBT(A4),D0	* GET PURBOT BYTE POINTER
	BSR	BYTBLK		* ROUND UP TO NEXT BLOCK BOUNDARY
	MOVE.W  D0,PURBOT(A6)	* AND SAVE IT

* Allocate an "undo" buffer, if requested.  This allocation (now) comes
* BEFORE the preload/paging allocations.  It should really get skipped if
* it would leave either () not enough memory for preload, or () a critically
* low (defined in some heuristic way) amount for paging.

	MOVE.W	PFLAGS(A4),D0
	BTST	#FUNDO,D0	* DOES THIS GAME USE UNDO?
	BEQ.S	STRX3C		* NO

	MOVE.W	PURBOT(A6),D0	* BLOCKS
	ADDQ.L	#STKLEN/512,D0
	BSR	BLKBYT		* TOTAL BYTES NEEDED FOR A SAVE
	BSR	GETM		* GET IT, WITHOUT ERROR TRAPPING
	BEQ.S	STRX3C		* ZERO MEANS NOT ENOUGH MEM

	CLR.W	(A0)		* OK, MARK THE BUFFER AS EMPTY
	MOVE.L	A0,MSAVEB(A6)	* AND STORE PTR

*** allocate a buffer for sampled sound, if requested

STRX3C	MOVE.W	PFLAGS(A4),D0
	BTST	#FSOUN,D0	* DOES THIS GAME USE (SPECIAL) SOUND?
	BEQ.S	STRX4		* NO
	BSR	INITSND		* yes

*** CHECK MEMORY, SET ENDLOD & PAGTOT, DO PRELOAD

STRX4	BSR	MEMAVAIL	* DETERMINE HOW MUCH FREE MEMORY EXISTS
	MOVE.L  D0,D7		* REMEMBER THE AMOUNT

	MOVEQ	#0,D0
	MOVE.W  PLENTH(A4),D0	* LENGTH OF GAME FILE (WORDS OR QUADS)
	ADD.L	D0,D0
    IFEQ EZIP
	ADD.L	D0,D0		* BYTES
    ENDC

    IFEQ DEBUG
	MOVE.L	D0,D1		
	BSR	BYTBLK		* TOTAL BLOCKS IN GAME FILE
	MOVE.W	D0,MAXLOD(A6)	* SAVE FOR DEBUGGING
	MOVE.L	D1,D0
    ENDC

	CMP.L	D7,D0		* ENOUGH ROOM TO PRELOAD ENTIRE GAME?
	BLT.S	LOAD1		* YES

	MOVEQ	#0,D0
	MOVE.W  PENDLD(A4),D0	* LENGTH OF PRELOAD SEGMENT (BYTES)
	CMP.L	D7,D0		* ENOUGH ROOM FOR IT?
	BLT.S	LOAD2		* YES

	BRA	MEMERR		* NO, FAIL

* WE HAVE MEGA-MEMORY, PRELOAD EVERYTHING ...

LOAD1	BSR	BYTBLK		* LENGTH OF GAME FILE (IN BLOCKS)
	MOVE.W  D0,ENDLOD(A6)	* MAXIMIZE THE PRELOAD

	MOVE.W  #PAGMIN,PAGTOT(A6)  * MINIMIZE THE PAGING SPACE (FOR $VER)
	MOVE.W	#1,MAXFLG(A6)	* SET FLAG
	BRA.S	LOAD3

* WE HAVE LIMITED MEMORY, PRELOAD ONLY WHAT'S NEEDED

LOAD2	SUB.L	D0,D7		* FIRST DETERMINE MEMORY LEFT AFTER PRELOAD
	BSR	BYTBLK
	MOVE.W  D0,ENDLOD(A6)	* LENGTH OF PRELOAD (IN BLOCKS)

	DIVU	#512+8,D7	* PAGES AVAIL (ALLOW 8 BYTES PER TABLE ENTRY)
	CMPI.W  #2,D7
	BGE.S	LOADX1
	MOVEQ	#2,D7		* MUST HAVE AT LEAST TWO (FOR $VERIFY)
LOADX1	MOVE.W  D7,PAGTOT(A6)	* MAXIMIZE THE PAGING SPACE

LOAD3	MOVE.W  ENDLOD(A6),D0	* SPACE NEEDED FOR PRELOAD, IN BLOCKS
	BSR	BLKBYT		* CONVERT TO BYTES
	BSR	GETMEM		* GET IT

	MOVE.L  A0,BUFFER(A6)	* SAVE POINTER
	MOVE.L  A0,A4		* ALSO HERE FOR REMAINING INIT

	MOVE.W  ENDLOD(A6),D1	* NUMBER OF BLOCKS TO PRELOAD
	CLR.W	D0		* STARTING WITH BLOCK 0
	BSR	GTBLKS		* READ THEM IN

	CLR.W	WIND1(A6)	* RESTORE NORMAL VALUE

* ------------------------------------------------------------------------

*** INITIALIZE MAJOR TABLE POINTERS

STRX6	MOVEQ	#0,D0
	MOVE.W  PVOCTB(A4),D0	* RELATIVE VOCAB TABLE POINTER
	ADD.L	A4,D0		* ABSOLUTIZE IT
	MOVE.L  D0,VOCTAB(A6)	* AND SAVE IT

	MOVEQ	#0,D0
	MOVE.W  POBJTB(A4),D0	* RELATIVE OBJECT TABLE POINTER
	ADD.L	A4,D0
	MOVE.L  D0,OBJTAB(A6)

	MOVEQ	#0,D0
	MOVE.W  PGLOTB(A4),D0	* RELATIVE GLOBAL TABLE POINTER
	ADD.L	A4,D0
	MOVE.L  D0,GLOTAB(A6)

	MOVEQ	#0,D0
	MOVE.W  PWRDTB(A4),D0	* RELATIVE WORD TABLE POINTER
	ADD.L	A4,D0
	MOVE.L  D0,WRDTAB(A6)

*** ALLOCATE MEMORY FOR Z STACK

	MOVE.L  #STKLEN,D0
	BSR	GETMEM
	MOVE.L  A0,STKBOT(A6)	* THIS WILL BE BOTTOM OF GAME STACK

*** INITIALIZE LINE BUFFER, SCRIPT BUFFER

SCRLEN  EQU	80		* LENGTH OF SCRIPT BUFFER (FIXED FOR NOW)
MAXLEN  EQU	256		* MAX LENGTH OF LINE BUFFER

* ***	MOVE.W	#MAXLEN,D1	* ALLOW FOR A RE-SIZEABLE WINDOW
	MOVE.W	_columns,D1	* SIZE OF ATARI SCREEN DISPLAY (40 OR 80)
	MOVE.W	D1,D2
	LEA	LINOUT,A1	* SCREEN DISPLAY FUNCTION
	LEA	CHSIZ,A2

	BSR	INITQP		* SET UP DISPLAY QUEUE STUFF
	MOVE.L	A0,DQUE(A6)	* SAVE BLOCK POINTER

	MOVE.W	#SCRLEN,D1	* SCRIPTING SIZE, NEVER CHANGES
	MOVE.W	D1,D2
	LEA	SCROUT,A1	* SCRIPTING DISPLAY FUNCTION
	LEA	CHSIZ,A2

	BSR	INITQP		* SET UP SCRIPT QUEUE STUFF
	MOVE.L	A0,SQUE(A6)	* SAVE THIS POINTER TOO

* AND SET UP MACBUF ...

* ALLOCATE AND SET UP BREAK-CHAR TABLE

	MOVE.L	#64,D0		* MAX BREAK CHARS
	BSR	GETMEM		* ALLOCATE BUFFER FOR BREAK-CHAR TABLE
	MOVE.L	A0,RBRKS(A6)

	MOVE.L	VOCTAB(A6),A1	* (DEFAULT) VOCAB TABLE
	CLR.W	D0
	MOVE.B	(A1)+,D0	* FIRST BYTE OF VOCTAB IS # OF SI BREAK CHARS
	BRA.S	STRX11		* (ZERO CHECK)

STRX10	MOVE.B	(A1)+,(A0)+	* TRANSFER SI BREAKS FIRST
STRX11	DBF	D0,STRX10
	MOVE.L	A0,ESIBKS(A6)	* REMEMBER END OF SI BREAKS

	LEA	IRBRKS,A2	* THESE ARE THE "NORMAL" BREAK CHARS
STRX12	MOVE.B	(A2)+,(A0)+	* TRANSFER THEM TOO
	BNE	STRX12		* ASCIZ

*** ALLOCATE MEMORY FOR PAGE TABLE & BUFFERS

	MOVE.W  PAGTOT(A6),D0	* PREVIOUSLY CALCULATED NUMBER OF PAGE BUFFERS
	MULU	#8,D0		* 8-BYTE TABLE ENTRY FOR EACH PAGE
	ADDQ.L  #2,D0		* ALLOW FOR THE END MARK
	BSR	GETMEM
	MOVE.L  A0,PAGTAB(A6)	* THIS WILL BE START OF PAGE TABLE

	MOVE.W  PAGTOT(A6),D0	* PREVIOUSLY CALCULATED NUMBER OF PAGE BUFFERS
	MULU	#512,D0		* 512 BYTES EACH
	BSR	GETMEM
	MOVE.L  A0,PAGES(A6)	* PAGES THEMSELVES WILL START HERE

*** INITIALIZE THE PAGE TABLE

	MOVE.W  PAGTOT(A6),D0	* PREVIOUSLY CALCULATED NUMBER OF PAGE BUFFERS
	MOVE.L  PAGTAB(A6),A0

STRX16  MOVE.W  #-2,(A0)+	* BLOCK (NO BLOCK "$FFFE")
	CLR.L	(A0)+		* REF TIME IS ZERO
	CLR.W	(A0)+		* THIS SLOT UNUSED (BUT 8 BYTES SPEEDS CALCS)
	SUBQ.W  #1,D0
	BNE	STRX16
	MOVE.W  #-1,(A0)	* MARK THE END OF THE TABLE (NO BLOCK "$FFFF")

	MOVE.W  #-1,CURBLK(A6)  * MUST INIT THESE PAGING VARS TOO!
	MOVE.W  #-1,LPAGE(A6)

* ETCETERA ...

	BSR	GTSEED		* INITIALIZE THE RANDOM NUMBER SEEDS
	MOVE.W  D0,RSEED1(A6)
	SWAP	D0
	MOVE.W  D0,RSEED2(A6)	* PUT HIGH WORD HERE (RELATIVELY CONSTANT)

	MOVE.W	#1,VOBUFF(A6)	* BEGIN BUFFERING OUTPUT

	JSR	_end_title	* PAUSE/ERASE TITLE SCREEN, IF SHOWN
	BRA.S	START1

* ----------------------
* RESTRT
* ----------------------

* RESTART EXECUTION HERE

RESTRT	MOVE.L  BUFFER(A6),A0
	MOVE.W  PFLAGS(A0),-(SP)  * PRESERVE THE USER FLAGS (SCRIPT ETC)

	CLR.W	D0		* REREAD ALL OF THE IMPURE STUFF
	MOVE.W  PURBOT(A6),D1
	BSR	GTBLKS

	MOVE.L  BUFFER(A6),A0
	MOVE.W  (SP)+,PFLAGS(A0)  * RESTORE FLAGS

START1	MOVE.L  TOPSP(A6),SP	* RESET SYSTEM STACK POINTER

	MOVE.L	DQUE(A6),A0
	MOVE.L	BUFPTR(A0),NXTPTR(A0)	* INITIALIZE OUTPUT BUFFER POINTER

	MOVE.L  STKBOT(A6),A4
	ADDA.W  #STKLEN,A4	* INITIALIZE GAME STACK POINTER
	MOVE.L  A4,ZLOCS(A6)	* INITIALIZE POINTER TO LOCALS/FRAME
	MOVE.L  BUFFER(A6),A2

    IFEQ EZIP
***	ORI.B	#2,PVERS2(A2)	* NO DISPLAY
	ORI.B	#32+16+8+4,PVERS2(A2)	* SOUND, MONOSPACE, ITALIC, BOLD
	TST.W	_mono
	BNE.S	STR1X2
	ORI.B	#1,PVERS2(A2)	* COLOR IS AVAILABLE

STR1X2	CLR.L	-(SP)
	CLR.L	-(SP)
	JSR	_op_color	* GET MACHINE DEFAULTS, BACK + FORE
	ADDQ.L	#8,SP
	MOVE.W	D0,PCLRWRD(A2)

	MOVE.W  INTWRD,PINTWD(A2) * SET INTERPRETER ID/VERSION WORD
	CLR.W	RCYCLE(A6)	  * ALWAYS RESTART WITH NORMAL RANDOMNESS

	MOVE.W	#$0101,PFWRD(A2)  * ST XZIP: 1 CHAR UNIT = 1 PIXEL
	MOVE.W	_rows,D0
	MOVE.W	_columns,D1
	MOVE.W	D0,PVWRD(A2)	* ST XZIP: 1 CHAR UNIT = 1 PIXEL
	MOVE.W	D1,PHWRD(A2)

	ASL.W	#8,D0		* ROWS IN HIGH BYTE, COLUMNS IN LOW
	MOVE.B	D1,D0
	MOVE.W	D0,PSCRWD(A2)	* SET SCREEN-PARAMETERS WORD

	CLR.W	_split_row
	BSR	EZERR		* CHECK OBJTAB ALIGNMENT
    ENDC
    IFEQ CZIP
	BSET	#5,PVERS2(A2)	* SPLIT-SCREEN IS AVAILABLE
	MOVE.W	#1,_split_row	* ALLOW FOR STATUS LINE
    ENDC

	MOVE.W  PSTART(A2),D0	* GET STARTING LOCATION
	BSR	BSPLTB		* SPLIT BLOCK AND BYTE POINTERS

	MOVE.W  D0,ZPC1(A6)	* INITIALIZE THE ZPC
	MOVE.W  D1,ZPC2(A6)
	BSR	NEWZPC		* GET THE PAGE TO EXECUTE

	BSR	SYSIN2		* MAC -- BUT LOAD A SAVED GAME IF REQUESTED
	BRA	NXTINS		* TALLY HO

    IFEQ EZIP

* ----------------------
* EZERR
* ----------------------

* MAKE SURE OBJ TABLE IS WORD ALIGNED FOR EZIP

EZERR	MOVE.L	BUFFER(A6),A0
	MOVE.W	POBJTB(A0),D0	* OBJECT TABLE BASE
	BTST	#0,D0		* WORD ALIGNED?
	BNE.S	EZERX1		* NO, FAIL
	RTS

EZERX1	CLR.W	D0
	LEA	MSGEZR,A0
	BRA	FATAL		* 'OBJTAB alignment error'

    DATA
MSGEZR	DC.B	'OBJTAB alignment error',0
    TEXT

    ENDC

	PAGE
* ---------------------------------------------------------------------------
* MISC FUNCTIONS
* ---------------------------------------------------------------------------

* ------------------------------
* COPYB
* ------------------------------

* COPY BYTES
* GIVEN A0 -> SRC, D0 = LEN, A1 -> DEST

CPBX1	MOVE.B	(A0)+,(A1)+	* COPY THEM
COPYB	DBF	D0,CPBX1	* ZERO CHECK  << ENTRY POINT >>
	RTS

* ------------------------------
* COPYS
* ------------------------------

* COPY A STRING, AND TACK ON A NULL BYTE
* GIVEN A0 -> SRC, A1 -> DEST, D0 = LEN, D1 = MAX LEN

COPYS	CMP.W	D1,D0		* LEN WITHIN MAX?
	BLE.S	CPSX1
	MOVE.W	D1,D0		* NO, TRUNCATE IT
CPSX1	BRA.S	CPSX3		* ZERO CHECK

CPSX2	MOVE.B	(A0)+,(A1)+
CPSX3	DBF	D0,CPSX2
	CLR.B	(A1)		* ASCIZ
	RTS

* --------------------------
* COMPS
* --------------------------

* COMPARE STRINGS, PTRS IN A0 AND A1, LENGTHS IN D0.W
* RETURN FLAGS, 'EQ' IF SAME

COMPS	TST.W	D0
	BLE.S	CMPSX4		* ZERO CHECK
CMPSX2	CMP.B	(A0)+,(A1)+
	BNE.S	CMPSX4		* MISMATCH, RETURN "DIFFERENT"
	SUBQ.W	#1,D0
	BNE.S	CMPSX2		* IF DONE, RETURN "SAME"
CMPSX4	RTS
	

* ------------------------------
* RELABS
* ------------------------------

* CONVERT A RELATIVE (BYTE) PTR (D0.W) TO ABSOLUTE (A0)

RELABS	SWAP	D0
	CLR.W	D0		* ZERO THE HIGH WORD (NO SIGN-EXTENDING)
	SWAP	D0		*   [14 cycles vs 16]
	MOVE.L	BUFFER(A6),A0
	ADDA.L	D0,A0		* ABSOLUTIZE THE LOCATION
	RTS

* ----------------------
* BLKBYT
* ----------------------

* GIVEN A ZIP BLOCK COUNT IN D0.W, RETURN A BYTE COUNT IN D0.L

BLKBYT	EXT.L	D0		* CLEAR HIGH WORD
	SWAP	D0
	LSR.L	#7,D0		* x512
	RTS

* ----------------------
* BYTBLK
* ----------------------

* GIVEN A BYTE COUNT IN D0.L, RETURN A ZIP BLOCK COUNT IN D0.W, ROUNDING UP

BYTBLK  MOVE.W  D0,-(SP)	* SAVE LOW WORD
	LSR.L	#8,D0
	LSR.L	#1,D0		* EXTRACT BLOCK NUMBER

	ANDI.W  #$01FF,(SP)+	* EXACT MULTIPLE OF 512?
	BEQ.S	BYTBX1		* YES
	ADDQ.W  #1,D0		* NO, ROUND UP TO NEXT BLOCK
BYTBX1	RTS

* ----------------------
* LOWCORE
* ----------------------

* USE THIS ROUTINE TO ACCESS LOW-CORE EXTENSION-TABLE VARS

* GIVEN D0 = VAR (WORD OFFSET)
* RETURN A0 (MAY BE ODD) -> VAR, AND FLAGS (ZERO IF INVALID VAR)

LOWCORE	MOVEM.L	D1,-(SP)
	MOVE.W	D0,D1
	MOVE.L	BUFFER(A6),A0
	MOVEQ	#0,D0		* GET EXTENSION TABLE OFFSET (MAY BE >32K, ODD)
	MOVE.W	PLCTBL(A0),D0	* EXISTS?
	BEQ.S	LWCX1		* NO, ERROR

	ADDA.L	D0,A0		* TABLE BASE
	BSR	GTAWRD		* TABLE LEN (WORDS)
	CMP.W	D0,D1		* ENOUGH?
	BGT.S	LWCX1		* NO, ERROR

	SUBQ.L	#2,A0
	ADD.W	D1,D1		* BYTE OFFSET
	ADDA.W	D1,A0		* POINT TO DESIRED VAR
	BRA.S	LWCX2		* NONZERO FLAGS

LWCX1	MOVEQ	#0,D0		* ZERO FLAGS
LWCX2	MOVEM.L	(SP)+,D1	* DON'T DISTURB FLAGS
	RTS
 
* ----------------------
* GTAWRD
* ----------------------

* GET CORE WORD, ABSOLUTE POINTER IN A0, RETURN THE WORD IN D0, UPDATE POINTER

GTAWRD
	MOVE.B  (A0)+,D0	* GET HIGH-ORDER BYTE, ADVANCE A0
	ASL.W	#8,D0		* POSITION IT
	MOVE.B  (A0)+,D0	* GET LOW-ORDER BYTE, ADVANCE A0
	RTS

* ----------------------
* PTAWRD
* ----------------------

* UPDATE CORE WORD, ABSOLUTE POINTER IN A0, NEW VALUE IN D0

PTAWRD
	MOVE.B  D0,1(A0)	* STORE LOW-ORDER BYTE
	ASR.W	#8,D0
	MOVE.B  D0,(A0)		* STORE HIGH-ORDER BYTE
	RTS

* ---------------------------------------------------------------------------
* LOW LEVEL ZIP FUNCTIONS
* ---------------------------------------------------------------------------

* ----------------------
* GETBYT
* ----------------------

* GET A BYTE FROM GAME, BLOCK-POINTER IN D0, BYTE-POINTER IN D1, RESULT IN D2
*   UPDATE D0 AND D1 TO REFLECT BYTE GOTTEN

GETBYT  MOVE.W  D0,-(SP)
	CMP.W	ENDLOD(A6),D0	* IS THIS A PRELOADED LOCATION?
	BGE.S	GETBX1		* NO

	BSR	BLKBYT		* YES, RECONSTRUCT POINTER (MAY EXCEED 32K)
	OR.W	D1,D0

	CLR.W	D2		* CLEAR THE UNWANTED HIGH BYTE
	MOVE.L  BUFFER(A6),A0	* ABSOLUTE POINTER
	MOVE.B  0(A0,D0.L),D2	* GET THE DESIRED BYTE
	BRA.S	GETBX2

GETBX1	BSR	GETPAG		* FIND THE PROPER PAGE (POINTER RETURNED IN A0)
	CLR.W	D2		* CLEAR THE UNWANTED HIGH BYTE
	MOVE.B  0(A0,D1.W),D2	* GET THE DESIRED BYTE

GETBX2	MOVE.W  (SP)+,D0
	ADDQ.W  #1,D1		* UPDATE BYTE-POINTER
	CMPI.W  #512,D1		* END OF PAGE?
	BNE.S	GETBX3		* NO, DONE

	CLR.W	D1		* YES, CLEAR BYTE-POINTER
	ADDQ.W  #1,D0		* AND UPDATE BLOCK-POINTER
GETBX3	RTS

* ----------------------
* GETWRD
* ----------------------

* GET A WORD FROM GAME, BLOCK-POINTER IN D0, BYTE-POINTER IN D1, RESULT IN D2

GETWRD  BSR	GETBYT		* GET HIGH-ORDER BYTE
	ASL.W	#8,D2		* POSITION IT
	MOVE.W  D2,-(SP)	* SAVE IT

	BSR	GETBYT		* GET LOW-ORDER BYTE
	OR.W	(SP)+,D2	* OR IN THE OTHER BYTE
	RTS

* ----------------------
* NXTBYT
* ----------------------

* GET THE NEXT BYTE, RETURN IT IN D0

NXTBYT  MOVE.L  CURPAG(A6),A0	* INDEX INTO CURRENT PAGE
	ADDA.W  ZPC2(A6),A0
	CLR.W	D0		* CLEAR HIGH REGISTER AND
	MOVE.B  (A0),D0		* GET THE NEXT BYTE

	ADDQ.W  #1,ZPC2(A6)	* UPDATE PC
	CMPI.W  #512,ZPC2(A6)	* END OF PAGE?
	BLT.S	NXTBX1		* NO

	MOVE.W  D0,-(SP)
	BSR	NEWZPC		* YES, UPDATE PAGE
	MOVE.W  (SP)+,D0
NXTBX1	RTS			* AND RETURN

* ----------------------
* NXTWRD
* ----------------------

* GET THE NEXT WORD, RETURN IT IN D0

NXTWRD  BSR	NXTBYT		* GET HIGH-ORDER BYTE
	ASL.W	#8,D0		* SHIFT TO PROPER POSITION
	MOVE.W  D0,-(SP)	* SAVE IT

	BSR	NXTBYT		* GET LOW-ORDER BYTE
	OR.W   (SP)+,D0		* OR IN THE OTHER BYTE
	RTS

* ----------------------
* GETARG
* ----------------------

* GET AN ARGUMENT GIVEN ITS TYPE IN D0

GETARG  SUBQ.W  #1,D0		* EXAMINE ARGUMENT
	BLT.S	NXTWRD		* 0 MEANT LONG IMMEDIATE
	BEQ.S	NXTBYT		* 1 MEANT SHORT IMMEDIATE

	BSR	NXTBYT		* 2 MEANT VARIABLE, GET THE VAR
	TST.W	D0		* STACK?
	BNE.S	GETV1		* NO, JUST GET THE VAR'S VALUE
	MOVE.W  (A4)+,D0	* YES, POP THE STACK
	RTS

* ----------------------
* GETVAR
* ----------------------

* GET VALUE OF A VARIABLE, VAR IN D0, VALUE RETURNED IN D0

GETVAR  TST.W	D0		* STACK?
	BNE.S	GETV1		* NO
	MOVE.W  (A4),D0		* YES, GET TOP-OF-STACK (DON'T POP)
	RTS

GETV1	CMPI.W  #16,D0		* LOCAL?
	BGE.S	GETVX2		* NO
	MOVE.L  ZLOCS(A6),A0	* YES, POINT TO PROPER STACK ELEMENT
	ADD.W	D0,D0
	SUBA.W  D0,A0		* LOCALS BUILD DOWN
	MOVE.W  (A0),D0		* GET IT
	RTS

GETVX2	SUB.W	#16,D0		* GLOBAL, ADJUST FOR LOCALS
	MOVE.L  GLOTAB(A6),A0	* POINT TO PROPER GLOBAL TABLE ELEMENT
	ADD.W	D0,D0
	ADDA.W  D0,A0
	BRA	GTAWRD		* GET IT AND RETURN

* ----------------------
* PUTVAR
* ----------------------

* UPDATE VALUE OF A VARIABLE, VAR IN D0, NEW VALUE IN D1

PUTVAR  TST.W	D0		* STACK?
	BNE.S	PUTVX1		* NO
	MOVE.W  D1,(A4)		* YES, UPDATE TOP-OF-STACK (DON'T PUSH)
	RTS

PUTVX1	CMPI.W  #16,D0		* LOCAL?
	BGE.S	PUTVX2		* NO
	MOVE.L  ZLOCS(A6),A0	* YES, POINT TO PROPER STACK ELEMENT
	ADD.W	D0,D0
	SUBA.W  D0,A0		* LOCALS BUILD DOWN
	MOVE.W  D1,(A0)		* UPDATE IT
	RTS

PUTVX2	SUB.W	#16,D0		* GLOBAL, ADJUST FOR LOCALS
	MOVE.L  GLOTAB(A6),A0	* POINT TO PROPER GLOBAL TABLE ELEMENT
	ADD.W	D0,D0
	ADDA.W  D0,A0
	MOVE.W  D1,D0
	BRA	PTAWRD		* UPDATE IT AND RETURN

* ----------------------
* PUTVAL, BYTVAL
* ----------------------

* RETURN VAL IN D0 TO LOCATION SPECIFIED BY NEXTBYTE
* DESTROYS D1, BUT IS USUALLY CALLED AT END OF TOP-LEVEL FUNCTION

BYTVAL  ANDI.W  #$00FF,D0	* ENTER HERE TO CLEAR HIGH BYTE
PUTVAL  MOVE.W  D0,D1		* NORMAL ENTRY
	BSR	NXTBYT		* GET VAR TO USE
	TST.W	D0		* STACK?
	BNE.S	PUTVAR		* NO, GO STORE VALUE
	MOVE.W  D1,-(A4)	* YES, PUSH ONTO STACK
	RTS

* ----------------------
* PFALSE, PTRUE
* ----------------------

* PREDICATE HANDLERS TRUE AND FALSE
* DESTROYS REGISTERS, BUT ARE ONLY CALLED FROM END OF TOP-LEVEL FUNCTIONS

PFALSE  CLR.W	D1		* PREDICATE WAS FALSE, CLEAR FLAG
	BRA.S	PTRUE1

PTRUE	MOVEQ	#1,D1		* PREDICATE WAS TRUE, SET FLAG
PTRUE1  BSR	NXTBYT		* GET FIRST (OR ONLY) PREDICATE JUMP BYTE
	BCLR	#7,D0		* NORMAL POLARITY PREDICATE?
	BEQ.S	PTRUX1		* NO, LEAVE FLAG ALONE
	ADDQ.W  #1,D1		* YES, INCREMENT FLAG

PTRUX1	BCLR	#6,D0		* ONE-BYTE JUMP OFFSET?
	BNE.S	PTRUX3		* YES

	ASL.W	#8,D0		* NO, TWO-BYTE, POSITION HIGH-ORDER OFFSET BYTE
	MOVE.W  D0,D2
	BSR	NXTBYT		* GET LOW-ORDER BYTE
	OR.W	D2,D0		* OR IN HIGH-ORDER BITS
	BTST	#13,D0		* IS NUMBER NEGATIVE (14-BIT 2'S COMP NUMBER)?
	BEQ.S	PTRUX3		* NO
	ORI.W	#$C000,D0	* YES, MAKE 16-BIT NUMBER NEGATIVE

PTRUX3	SUBQ.W  #1,D1		* TEST FLAG
	BEQ.S	PTRUX6		* WAS 1, THAT MEANS DO NOTHING
	TST.W	D0		* ZERO JUMP?
	BNE.S	PTRUX4		* NO
	BRA	OPRFAL		* YES, THAT MEANS DO AN RFALSE

PTRUX4	SUBQ.W  #1,D0		* ONE JUMP?
	BNE.S	PTRUX5		* NO
	BRA	OPRTRU		* YES, THAT MEANS DO AN RTRUE

PTRUX5	SUBQ.W  #1,D0		* ADJUST OFFSET
	ADD.W	D0,ZPC2(A6)	* ADD TO PC
	BRA	NEWZPC		* AND UPDATE ZPC STUFF
PTRUX6	RTS

* ----------------------
* BSPLTB
* ----------------------

* SPLIT BYTE-POINTER IN D0.W (16 BIT UNSIGNED)
*     INTO BLOCK NUMBER IN D0 & BYTE OFFSET IN D1

BSPLTB  MOVE.W  D0,D1
	LSR.W	#8,D0		* EXTRACT THE 7 BLOCK BITS (64K RANGE)
	LSR.W	#1,D0
	ANDI.W  #$01FF,D1	* EXTRACT THE 9 OFFSET BITS (0-511)
    IFEQ DEBUG
	CMP.W	MAXLOD(A6),D0	* VALID BLOCK NUMBER?
	BCC	BLKERR	* BHS	* NO, FAIL
    ENDC
	RTS

* ----------------------
* BSPLIT
* ----------------------

* SPLIT WORD-POINTER IN D0.W (16 BIT UNSIGNED)
*     INTO BLOCK NUMBER IN D0 & BYTE OFFSET IN D1

BSPLIT  MOVE.W  D0,D1
	LSR.W	#8,D0		* EXTRACT THE 8 BLOCK BITS (128K RANGE)
	ANDI.W  #$00FF,D1	* EXTRACT THE 8 OFFSET BITS (0-255)
	ADD.W	D1,D1		* CONVERT OFFSET TO BYTES
    IFEQ DEBUG
	CMP.W	MAXLOD(A6),D0	* VALID BLOCK NUMBER?
	BCC	BLKERR	* BHS	* NO, FAIL
    ENDC
	RTS

* ----------------------
* BSPLTQ
* ----------------------

* SPLIT QUAD-POINTER IN D0.W (16 BIT UNSIGNED)
*     INTO BLOCK NUMBER IN D0 & BYTE OFFSET IN D1 -- EZIP ONLY

BSPLTQ  MOVE.W  D0,D1
	LSR.W	#7,D0		* EXTRACT THE 9 BLOCK BITS (256K RANGE)
	ANDI.W  #$007F,D1	* EXTRACT THE 7 OFFSET BITS (0-127)
	ADD.W	D1,D1		* CONVERT OFFSET TO BYTES
	ADD.W	D1,D1
    IFEQ DEBUG
	CMP.W	MAXLOD(A6),D0	* VALID BLOCK NUMBER?
	BCC	BLKERR	* BHS	* NO, FAIL
    ENDC
	RTS

* ----------------------
* BLKERR
* ----------------------

    IFEQ DEBUG
BLKERR	LEA	MSGBLK,A0
	BRA	FATAL		* 'Block range error'

    DATA
MSGBLK	DC.B	'Block range error',0
    TEXT

    ENDC

