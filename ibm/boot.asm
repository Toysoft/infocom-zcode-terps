	TITLE	BOOT	BOOTSTRAP LOADER FOR ZORK

ABS	SEGMENT	AT 0H
ABS	ENDS

STK	SEGMENT	PARA STACK
STK	ENDS

DATA	SEGMENT WORD
DATA	ENDS

CODE	SEGMENT	PARA
ASSUME	CS:CODE

START	PROC	FAR
	CLI
	SUB	AX,AX
	MOV	DS,AX
	MOV	BX,78H
	MOV	CX,OFFSET CS:TBL$
	MOV	DX,7C0H		; SIGH
	MOV	SI,[BX]
	MOV	DI,[BX+2]
	MOV	[BX],CX
	MOV	[BX+2],DX

	MOV	AX,CS
	MOV	DS,AX
	MOV	DX,0
	MOV	SS,DX
	MOV	BX,7C00H
	MOV	SP,BX
	STI

	MOV	AX,60H
	MOV	DS,AX
	MOV	ES,AX		; LOAD THE GAME AT SEGMENT 60H
	SUB	AX,AX
	SUB	DX,DX
	INT	13H		; RESET THE DISK SYSTEM
	MOV	DX,3		; WILL NEED THREE PASSES
	SUB	BX,BX		; LOAD TO ES:[BX]
	MOV	CH,1		; START WITH TRACK 1
LOOP$:	PUSH	DX		; GET NUMBER OF PASSES NEEDED TO LOAD
	MOV	CL,1		; TRACK N, SECTOR 0
	PUSH	CX
	SUB	DX,DX		; DRIVE 0, HEAD 0
	MOV	AX,0204H	; READ, 4 SECTORS
	INT	13H
	JC	YUK$
	POP	CX		; GET BACK TRACK,SECTOR
	INC	CH		; NEXT TRACK NEXT TIME
	ADD	BX,1000H	; NEXT BUNCH OF CORE ALSO
	POP	DX
	DEC	DX
	JNZ	LOOP$		; LOOP UNTIL DONE
	SUB	AX,AX
	MOV	DS,AX
	MOV	BX,78H
	MOV	[BX],SI
	MOV	[BX+2],DI
	PUSH	ES		; ES IS WHERE WE LOADED THE GAME
	SUB	AX,AX
	PUSH	AX		; CODE STARTS AT ZERO
	RET			; JUMP TO INTERPRETER
YUK$:	SUB	BX,BX
	MOV	AL,"I"
	MOV	AH,14
	INT	10H
	MOV	AL,"L"
	MOV	AH,14
	INT	10H
	MOV	AL,"L"
	MOV	AH,14
	INT	10H
	HLT
TBL$	DB	11001111B
	DB	2
	DB	37
	DB	3
	DB	4
	DB	02AH
	DB	0FFH
	DB	050H
	DB	0F6H
	DB	25
	DB	4
START	ENDP
CODE	ENDS

	END	START
