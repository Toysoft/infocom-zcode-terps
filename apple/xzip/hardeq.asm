	STTL "--- HARDWARE EQUATES: APPLE II ---"
	PAGE	
; -------------------
; APPLE II MEMORY MAP
; -------------------


LBUFF	EQU	$0200		; LINE INPUT BUFFER (80 BYTES)
SCREEN	EQU	$0400		; START OF SCREEN RAM
LSTLNE	EQU	$07D0		; LAST LINE OF SCREEN RAM
BORG	EQU	$0800		; ORIGIN OF BOOT CODE (EZIP)
IOBUFF	EQU	BORG+$200	; PAGENG BUFFER (EZIP)
BUFFA	EQU	IOBUFF+$100	;($100 BYTES) DECODE BUFFER, LOWER HALF
BUFFB	EQU	BUFFA+$100	;($56 BYTES) SECTOR DECODE BUFFER, UPPER HALF
LOCALS	EQU	BUFFB+$80	; LOCAL VARIABLE STORAGE (30 BYTES)
BUFSAV	EQU	LOCALS+$20	; TEMP SPACE FOR SAVE/RESTORE (80 BYTES)

NEXTPNT	EQU	BUFFB+$100	
PREVPNT	EQU	NEXTPNT+$80	
VPAGEH	EQU	PREVPNT+$80	
VPAGEL	EQU	VPAGEH+$80	

ZSTKBL	EQU	VPAGEL+$80	; Z-STACK  BOTTOM,LO  (1K STACK FOR EZIP)
ZSTKTL	EQU	ZSTKBL+$100	; TOP, LO
ZSTKBH	EQU	ZSTKBL+$200	; BOTTOM, HI
ZSTKTH	EQU	ZSTKBL+$300	; TOP, HI

ZBEGIN	EQU	ZSTKBL+$400	; START OF GAME CODE




; ---------
; CONSTANTS
; ---------

XZIPID	EQU	2	; ID BYTE STATING THIS IS AN APPLE XZIP
IIcID	EQU	9	; IIc AND IIe DIFFERENT

AUX	EQU	1	
MAIN	EQU	0	



; THE FIRST 98.5K (SIDE1) MUST
; BE RAM RESIDENT (394=$18A PAGES)
; 98.5K = $18A PAGES (V$0 TO V$189)
;
; PAGES V$13A TO V$189 ARE IN RAMDISK
; PAGES V$0 TO ($BF-VBEGIN) ARE IN MAIN
; PAGES ($C0-VBEGIN) TO V$139 ARE IN AUX
; PAGENG BUFFERS ARE IN AUX FROM
; V$13A-($C0-VBEGIN)+$08 TO $BF



VTOTAL	EQU	256*4	;TOTAL # PAGES IN EZIP
PSIDE2	EQU	35*18	;# PAGES ON SIDE 2 OF DISK
PSIDE1	EQU	VTOTAL-PSIDE2	;# PAGES ON DISK SIDE 1
RMDSIZE	EQU	$4F	; # PAGES RAMDSK CAN HOLD
			; (SECTORS 0-$4E)

AUXSTART EQU	$08	;FIRST RAM PAGE IN AUX MEM
AUXEND	EQU	$BF		;LAST PAGE USABLE IN AUXMEM
MAINSTRT EQU	ZBEGIN/$100	;FIRST FREE PAGE IN MAIN
MAINEND	EQU	$BF		;LAST USABLE PAGE IN MAIN
VAUX	EQU	MAINEND-MAINSTRT+1	;FIRST V-PAGE IN AUXMEM
VRAMDSK	EQU	PSIDE1-RMDSIZE	;FIRST V-PAGE IN RAMDSK


; PBEGIN IS FIRST RAM PAGING BUFFER IN AUX MEM
; PBEGIN IS FIRST PAGING BUFFER (RAM PAGE IN AUX MEM)

PBEGIN	EQU	VRAMDSK-VAUX+AUXSTART	
NUMBUFS	EQU	AUXEND-PBEGIN+1	;# PAGENG BUFFER (RAM PAGES IN AUX)
;TEMP1	EQU	(VRAMDSK*$100)/$100	
V64PG	EQU	PBEGIN-<VRAMDSK

;ARROW	EQU	$08	; LEFT ARROW (BACKSPACE)
BARROW	EQU	$83	; LEFT ARROW AS RETURNED FOR GAME
EOL	EQU	$0D	; EOL CHAR
LF	EQU	$0A	; LINE FEED
SPACE	EQU	$20	; SPACE CHAR
BACKSP	EQU	$7F	; BACKSPACE
FREAD	EQU	$84	; READ BIG FORMAT
READ	EQU	$00	; "READ" COMMAND
WRITE	EQU	$01	; "WRITE" COMMAND
TOP	EQU	1	; NORMAL TOP EXCLUDING STATUS LINE
BOTM	EQU	24	; BOTTOM SCREEN LINE
ZTRKF	EQU	04	; FIRST TRACK GAME IS ON
ZTRKL	EQU	35	; ANYTHING > 35 IS ILLEGAL


; ----------------------
; BOOT ZERO PAGE EQUATES
; ----------------------

BADDR	EQU	$26	; (WORD) ROM BOOT ADDRESS
BSLOT	EQU	$2B	; (BYTE) ROM BOOT SLOT
BSECT	EQU	$3D	; (BYTE) BOOT SECTOR TO READ


; ----------------
; HARDWARE EQUATES
; ----------------

KBD	EQU	$C000	; KEY STROBE
ANYKEY	EQU	$C010	; ANY KEY DOWN FLAG
SPKR	EQU	$C030	; SPEAKER FLAG (MAKE A NOISE)
TXTSET	EQU	$C051	; SWITCH FOR TEXT MODE
MIXCLR	EQU	$C052	; SWITCH FOR MIX MODE CLEAR
LOWSCR	EQU	$C054	; SWITCH FOR PAGE 1 SELECT

ALTZP	EQU	$C008	;WRITE          R/W MAIN (C009 = AUX) >MEM
WRTBNK	EQU	$C004	;WRITE          WRITE MAIN 48K OF MEMORY (+MAIN, +AUX)
RDBNK	EQU	$C002	;WRITE          READ MAIN MEMORY (+MAIN, +AUX)
BNK2SET	EQU	$C083	;READ/READ      READ RAM WRITE RAM BANK 2
BNK1SET	EQU	$C08B	;READ/READ      READ RAM WRITE RAM BANK 1
RDROM	EQU	$C08D	;READ/READ	(X) READ ROM WRITE RAM (>MEM)


; ------------------------
; IDOS INTERFACE VARIABLES
; ------------------------

DCBSLT	EQU	$00		; (BYTE) TARGET SLOT ID
DCBPSL	EQU	DCBSLT+1	; (BYTE) PREVIOUSLY ACCESSED SLOT
DCBDRV	EQU	DCBSLT+2	; (BYTE) TARGET DRIVE ID
DCBPDR	EQU	DCBSLT+3	; (BYTE) PREVIOUSLY ACCESSED DRIVE
DCBSEC	EQU	DCBSLT+4	; (BYTE) TARGET SECTOR
DCBTRK	EQU	DCBSLT+5	; (BYTE) TARGET TRACK
DCBERR	EQU	DCBSLT+6	; (BYTE) DRIVE ERROR CODE
DCBCMD	EQU	DCBSLT+7	; (BYTE) DISK COMMAND ID
DCBBFL	EQU	DCBSLT+8	; (BYTE) LO POINTER TO DATA BUFFER
DCBBFM	EQU	DCBSLT+9	; (BYTE) HI POINTER TO DATA BUFFER
DRVFLG	EQU	DCBSLT+10	; (BYTE) CURRENT DRIVE
SLTMP3	EQU	DCBSLT+11	; (BYTE) TRACK-SEEK SLOT
TTRK	EQU	DCBSLT+12	; (BYTE) TARGET TRACK
DTMP3	EQU	DCBSLT+13	; (BYTE) WORK BYTE
DTMP4	EQU	DCBSLT+14	; (BYTE) SLOT ID * 16
HDRCHK	EQU	DCBSLT+15	; (BYTE) CHECKSUM FOUND
HDRSEC	EQU	DCBSLT+16	; (BYTE) SECTOR FOUND
HDRTRK	EQU	DCBSLT+17	; (BYTE) TRACK FOUND
HDRVOL	EQU	DCBSLT+18	; (BYTE) VOLUME FOUND
DCNT	EQU	DCBSLT+19	; (BYTE) MOTOR TIME COUNT
DTMP2	EQU	DCBSLT+20	; (BYTE) TEMP

; NEXT 4 FOR 18 SECTORS/TRK CODE IN RWTS

HTEMP	EQU	DCBSLT+21	; (BYTE)
TRYS	EQU	DCBSLT+22	; (BYTE)
TEMP	EQU	DCBSLT+23	; (BYTE)
WORD1	EQU	DCBSLT+24	; (WORD)
DTMP6	EQU	DCBSLT+26	; (BYTE)


; ---------------------
; DISK HARDWARE EQUATES
; ---------------------

PH0OFF	EQU	$C080	; STEP MOTOR POSITION #0
DRVOFF	EQU	$C088	; DRIVE MOTOR OFF
DRVON	EQU	$C089	; DRIVE MOTOR ON
DRV0EN	EQU	$C08A	; ENGAGE DRIVE #1
DRV1EN	EQU	$C08B	; ENGAGE DRIVE #2
Q6L	EQU	$C08C	; READ DATA LATCH
Q6H	EQU	$C08D	; WRITE DATA LATCH
Q7L	EQU	$C08E	; SET READ MODE
Q7H	EQU	$C08F	; SET WRITE MODE


; -----------------
; MONITOR VARIABLES
; -----------------

WLEFT	EQU	$20	; LEFT MARGIN (0)
WWDTH	EQU	$21	; RIGHT MARGIN (40 OR 80)
WTOP	EQU	$22	; TOP LINE (0-23)
WBOTM	EQU	$23	; BOTTOM LINE (1-24)
CHZ	EQU	$24	; CURSOR HORIZONTAL
CVT	EQU	$25	; CURSOR VERTICAL
BASL	EQU	$28	; SCREEN LINE
INVFLG	EQU	$32	; CHAR OUTPUT MASK ($FF=NORM, $3F=INVERSE)
PROMPT	EQU	$33	; PROMPT CHARACTER (SET TO <)
CSW	EQU	$36	; CHARACTER OUTPUT VECTOR
RNUM1	EQU	$4E	; RANDOM #'S GENERATED BY
RNUM2	EQU	$4F	; MONITOR GETKEY
EHZ	EQU	$057B	; CURSOR HORIZONTAL (IIE/C)
APKEY1	EQU	$C061	; open apple key flag
APKEY2	EQU	$C062	; closed apple key flag

; ----------------
; MONITOR ROUTINES
; ----------------

MBASCAL	EQU	$FC22	; CALC LINE BASE ADDRESS
MBELL	EQU	$FF3A	; MAKE A NOISE
MCLEOL	EQU	$FC9C	; CLEAR TO END OF LINE
MCLEOS	EQU	$FC42	; CLEAR TO END OF SCREEN
MHOME	EQU	$FC58	; CLEAR SCREEN/HOME CURSOR
MMCOUT	EQU	$FDED	; CHAR OUTPUT
MCOUT1	EQU	$FDF0	; CHAR OUTPUT TO SCREEN
MRDKEY	EQU	$FD0C	; READ KEY
MGETLN1	EQU	$FD6F	; GET LINE
MMWAIT	EQU	$FCA8	; WASTE SO MUCH TIME

	END

