	PAGE
	SBTTL "--- PAGING ROUTINES ---"

	; -------------------------
	; FETCH NEXT BYTE OF Z-CODE
	; -------------------------

	; EXIT: BYTE AT [ZPC] IN [A] & [Y], FLAGS SET

NEXTPC:	LDA	ZPCFLG		; HAS PAGE CHANGED?
	BEQ	NEWZ		; APPARENTLY SO

NPC:	LDY	ZPCL
	LDA	(ZPCPNT),Y	; GRAB A Z-BYTE

	INC	ZPCL
	BNE	NXTX

	LDY	#0
	STY	ZPCFLG

	INC	ZPCM		; POINT [ZPC] TO NEXT PAGE
	BNE	NXTX
	INC	ZPCH

NXTX:	TAY			; SET FLAGS
	RTS

	; --------------
	; SWITCH Z-PAGES
	; --------------

NEWZ:	LDA	ZPCM		; GET LSB OF TARGET INTO [A]
	LDY	ZPCH		; AND MSB INTO [Y]
	BNE	NZ0		; SWAP IF MSB <> 0

	CMP	ZPURE		; IS PAGE IN PRELOAD?
	BCS	NZ0		; NO, SWAP IT IN

	ADC	ZCODE		; ELSE CALC ABSOLUTE PAGE
	BNE	NZ1		; AND GIVE IT TO [ZPCPNT]

NZ0:	LDX	#0
	STX	MPCFLG		; INVALIDATE [MPC]
	JSR	PAGE		; LOCATE PAGE [A/Y] IN SWAPPING SPACE

NZ1:	STA	ZPCPNT+HI	; AND UPDATE MSB OF POINTER
	LDX	#$FF
	STX	ZPCFLG		; VALIDATE [ZPC]
	INX			; (= 0) CLEAR LSB
	STX	ZPCPNT+LO	; OF [ZPCPNT]
	BEQ	NPC		; GET THE BYTE

	; -------------------------------
	; GET NEXT BYTE OF VIRTUAL MEMORY
	; -------------------------------

	; EXIT: BYTE AT [MPC] IN [A] & [Y], FLAGS SET

GETBYT:	LDA	MPCFLG		; [MPC] VALID?
	BEQ	NEWM		; NO, SWITCH PAGES

GTB:	LDY	MPCL		; GRAB NEXT BYTE
	LDA	(MPCPNT),Y

	INC	MPCL		; END OF THIS PAGE?
	BNE	NXMX		; NO, CONTINUE

	LDY	#0		; ELSE INVALIDATE
	STY	MPCFLG		; [MPC]

	INC	MPCM		; POINT [MPC] TO
	BNE	NXMX		; NEXT PAGE
	INC	MPCH

NXMX:	TAY			; SET FLAGS
	RTS

	; --------------
	; SWITCH M-PAGES
	; --------------

NEWM:	LDA	MPCM		; GET LSB AND
	LDY	MPCH		; MSB OF TARGET PAGE
	BNE	NM0		; SWAP IF MSB <> 0

PATCH	EQU	$+1		; PATCH POINT FOR "VERIFY"

	CMP	ZPURE		; TARGET IN PRELOAD?
	BCS	NM0		; NO, SWAP IT IN

	ADC	ZCODE		; ELSE MAKE IT ABSOLUTE
	BNE	NM1		; AND GIVE TO [MPCPNT]

NM0:	LDX	#0
	STX	ZPCFLG		; INVALIDATE [ZPC]
	JSR	PAGE		; GET PAGE OF TARGET BLOCK IN [A/Y]

NM1:	STA	MPCPNT+HI	; SET MSB OF POINTER
	LDX	#$FF
	STX	MPCFLG		; [MPC] IS NOW VALID
	INX			; CLEAR LSB
	STX	MPCPNT+LO	; OF [MPCPNT]
	BEQ	GTB

	; -------------------------------
	; LOCATE A PAGE OF VIRTUAL MEMORY
	; -------------------------------

	; ENTRY: TARGET PAGE IN [A/Y] (LSB/MSB)
	; EXIT: ABSOLUTE PAGE ADDRESS IN [A]

PAGE:	STA	TARGET+LO	; SAVE THE
	STY	TARGET+HI	; TARGET PAGE FOR REFERENCE

	LDX	#0		; INIT INDEX
	STX	ZPAGE		; KEEP A RUNNING TALLY

PG1:	CMP	PTABL,X		; SEARCH FOR LSB IN [A]
	BEQ	PG3		; IF FOUND, CHECK MSB

PG2:	INC	ZPAGE		; UPDATE TALLY
	INX
	CPX	PMAX		; OUT OF PAGING SPACE?
	BCC	PG1		; NO, KEEP LOOKING
	BCS	SWAP		; ELSE PAGE MUST BE SWAPPED IN

PG3:	TYA			; GET MSB OF TARGET
	CMP	PTABH,X		; MATCHED?
	BEQ	PFOUND		; YES, PAGE IS IN [ZPAGE]
	LDA	TARGET+LO	; ELSE RESTORE LSB OF TARGET
	JMP	PG2		; AND RESUME SEARCH

	; SWAP IN TARGET PAGE IN [TARGET]

SWAP:	LDX	LRU		; SPLICE THE
	LDA	TARGET+LO	; TARGET PAGE
	STA	PTABL,X		; INTO THE PAGING TABLES
	STA	DBLOCK+LO	; AND GIVE IT TO ZDOS

	LDA	TARGET+HI	; SAME FOR MSB
	STA	PTABH,X
	STA	DBLOCK+HI

	TXA
	STA	ZPAGE		; SAVE FOR "PFOUND"
	CLC
	ADC	PAGE0		; MAKE IT ABSOLUTE
	STA	DBUFF+HI	; GIVE PAGE ADDRESS TO ZDOS

	JSR	GETDSK		; GET BLOCK INTO SWAPPING SPACE
	BCS	DSKERR		; ERROR IF CARRY SET

	INC	LRU		; UPDATE PAGE POINTER
	LDA	LRU
	CMP	PMAX		; TOP OF PAGING SPACE?
	BCC	PFOUND		; NO, EXIT
	LDA	#0
	STA	LRU		; ELSE RESET POINTER

PFOUND:	LDA	ZPAGE		; GET SWAPPING PAGE INDEX
	CLC
	ADC	PAGE0		; MAKE IT ABSOLUTE
	RTS			; AND RETURN IT IN [A]

	; *** ERROR #14: DRIVE ACCESS ***

DSKERR:	LDA	#14
	JMP	ZERROR

	; -------------------------
	; POINT [MPC] TO V-ADDR [I]
	; -------------------------

SETWRD:	LDA	I+LO
	STA	MPCL
	LDA	I+HI
	STA	MPCM

	LDA	#0
	STA	MPCH		; ZERO TOP BIT
	STA	MPCFLG		; INVALIDATE [MPC]
	RTS

	; ----------------------------
	; GET Z-WORD AT [MPC] INTO [I]
	; ----------------------------

GETWRD:	JSR	GETBYT
	STA	I+HI
	JSR	GETBYT
	STA	I+LO
	RTS

	END

		