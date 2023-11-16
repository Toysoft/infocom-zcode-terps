	PAGE	
	STTL "--- READ HANDLER ---"


; ----
; READ
; ----
; READ LINE INTO TABLE [ARG1] ; PARSE INTO TABLE [ARG2]

ZREAD:	;JSR	ZUSL	; UPDATE THE STATUS LINE (NOT IN EZIP)
	LDA	ARG1+HI	; MAKE THE TABLE ADDRESSES
	CLC		; ABSOLUTE
	ADC	ZCODE	
	STA	RDTBL1+HI	; AND PLACE IT HERE TO USE
	LDA	ARG1+LO	
	STA	RDTBL1+LO	; LSBS NEED NOT CHANGE
	LDA	ARG2+HI	
	CLC		
	ADC	ZCODE	
	STA	RDTBL2+HI	
	LDA	ARG2+LO	
	STA	RDTBL2+LO	

	LDY	#0	; GET SIZE OF INPUT BUFFER
	LDA	(RDTBL1),Y	
	CMP	#79	; IF OVER 78, CUT DOWN TO 78
	BCC	LEAVIT	; LEAVE IT AS IT IS, IT IS LESS
	LDA	#78	
LEAVIT:	STA	CHRMAX	; SET COUNTER FOR INPUT
	JSR	INPUT	; READ LINE; RETURN LENGTH IN [A]

	; IF TIMEOUT, [A]=0 SO WILL QUIT W/NO RESULTS

	STA	LINLEN	; SAVE # CHARS IN LINE
	LDA	#0	
	STA	WRDLEN	; INIT # CHARS IN WORD COUNTER
	LDY	#1	; POINT TO "# WORDS READ" SLOT
	STA	(RDTBL2),Y	; AND CLEAR IT ([A] = 0)
	STY	SOURCE	; INIT SOURCE TABLE PNTR ([Y] = 1)
	INY		; = 2
	STY	RESULT	; AND RESULT TABLE POINTER

	; MAIN LOOP STARTS HERE

READL:	LDY	#0	; POINT TO "MAX # WORDS" SLOT
	LDA	(RDTBL2),Y	; AND READ IT
	BEQ	RDERR	; (5/14/85 - FORCE # WORDS TO
	CMP	#60	; BE BETWEEN 1 AND 59
	BCC	RD0	
RDERR:	LDA	#59	
	STA	(RDTBL2),Y	;   Le)
RD0:	INY		; (Y = 1) POINT TO "# WORDS READ" SLOT
	CMP	(RDTBL2),Y	; TOO MANY WORDS?
	BCC	RLEX	; YES, SO LEAVE, IGNORING THE REST

; BCS RL1  ; CHANGED 5.2.85 IN ZIP & EZIP
;  ; *** ERROR #13: PARSER OVERFLOW ***
;
; LDA #13
; JMP ZERROR

RL1:	LDA	LINLEN	
	ORA	WRDLEN	; OUT OF CHARS AND WORDS?
	BNE	RL2	; NOT YET
RLEX:	RTS		; ELSE EXIT
RL2:	LDA	WRDLEN	; GET WORD LENGTH
	CMP	#9	; 9 CHARS DONE? (EZIP)
	BCC	RL3	; NO, KEEP GOING
	JSR	FLUSHW	; ELSE FLUSH REMAINDER OF WORD
RL3:	LDA	WRDLEN	; GET WORD LENGTH AGAIN
	BNE	READL2	; CONTINUE IF NOT FIRST CHAR

	; START A NEW WORD

	LDX	#8	; CLEAR Z-WORD INPUT BUFFER
RLL:	STA	IN,X	; [A] = 0
	DEX		
	BPL	RLL	
	JSR	EFIND	; GET BASE ADDRESS INTO [ENTRY]
	LDA	SOURCE	; STORE THE START POS OF THE WORD
	LDY	#3	; INTO THE "WORD START" SLOT
	STA	(ENTRY),Y	; OF THE RESULT TABLE
	TAY		
	LDA	(RDTBL1),Y	; GET A CHAR FROM SOURCE BUFFER
	JSR	SIB	; IS IT A SELF-INSERTING BREAK?
	BCS	DOSIB	; YES IF CARRY WAS SET
	JSR	NORM	; IS IT A "NORMAL" BREAK?
	BCC	READL2	; NO, CONTINUE
	INC	SOURCE	; ELSE FLUSH THE STRANDED BREAK
	DEC	LINLEN	; UPDATE # CHARS LEFT IN LINE
	JMP	READL	; AND LOOP
READL2:	LDA	LINLEN	; OUT OF CHARS YET?
	BEQ	READL3	; LOOKS THAT WAY
	LDY	SOURCE	
	LDA	(RDTBL1),Y	; ELSE GRAB NEXT CHAR
	JSR	BREAK	; IS IT A BREAK?
	BCS	READL3	; YES IF CARRY WAS SET
	LDX	WRDLEN	; ELSE STORE THE CHAR
	STA	IN,X	; INTO THE INPUT BUFFER
	DEC	LINLEN	; ONE LESS CHAR IN LINE
	INC	WRDLEN	; ONE MORE IN WORD
	INC	SOURCE	; POINT TO NEXT CHAR IN SOURCE
	JMP	READL	; AND LOOP BACK
DOSIB:	STA	IN	; PUT THE BREAK INTO 1ST WORD SLOT
	DEC	LINLEN	; ONE LESS CHAR IN LINE
	INC	WRDLEN	; ONE MORE IN WORD BUFFER
	INC	SOURCE	; POINT TO NEXT SOURCE CHAR
READL3:	LDA	WRDLEN	; ANY CHARS IN WORD YET?
	BEQ	READL	; APPARENTLY NOT, SO LOOP BACK
	JSR	EFIND	; GET ENTRY ADDR INTO [ENTRY]
	LDA	WRDLEN	; GET ACTUAL LNGTH OF WORD
	LDY	#2	; STORE IT IN "WORD LENGTH" SLOT
	STA	(ENTRY),Y	; OF THE CURRENT ENTRY
	JSR	CONZST	; CONVERT DB	II IN [IN] TO Z-STRING
	JSR	FINDW	; AND LOOK IT UP IN VOCABULARY
	LDY	#1	
	LDA	(RDTBL2),Y	; FETCH THE # WORDS READ
	CLC		
	ADC	#1	; INCREMENT IT
	STA	(RDTBL2),Y	; AND UPDATE
	JSR	EFIND	; MAKE [ENTRY] POINT TO ENTRY
	LDY	#0	
	STY	WRDLEN	; CLEAR # CHARS IN WORD
	LDA	VALUE+HI	; GET MSB OF VOCAB ENTRY ADDRESS
	STA	(ENTRY),Y	; AND STORE IN 1ST SLOT OF ENTRY
	INY		
	LDA	VALUE+LO	; ALSO STORE LSB IN 2ND SLOT
	STA	(ENTRY),Y	
	LDA	RESULT	; UPDATE THE
	CLC		; RESULT TABLE POINTER
	ADC	#4	; SO IT POINTS TO THE
	STA	RESULT	; NEXT ENTRY
	JMP	READL	; AND LOOP BACK


; -----------------------------------
; FIND BASE ADDR OF RESULT ENTRY SLOT
; -----------------------------------

EFIND:	LDA	RDTBL2+LO	; LSB OF RESULT TABLE BASE
	CLC		
	ADC	RESULT	; AND CURRENT POINTER
	STA	ENTRY+LO	; SAVE IN [ENTRY]
	LDA	RDTBL2+HI	; ALSO ADD MSB
	ADC	#0	
	STA	ENTRY+HI	
	RTS		


; ----------
; FLUSH WORD
; ----------

FLUSHW:	LDA	LINLEN	; ANY CHARS LEFT IN LINE?
	BEQ	FLEX	; NO, SCRAM
	LDY	SOURCE	; GET CURRENT CHAR POINTER
	LDA	(RDTBL1),Y	; AND GRAB A CHAR
	JSR	BREAK	; IS IT A BREAK?
	BCS	FLEX	; EXIT IF SO
	DEC	LINLEN	; ELSE UPDATE CHAR COUNT
	INC	WRDLEN	; AND WORD-CHAR COUNT
	INC	SOURCE	; AND CHAR POINTER
	BNE	FLUSHW	; AND LOOP BACK (ALWAYS)
FLEX:	RTS		


; ---------------------------------
; IS CHAR IN [A] ANY TYPE OF BREAK?
; ---------------------------------
; ------------------
; NORMAL BREAK CHARS
; ------------------

BRKTBL:	DB	'!?,.'	; IN ORDER OF
	DB	$0D	; DB	ENDING FREQUENCY
	DB	SPACE	; SPACE CHAR IS TESTED FIRST FOR SPEED
NBRKS	EQU	$-BRKTBL	; # NORMAL BREAKS

BREAK:	JSR	SIB	; CHECK FOR A SIB FIRST
	BCS	FBRK	; EXIT NOW IF MATCHED

	; ELSE FALL THROUGH ...


; --------------------------------
; IS CHAR IN [A] A "NORMAL" BREAK?
; --------------------------------

NORM:	LDX	#NBRKS-1	; NUMBER OF "NORMAL" BREAKS
NBL:	CMP	BRKTBL,X	; MATCHED?
	BEQ	FBRK	; YES, EXIT
	DEX		
	BPL	NBL	; NO, KEEP LOOKING
	CLC		; NO MATCH, CLEAR CARRY
	RTS		; AND RETURN


; ---------------------
; IS CHAR IN [A] A SIB?
; ---------------------

SIB:	STA	IOCHAR	; SAVE TEST CHAR
	LDA	ZBEGIN+ZVOCAB	; GET 1ST BYTE IN VOCAB TABLE
	LDY	ZBEGIN+ZVOCAB+1	
	STA	MPCM	
	STY	MPCL	
	LDA	#0	
	STA	MPCH	
	JSR	VLDMPC	; GET CORRECT PAGE
	JSR	GETBYT	; HAS # SIBS
	STA	J	; USE AS AN INDEX
SBL:	JSR	GETBYT	; GET NEXT SIB
	CMP	IOCHAR	; MATCHED?
	BEQ	FBRK0	; YES, REPORT IT
	DEC	J	
	BNE	SBL	; ELSE KEEP LOOPING
	LDA	IOCHAR	
	CLC		; NO MATCH, SO
	RTS		; EXIT WITH CARRY CLEAR
FBRK0:	LDA	IOCHAR	
FBRK:	SEC		; EXIT WITH CARRY SET
	RTS		; IF MATCHED WITH A BREAK CHAR


; -----------------
; VOCABULARY SEARCH
; -----------------
; ENTRY: 6-BYTE TARGET Z-WORD IN [OUT]
; EXIT: VIRTUAL ENTRY ADDRESS IN [VALUE] IF FOUND ;
; OTHERWISE [VALUE] = 0

VWLEN	EQU	I	
VWCUR	EQU	J+HI	

FINDW:	LDA	ZBEGIN+ZVOCAB	; GET VIRTUAL ADDR OF VOCAB TBL
	LDY	ZBEGIN+ZVOCAB+1	
	STA	MPCM	
	STY	MPCL	
	LDA	#0	
	STA	MPCH	
	JSR	VLDMPC	; SET TO NEW PAGE
	JSR	GETBYT	; GET # SIBS
	CLC		
	ADC	MPCL	; GET ACTUAL BASE ADDR OF VOCAB ENTRIES
	STA	MPCL	
	BCC	FWL0	
	INC	MPCM	
FWL0:	JSR	VLDMPC	; SET TO NEW PAGE
	JSR	GETBYT	; GET # BYTES PER ENTRY (AND MOVE TO NEXT BYTE)
	STA	ESIZE	; SAVE IT HERE
	STA	VWLEN+0	; AND HERE
	LDA	#0	; CLEAR REST OF COUNTER
	STA	VWLEN+1	
	STA	VWLEN+2	

	JSR	GETBYT	;GET # OF ENTRIES IN TBL (MSB)
	STA	NENTS+HI	; AND STUFF IT IN [NENTS]
	JSR	GETBYT	; DON'T FORGET THE LSB!
	STA	NENTS+LO	
	LDA	#0	; FIND SIZE OF VAOCAB TBL
	STA	VOCEND	; TO LOCATE THE END OF IT
	STA	VOCEND+1	
	STA	VOCEND+2	
	LDX	ESIZE	

FWL1:	CLC		
	LDA	VOCEND	; (# OF ENTRIES) * (ENTRY SIZE)
	ADC	NENTS+LO	
	STA	VOCEND	
	LDA	VOCEND+1	
	ADC	NENTS+HI	
	STA	VOCEND+1	
	LDA	VOCEND+2	
	ADC	#0	; PICK UP CARRY
	STA	VOCEND+2	
	DEX		
	BNE	FWL1	

	CLC		
	LDA	VOCEND	; AND ADD LENGTH TO START OF TBL
	ADC	MPCL	; TO GET END OF TBL
	STA	VOCEND	
	LDA	VOCEND+1	
	ADC	MPCM	
	STA	VOCEND+1	
	LDA	VOCEND+2	
	ADC	MPCH	
	STA	VOCEND+2	; TO SAVE FOR TESTING IF PAST END

	LDA	VOCEND		; SUBTRACT [ESIZE] SO THAT
	SEC			; [VOCEND] POINTS TO REAL LAST ENTRY
	SBC	ESIZE
	STA	VOCEND
	LDA	VOCEND+1
	SBC	#0
	STA	VOCEND+1

;	NOP
;	NOP
;	NOP
;	NOP
;	NOP
;	NOP

	; BEGIN THE SEARCH! [MPC] NOW POINTS TO 1ST ENTRY

	LSR	NENTS+HI	; 2 ALIGN # OF ENTRIES
	ROR	NENTS+LO	
FWCALC:	ASL	VWLEN+0	; CALCULATE INITIAL OFFSET FOR SEARCH
	ROL	VWLEN+1	
	ROL	VWLEN+2	
	LSR	NENTS+HI	
	ROR	NENTS+LO	
	BNE	FWCALC	

;	LDA	NENTS+HI
;	BNE	FWCALC		; DOUBLE-CHECK

	CLC		; ADD 1ST OFFSET INTO START OF VOCABULARL
	LDA	MPCL	; WHICH IS CURRENTLY IN MPC
	ADC	VWLEN+0	
	STA	MPCL	
	LDA	MPCM	
	ADC	VWLEN+1	
	STA	MPCM	
	LDA	MPCH	
	ADC	VWLEN+2	
	STA	MPCH	

	SEC		; AVOID FENCE-POST BUG FOR
	LDA	MPCL	; EXACT-POWER-OF-2 TBL (DUNCAN)
	SBC	ESIZE	
	STA	MPCL	
	BCS	FWLOOP	
	LDA	MPCM	
	SEC		
	SBC	#1	
	STA	MPCM	
	BCS	FWLOOP	
	LDA	MPCH	
	SBC	#0	
	STA	MPCH	

FWLOOP:	LSR	VWLEN+2	; SET FOR NEXT OFFSET,
	ROR	VWLEN+1	; WHICH IS HALF THIS ONE
	ROR	VWLEN+0	

	LDA	MPCL	; HOLD START ADDR, MPC WILL BE A MESS
	STA	VWCUR+0	
	LDA	MPCM	
	STA	VWCUR+1	
	LDA	MPCH	
	STA	VWCUR+2	

	JSR	VLDMPC	; SET TO NEW PAGE
	JSR	GETBYT	; GET 1ST BYTE OF ENTRY

	CMP	OUT	; MATCH 1ST BYTE OF TARGET?
	BCC	WNEXT	; LESS
	BNE	FWPREV	; GREATER
	JSR	GETBYT	
	CMP	OUT+1	; 2ND BYTE MATCHED?
	BCC	WNEXT	
	BNE	FWPREV	; NOPE
	JSR	GETBYT	
	CMP	OUT+2	; 3RD BYTE?
	BCC	WNEXT	
	BNE	FWPREV	; SORRY ...
	JSR	GETBYT	
	CMP	OUT+3	; 4TH BYTE
	BCC	WNEXT	
	BNE	FWPREV	
	JSR	GETBYT	
	CMP	OUT+4	; 5TH BYTE?
	BCC	WNEXT	
	BNE	FWPREV	; SORRY ...
	JSR	GETBYT	
	CMP	OUT+5	; LAST BYTE?
	BEQ	FWSUCC	; FOUND IT!
	BCS	FWPREV	; ELSE BACK UP ...

WNEXT:	LDA	VWCUR+0	; TO MOVE UP, JUST ADD
	CLC		; OFFSET FROM START OF THIS
	ADC	VWLEN+0	; ENTRY
	STA	MPCL	
	LDA	VWCUR+1	
	ADC	VWLEN+1	

	BCS	WNXT2	; SAVES CODE (?)

	STA	MPCM	

	LDA	#0
	STA	MPCH

;	LDA	VWCUR+2	
;	ADC	VWLEN+2	
;	STA	MPCH	

;	LDA	MPCH	
;	CMP	VOCEND+2	; GONE PAST END?
;	BEQ	WNXT0	; MAYBE
;	BCS	WNXT2	; YES
;	BCC	FWMORE	; NO
WNXT0:	LDA	MPCM	
	CMP	VOCEND+1	
	BEQ	WNXT1	; MAYBE
	BCS	WNXT2	; YES
	BCC	FWMORE	; NO
WNXT1:	LDA	MPCL	
	CMP	VOCEND	
	BCC	FWMORE	; NO
	BEQ	FWMORE	; NO, EQUAL
WNXT2:	LDA	VOCEND	; YES, SO POINT TO END OF TBL
	STA	MPCL	
	LDA	VOCEND+1	
	STA	MPCM	
	LDA	VOCEND+2	
	STA	MPCH	
	JMP	FWMORE	

FWPREV:	LDA	VWCUR+0	; TO MOVE DOWN, JUST SUBTRACT
	SEC		; OFFSET FROM START OF THIS
	SBC	VWLEN+0	; ENTRY
	STA	MPCL	
	LDA	VWCUR+1	
	SBC	VWLEN+1	
	STA	MPCM	
	LDA	VWCUR+2	
	SBC	VWLEN+2	
	STA	MPCH	

FWMORE:	LDA	VWLEN+2		; IF OFFSET HIGH GELOW  1 WORD, CONTINUE
	BNE	FWM1	
	LDA	VWLEN+1	
	BNE	FWM1	
	LDA	VWLEN+0	
	CMP	ESIZE	
	BCC	FWFAIL	
FWM1:	JMP	FWLOOP		; AND TRY AGAIN

FWFAIL:	LDA	#0		; NOT FOUND
	STA	VALUE+LO	
	STA	VALUE+HI	
	RTS			; THEN RETURN WITH [VALUE] = 0

FWSUCC:	LDA	VWCUR+0		; ENTRY MATCHED!  RETRIEVE START OF WORD
	STA	VALUE+LO	
	LDA	VWCUR+1	
	STA	VALUE+HI	; MUST BE 64K LIMIT AS ONLY
	RTS			; WORD VALUE RETURNABLE

	END
