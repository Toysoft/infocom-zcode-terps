	PAGE	
	STTL "--- MACHINE COLDSTART: APPLE II ---"

	; ---------
	; COLDSTART
	; ---------


SIG:	DB	0		; IIc FLAG
STRYSL:	DB	0		; BOOT SLOT
STRYDR:	DB	0		; BOOT DRIVE

	; FINISH LOADING THE ZIP

COLD:
	LDA	BSLOT		; SET UP
	STA	DCBSLT		; CURRENT AND
	STA	DCBPSL		; PREVIOUS SLOT IDS

	LDA	#>MCOUT1	; SET SCREEN OUTPUT (X)
	STA	CSW+HI		; IN CASE OF PR#6
	LDA	#<MCOUT1	; WHICH SETS ALL IN & OUTPUT (X) 
	STA	CSW+LO		; TO PR #6

	LDX	#0
	STX	DCBSEC		; START WITH SECTOR 0
	STX	DBUFF+LO	; CLEAR LSB OF [DBUFF]
	INX			; = 1
	STX	DCBTRK		; START WITH TRACK 1
	STX	DCBDRV		; SET UP CURRENT
	STX	DCBPDR		; AND PREVIOUS DRIVE ID
	LDA	#$DE		; START LOAD AT $DE00 (X)
	STA	DBUFF+HI
	LDA	#34		; LOAD ALL OF (X)
	STA	I+LO		; TRACK 1 AND PART OF 2 (EZIP)

COLD0:	JSR	GETRES		; GO THRU ZDOS
	DEC	I+LO		; DONE LOADING?
	BNE	COLD0		; NO, SO LOOP BACK
	LDA	#$FF		; SET TO NORMAL DISPLAY
	STA	INVFLG

	; DETERMINE SCREEN CONFIGURATION

	JSR	CHKSIZ		; DOWN ON PG 9 AS MUST CHECK BYTES IN ROM
	BCC	COLD1
	BCS	NORAM		; OOPS
COLD1:	LDA	SIG
	BEQ	DO80		; IIC, SKIP CHECK
	JSR	MEMCHK		; CHECK IF 128K OF MEMORY
	BCS	NORAM		; NOPE
DO80:	JSR	CALL80		; INIT 80 COL (PR#3) FROM PAGE 9 (X)


	END
