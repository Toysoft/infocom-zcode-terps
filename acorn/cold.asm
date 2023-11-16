	PAGE
	SBTTL "--- MACHINE COLDSTART: ACORN ---"

	ORG ZIP

	;COLDSTART

COLD:	LDA #MODE		;SET SCREEN TO MODE 7
	JSR VDU
	LDA #7
	JSR VDU

	LDA #229		;SET ESCAPE KEY TO ASCII CODE ($1B)
	LDX #1
	JSR OSBYTE

	LDA #4			;DISABLE CURSOR EDIT KEYS
	LDX #1
	JSR OSBYTE

	JMP WARM1


	;***************
	;WARMSTART ENTRY
	;***************

SLOAD:	DB "The story is loading ..."	
;	DB  EOL
SLOADL 	EQU $-SLOAD

WARM1:	CLD		;INSURE BINARY
	LDX #$FF	;RESET MACHINE STACK
	TXS
	JSR CLS		;CLEAR SCREEN

	LDA #MVTXC	;ALIGN "STORY LOADING"
	JSR VDU
	LDA #6		;COL 6
	JSR VDU
	LDA #11		;LINE 11
	JSR VDU

	LDX #LOW SLOAD
	LDA #HIGH SLOAD
	LDY #SLOADL
	JSR DLINE	;"THE STORY IS LOADING ..."

	;FALL THROUGH TO ZIP WARMSTART AT WARM2

	END
	