	TITLE	"Apple ][ YZIP (c)Infocom","--- ZIP DATA TABLES ---"
CHADR_H:
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	HIGH C20,HIGH C21,HIGH C22,HIGH C23,HIGH C24,HIGH C25,HIGH C26,HIGH C27
	DB	HIGH C28,HIGH C29,HIGH C2A,HIGH C2B,HIGH C2C,HIGH C2D,HIGH C2E,HIGH C2F
	db	HIGH C30,HIGH C31,HIGH C32,HIGH C33,HIGH C34,HIGH C35,HIGH C36,HIGH C37
	DB	HIGH C38,HIGH C39,HIGH C3A,HIGH C3B,HIGH C3C,HIGH C3D,HIGH C3E,HIGH C3F
	db	HIGH C40,HIGH C41,HIGH C42,HIGH C43,HIGH C44,HIGH C45,HIGH C46,HIGH C47
	DB	HIGH C48,HIGH C49,HIGH C4A,HIGH C4B,HIGH C4C,HIGH C4D,HIGH C4E,HIGH C4F
	db	HIGH C50,HIGH C51,HIGH C52,HIGH C53,HIGH C54,HIGH C55,HIGH C56,HIGH C57
	DB	HIGH C58,HIGH C59,HIGH C5A,HIGH C5B,HIGH C5C,HIGH C5D,HIGH C5E,HIGH C5F
	db	HIGH C60,HIGH C61,HIGH C62,HIGH C63,HIGH C64,HIGH C65,HIGH C66,HIGH C67
	DB	HIGH C68,HIGH C69,HIGH C6A,HIGH C6B,HIGH C6C,HIGH C6D,HIGH C6E,HIGH C6F
	db	HIGH C70,HIGH C71,HIGH C72,HIGH C73,HIGH C74,HIGH C75,HIGH C76,HIGH C77
	DB	HIGH C78,HIGH C79,HIGH C7A,HIGH C7B,HIGH C7C,HIGH C7D,HIGH C7E
CHADR_L:
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	LOW C20,LOW C21,LOW C22,LOW C23,LOW C24,LOW C25,LOW C26,LOW C27
	DB	LOW C28,LOW C29,LOW C2A,LOW C2B,LOW C2C,LOW C2D,LOW C2E,LOW C2F
	db	LOW C30,LOW C31,LOW C32,LOW C33,LOW C34,LOW C35,LOW C36,LOW C37
	DB	LOW C38,LOW C39,LOW C3A,LOW C3B,LOW C3C,LOW C3D,LOW C3E,LOW C3F
	db	LOW C40,LOW C41,LOW C42,LOW C43,LOW C44,LOW C45,LOW C46,LOW C47
	DB	LOW C48,LOW C49,LOW C4A,LOW C4B,LOW C4C,LOW C4D,LOW C4E,LOW C4F
	db	LOW C50,LOW C51,LOW C52,LOW C53,LOW C54,LOW C55,LOW C56,LOW C57
	DB	LOW C58,LOW C59,LOW C5A,LOW C5B,LOW C5C,LOW C5D,LOW C5E,LOW C5F
	db	LOW C60,LOW C61,LOW C62,LOW C63,LOW C64,LOW C65,LOW C66,LOW C67
	DB	LOW C68,LOW C69,LOW C6A,LOW C6B,LOW C6C,LOW C6D,LOW C6E,LOW C6F
	db	LOW C70,LOW C71,LOW C72,LOW C73,LOW C74,LOW C75,LOW C76,LOW C77
	DB	LOW C78,LOW C79,LOW C7A,LOW C7B,LOW C7C,LOW C7D,LOW C7E

CHWID:
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	8,6,10,13,13,14,12,5,7,7,9,10,6,9,5,10
	db	11,7,10,10,13,10,11,9,11,11,5,6,9,9,9,11,16,11,11,11,11
	db	9,9,11,11,5,11,12,9,15,13,11,11,11,11,11,11,11,11
	db	16,11,11,11,9,11,9,11,9,7,11,11,11,11,11,9,11,11,6,9,11,6
	db	15,11,11,11,11,9,10,9,11,11,15,11,11,11,9,6,9,12

CHAR_TABLE	EQU	*
C20	DB	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ;(SPACE)
C21	DB	$78,$78,$78,$78,$78,$00,$78,$00,$00 ;! 5
C22	DB	$73,$80,$73,$80,$73,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ;" 9
C23	DB	$39,$c0,$ff,$f0,$39,$c0,$39,$c0,$ff,$f0,$39,$c0,$00,$00,$00,$00,$00,$00 ;# 12
C24	DB	$06,$00,$7f,$e0,$e6,$00,$7f,$e0,$06,$70,$7f,$e0,$06,$00,$00,$00,$00,$00 ;$ 12
C25	DB	$78,$e0,$cd,$c0,$7b,$80,$07,$00,$0e,$f0,$1d,$98,$38,$f0,$00,$00,$00,$00 ;% 13
C26	DB	$7f,$00,$e3,$80,$e0,$00,$78,$00,$e0,$e0,$e1,$c0,$7f,$80,$00,$00,$00,$00 ;& 11
C27	DB	$70,$70,$70,$00,$00,$00,$00,$00,$00 ;' 4
C28	DB	$1c,$38,$70,$70,$70,$38,$1c,$00,$00 ;( 6
C29	DB	$70,$38,$1c,$1c,$1c,$38,$70,$00,$00 ;) 6
C2A	DB	$db,$3c,$ff,$3c,$db,$00,$00,$00,$00 ;* 8
C2B	DB	$1c,$00,$1c,$00,$ff,$80,$1c,$00,$1c,$00,$00,$00,$00,$00,$00,$00,$00,$00 ;+ 9
C2C	DB	$00,$00,$00,$00,$00,$38,$38,$18,$70 ;, 5
C2D	DB	$00,$00,$00,$ff,$00,$00,$00,$00,$00 ;- 8
C2E	DB	$00,$00,$00,$00,$00,$70,$70,$00,$00 ;. 4
C2F	DB	$03,$80,$07,$00,$0e,$00,$1c,$00,$38,$00,$70,$00,$e0,$00,$00,$00,$00,$00 ;/ 9
C30	DB	$1f,$00,$3b,$80,$71,$c0,$71,$c0,$71,$c0,$3b,$80,$1f,$00,$00,$00,$00,$00 ;0 10
C31	DB	$1c,$7c,$1c,$1c,$1c,$1c,$1c,$00,$00 ;1 6
C32	DB	$3f,$00,$63,$80,$06,$80,$0e,$00,$1c,$00,$70,$00,$7f,$80,$00,$00,$00,$00 ;2 9
C33	DB	$7f,$80,$03,$00,$06,$00,$1f,$00,$03,$80,$63,$80,$3f,$00,$00,$00,$00,$00 ;3 9
C34	DB	$07,$c0,$0f,$c0,$1d,$c0,$39,$c0,$71,$c0,$7f,$f0,$01,$c0,$00,$00,$00,$00 ;4 12
C35	DB	$7f,$80,$78,$00,$78,$00,$7f,$00,$03,$80,$63,$80,$3f,$00,$00,$00,$00,$00 ;5 9
C36	DB	$1f,$80,$38,$00,$70,$00,$7f,$80,$71,$c0,$71,$c0,$3f,$80,$00,$00,$00,$00 ;6 10
C37	DB	$7f,$07,$07,$0e,$1c,$1c,$1c,$00,$00 ;7 8
C38	DB	$3f,$80,$71,$c0,$71,$c0,$3f,$80,$71,$c0,$71,$c0,$3f,$80,$00,$00,$00,$00 ;8 10
C39	DB	$3f,$80,$71,$c0,$71,$c0,$3f,$c0,$01,$c0,$03,$80,$3f,$00,$00,$00,$00,$00 ;9 10
C3A	DB	$00,$00,$70,$70,$00,$70,$70,$00,$00 ;: 4
C3B	DB	$00,$00,$38,$38,$00,$38,$38,$18,$70 ;; 5
C3C	DB	$00,$0e,$38,$e0,$38,$0e,$00,$00,$00 ;LOW  8
C3D	DB	$00,$00,$7f,$00,$7f,$00,$00,$00,$00 ;= 8
C3E	DB	$00,$70,$1c,$07,$1c,$70,$00,$00,$00 ;HIGH  8
C3F	DB	$3f,$80,$71,$c0,$03,$80,$0e,$00,$0e,$00,$00,$00,$0e,$00,$00,$00,$00,$00 ;? 10
C40	DB	$1f,$f8,$e0,$0e,$e3,$e7,$e6,$77,$e6,$77,$e3,$bc,$e0,$00,$1f,$f8,$00,$00 ;@ 16
C41	DB	$3f,$80,$71,$c0,$71,$c0,$7f,$c0,$71,$c0,$71,$c0,$71,$c0,$00,$00,$00,$00 ;A 10
C42	DB	$7f,$80,$71,$c0,$71,$c0,$7f,$00,$71,$c0,$71,$c0,$7f,$80,$00,$00,$00,$00 ;B 10
C43	DB	$3f,$80,$71,$c0,$70,$00,$70,$00,$70,$00,$71,$c0,$3f,$80,$00,$00,$00,$00 ;C 10
C44	DB	$7f,$80,$71,$c0,$71,$c0,$71,$c0,$71,$c0,$71,$c0,$7f,$80,$00,$00,$00,$00 ;D 10
C45	DB	$7f,$70,$70,$7f,$70,$70,$7f,$00,$00 ;E 8
C46	DB	$7f,$70,$70,$7e,$70,$70,$70,$00,$00 ;F 8
C47	DB	$3f,$80,$71,$c0,$70,$00,$73,$c0,$71,$c0,$71,$c0,$3f,$80,$00,$00,$00,$00 ;G 10
C48	DB	$71,$c0,$71,$c0,$71,$c0,$7f,$c0,$71,$c0,$71,$c0,$71,$c0,$00,$00,$00,$00 ;H 10
C49	DB	$70,$70,$70,$70,$70,$70,$70,$00,$00 ;I 4
C4A	DB	$01,$c0,$01,$c0,$01,$c0,$01,$c0,$71,$c0,$71,$c0,$3f,$80,$00,$00,$00,$00 ;J 10
C4B	DB	$70,$e0,$71,$c0,$73,$80,$7f,$00,$73,$80,$71,$c0,$70,$e0,$00,$00,$00,$00 ;K 11
C4C	DB	$70,$70,$70,$70,$70,$70,$7f,$00,$00 ;L 8
C4D	DB	$78,$3c,$7c,$7c,$7e,$fc,$77,$dc,$73,$9c,$70,$1c,$70,$1c,$00,$00,$00,$00 ;M 14
C4E	DB	$78,$70,$7c,$70,$7e,$70,$77,$70,$73,$f0,$71,$f0,$70,$f0,$00,$00,$00,$00 ;N 12
C4F	DB	$3f,$80,$71,$c0,$71,$c0,$71,$c0,$71,$c0,$71,$c0,$3f,$80,$00,$00,$00,$00 ;O 10
C50	DB	$7f,$80,$71,$c0,$71,$c0,$7f,$80,$70,$00,$70,$00,$70,$00,$00,$00,$00,$00 ;P 10
C51	DB	$3f,$80,$71,$c0,$71,$c0,$71,$c0,$71,$c0,$71,$c0,$3f,$00,$03,$c0,$00,$00 ;Q 10
C52	DB	$7f,$80,$71,$c0,$71,$c0,$7f,$00,$71,$c0,$71,$c0,$71,$c0,$00,$00,$00,$00 ;R 10
C53	DB	$3f,$80,$71,$c0,$78,$00,$1f,$00,$03,$c0,$71,$c0,$3f,$80,$00,$00,$00,$00 ;S 10
C54	DB	$7f,$c0,$0e,$00,$0e,$00,$0e,$00,$0e,$00,$0e,$00,$0e,$00,$00,$00,$00,$00 ;T 10
C55	DB	$71,$c0,$71,$c0,$71,$c0,$71,$c0,$71,$c0,$71,$c0,$1f,$00,$00,$00,$00,$00 ;U 10
C56	DB	$71,$c0,$71,$c0,$71,$c0,$71,$c0,$73,$80,$77,$00,$7e,$00,$00,$00,$00,$00 ;V 10
C57	DB	$71,$c7,$71,$c7,$71,$c7,$71,$c7,$71,$c7,$71,$dc,$7f,$f8,$00,$00,$00,$00 ;W 16
C58	DB	$71,$c0,$71,$c0,$71,$c0,$1f,$00,$71,$c0,$71,$c0,$71,$c0,$00,$00,$00,$00 ;X 10
C59	DB	$71,$c0,$71,$c0,$71,$c0,$3f,$80,$0e,$00,$0e,$00,$0e,$00,$00,$00,$00,$00 ;Y 10
C5A	DB	$7f,$c0,$01,$c0,$03,$80,$0e,$00,$38,$00,$70,$00,$7f,$c0,$00,$00,$00,$00 ;Z 10
C5B	DB	$7f,$70,$70,$70,$70,$70,$7f,$00,$00 ;[ 8
C5C	DB	$70,$00,$38,$00,$1c,$00,$0e,$00,$07,$00,$03,$80,$01,$c0,$00,$00,$00,$00 ;\ 10
C5D	DB	$7f,$07,$07,$07,$07,$07,$7f,$00,$00 ;] 8
C5E	DB	$00,$00,$0c,$00,$3f,$00,$e1,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ;^ 10
C5F	DB	$00,$00,$00,$00,$00,$00,$00,$ff,$00 ;_ 8
C60	DB	$70,$38,$1c,$00,$00,$00,$00,$00,$00 ;` 6
C61	DB	$00,$00,$00,$00,$3f,$80,$01,$c0,$3f,$c0,$71,$c0,$3f,$c0,$00,$00,$00,$00 ;a 10
C62	DB	$70,$00,$70,$00,$7f,$80,$71,$c0,$71,$c0,$71,$c0,$7f,$80,$00,$00,$00,$00 ;b 10
C63	DB	$00,$00,$00,$00,$3f,$80,$71,$c0,$70,$00,$71,$c0,$3f,$80,$00,$00,$00,$00 ;c 10
C64	DB	$01,$c0,$01,$c0,$3f,$c0,$71,$c0,$71,$c0,$71,$c0,$3f,$c0,$00,$00,$00,$00 ;d 10
C65	DB	$00,$00,$00,$00,$3f,$80,$79,$c0,$7f,$c0,$70,$00,$3f,$80,$00,$00,$00,$00 ;e 10
C66	DB	$0f,$1c,$7f,$1c,$1c,$1c,$1c,$00,$00 ;f 8
C67	DB	$00,$00,$00,$00,$3f,$c0,$71,$c0,$71,$c0,$71,$c0,$3f,$c0,$01,$c0,$3f,$80 ;g 10
C68	DB	$70,$00,$70,$00,$7f,$80,$71,$c0,$71,$c0,$71,$c0,$71,$c0,$00,$00,$00,$00 ;h 10
C69	DB	$70,$00,$70,$70,$70,$70,$70,$00,$00 ;i 5
C6A	DB	$0e,$00,$0e,$0e,$0e,$0e,$0e,$0e,$7c ;j 8
C6B	DB	$70,$00,$70,$00,$71,$c0,$73,$80,$7f,$00,$73,$80,$71,$c0,$00,$00,$00,$00 ;k 10
C6C	DB	$70,$70,$70,$70,$70,$70,$70,$00,$00 ;l 5
C6D	DB	$00,$00,$00,$00,$7f,$fc,$73,$9c,$73,$9c,$73,$9c,$73,$9c,$00,$00,$00,$00 ;m 14
C6E	DB	$00,$00,$00,$00,$7f,$80,$71,$c0,$71,$c0,$71,$c0,$71,$c0,$00,$00,$00,$00 ;n 10
C6F	DB	$00,$00,$00,$00,$3f,$80,$71,$c0,$71,$c0,$71,$c0,$3f,$80,$00,$00,$00,$00 ;o 10
C70	DB	$00,$00,$00,$00,$7f,$80,$71,$c0,$71,$c0,$71,$c0,$7f,$80,$70,$00,$70,$00 ;p 10
C71	DB	$00,$00,$00,$00,$3f,$80,$71,$c0,$71,$c0,$71,$c0,$3f,$c0,$01,$c0,$01,$c0 ;q 10
C72	DB	$00,$00,$77,$7c,$70,$70,$70,$00,$00 ;r 8
C73	DB	$00,$00,$00,$00,$3f,$00,$70,$00,$1e,$00,$03,$80,$3f,$00,$00,$00,$00,$00 ;s 9
C74	DB	$1c,$1c,$7f,$1c,$1c,$1c,$0f,$00,$00 ;t 8
C75	DB	$00,$00,$00,$00,$71,$c0,$71,$c0,$71,$c0,$71,$c0,$3f,$c0,$00,$00,$00,$00 ;u 10
C76	DB	$00,$00,$00,$00,$71,$c0,$71,$c0,$73,$80,$77,$00,$7e,$00,$00,$00,$00,$00 ;v 10
C77	DB 	$00,$00,$00,$00,$73,$9c,$73,$9c,$73,$9c,$73,$9c,$7f,$f8,$00,$00,$00,$00 ;w 14
C78	DB	$00,$00,$00,$00,$71,$c0,$71,$c0,$1f,$00,$71,$c0,$71,$c0,$00,$00,$00,$00 ;x 10
C79	DB	$00,$00,$00,$00,$71,$c0,$71,$c0,$71,$c0,$71,$c0,$3f,$c0,$01,$c0,$3f,$80 ;y 10
C7A	DB	$00,$00,$00,$00,$7f,$c0,$03,$80,$0e,$00,$38,$00,$7f,$c0,$00,$00,$00,$00 ;z 10
C7B	DB	$1f,$38,$38,$f0,$38,$38,$1f,$00,$00 ;} 8
C7C	DB	$70,$70,$70,$70,$70,$70,$70,$70,$70 ;| 5
C7D	DB	$f8,$1c,$1c,$0f,$1c,$1c,$f8,$00,$00 ;} 8
C7E	DB	$00,$00,$00,$00,$3c,$e0,$e7,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ;~ 11
;
; base addresses for the screen lines
;	
BASEL:
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	DB	$80,$80,$80,$80,$80,$80,$80,$80
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	DB	$80,$80,$80,$80,$80,$80,$80,$80
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	DB	$80,$80,$80,$80,$80,$80,$80,$80
	DB	$00,$00,$00,$00,$00,$00,$00,$00
	DB	$80,$80,$80,$80,$80,$80,$80,$80
	DB	$28,$28,$28,$28,$28,$28,$28,$28
	DB	$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8
	DB	$28,$28,$28,$28,$28,$28,$28,$28
	DB	$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8
	DB	$28,$28,$28,$28,$28,$28,$28,$28
	DB	$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8
	DB	$28,$28,$28,$28,$28,$28,$28,$28
	DB	$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8
	DB	$50,$50,$50,$50,$50,$50,$50,$50
	DB	$D0,$D0,$D0,$D0,$D0,$D0,$D0,$D0
	DB	$50,$50,$50,$50,$50,$50,$50,$50
	DB	$D0,$D0,$D0,$D0,$D0,$D0,$D0,$D0
	DB	$50,$50,$50,$50,$50,$50,$50,$50
	DB	$D0,$D0,$D0,$D0,$D0,$D0,$D0,$D0
	DB	$50,$50,$50,$50,$50,$50,$50,$50
	DB	$D0,$D0,$D0,$D0,$D0,$D0,$D0,$D0
BASEH:
	DB	$20,$24,$28,$2C,$30,$34,$38,$3C
	DB	$20,$24,$28,$2C,$30,$34,$38,$3C
	DB	$21,$25,$29,$2D,$31,$35,$39,$3D
	DB	$21,$25,$29,$2D,$31,$35,$39,$3D
	DB	$22,$26,$2A,$2E,$32,$36,$3A,$3E
	DB	$22,$26,$2A,$2E,$32,$36,$3A,$3E
	DB	$23,$27,$2B,$2F,$33,$37,$3B,$3F
	DB	$23,$27,$2B,$2F,$33,$37,$3B,$3F
	DB	$20,$24,$28,$2C,$30,$34,$38,$3C
	DB	$20,$24,$28,$2C,$30,$34,$38,$3C
	DB	$21,$25,$29,$2D,$31,$35,$39,$3D
	DB	$21,$25,$29,$2D,$31,$35,$39,$3D
	DB	$22,$26,$2A,$2E,$32,$36,$3A,$3E
	DB	$22,$26,$2A,$2E,$32,$36,$3A,$3E
	DB	$23,$27,$2B,$2F,$33,$37,$3B,$3F
	DB	$23,$27,$2B,$2F,$33,$37,$3B,$3F
	DB	$20,$24,$28,$2C,$30,$34,$38,$3C
	DB	$20,$24,$28,$2C,$30,$34,$38,$3C
	DB	$21,$25,$29,$2D,$31,$35,$39,$3D
	DB	$21,$25,$29,$2D,$31,$35,$39,$3D
	DB	$22,$26,$2A,$2E,$32,$36,$3A,$3E
	DB	$22,$26,$2A,$2E,$32,$36,$3A,$3E
	DB	$23,$27,$2B,$2F,$33,$37,$3B,$3F
	DB	$23,$27,$2B,$2F,$33,$37,$3B,$3F
;
; this gives the bit offset for each one
;
XBITTBL:
	DB	0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
	DB	4,1,5,2,6,3,0
OLDZV:
;
; Variables that used to be in the zero page but got moved out
;
PSVFLG	EQU	OLDZV		; (BYTE) PRESERVE FLAG FOR LEX 0=DON'T 1=DO
VOCFLG	EQU	PSVFLG+1	; (BYTE) WHICH VOC TBL, 0=NORMAL 1= ARG3
DBLOCK	EQU	VOCFLG+1	; (WORD) Z-BLOCK TO READ
QUOT	EQU	DBLOCK+2	; (WORD) QUOTIENT FOR DIVISION
REMAIN	EQU	QUOT+2		; (WORD) REMAINDER FOR DIVISION
QSIGN	EQU	REMAIN+2	; (BYTE) SIGN OF QUOTIENT
RSIGN	EQU	QSIGN+1		; (BYTE) SIGN OF REMAINDER
DIGITS	EQU	RSIGN+1		; (BYTE) DIGIT COUNT FOR "PRINTN"
OLDLEN	EQU	DIGITS+1	; (BYTE) OLD LINE LENGTH
OLDEND	EQU	OLDLEN+1	; (BYTE) OLD LAST CHAR IN [LBUFF]
SPSTAT	EQU	OLDEND+1	; (BYTE) SPLIT SCREEN STATUS FLAG
LFROM	EQU	SPSTAT+1	; (WORD) "FROM" LINE ADDRESS
LTO	EQU	LFROM+2		; (WORD) "TO" LINE ADDRESS
PRLEN	EQU	LTO+2		; (BYTE) SCRIPT LINE LENGTH
GPOSIT	EQU	PRLEN+1		; (BYTE) DEFAULT SAVE POSITION
GDRIVE	EQU	GPOSIT+1	; (BYTE) DEFAULT SAVE DRIVE
TPOSIT	EQU	GDRIVE+1	; (BYTE) TEMP SAVE POSITION
TDRIVE	EQU	TPOSIT+1	; (BYTE) TEMP SAVE DRIVE
TSLOT	EQU	TDRIVE+1	; (BYTE) TEMP SAVE SLOT
DRIVE	EQU	TSLOT+1		; (BYTE) CURRENT DRIVE
SIDEFLG	EQU	DRIVE+1		; (BYTE) which disk side are we on
SRHOLD	EQU	SIDEFLG+1	; (WORD) LOW HIGH 0 if doing sequential random
SCRIPTF	EQU	SRHOLD+2	; (BYTE) DIROUT FLAG FOR PRINTER OUTPUT
SCRIPTFLG EQU	SCRIPTF+1	; (BYTE) Does window allow scripting?
OLDZSP	EQU	SCRIPTFLG+1	; (WORD)
CURSFLG	EQU	OLDZSP+2	; (BYTE) 1==New cursor X for DLINE
DBLK	EQU	CURSFLG+1	; (WORD)
RDTBL1	EQU	DBLK+2		; (WORD) READ TABLE 1 (Game Relative)
RDTBL2	EQU	RDTBL1+2	; (WORD) READ TABLE 2
NENTS	EQU	RDTBL2+2	; (WORD) # ENTRIES IN VOCAB TABLE
DIRITM	EQU	NENTS+2		; (WORD) OFFSET IN OUTPUT TBL (DIRTBL)
DIRCNT	EQU	DIRITM+2	; (WORD) COUNT OF CHARS IN TBL (DIRTBL)
SVTCHAR EQU	DIRCNT+2	; (WORD) Old TCHARS table address
VOCMPC	EQU	SVTCHAR+2	; (3 BYTES) Save for vocabulary MPC
VCESVE	EQU	VOCMPC+3	; (3 BYTES) Save for VOCEND
VWLSVE	EQU	VCESVE+3	; (3 BYTES) Save for VOCLEN
DIDVTBL	EQU	VWLSVE+3	; (BYTE) LOW HIGH 0 if we have done default table
IN	EQU	DIDVTBL+1	; (9 BYTES) INPUT BUFFER
OUT	EQU	IN+9		; (9 BYTES) OUTPUT BUFFER
OLDZVLEN EQU 	OUT-PSVFLG+9	; this is how much to reserve

	ds	OLDZVLEN	; and zero it out

; ------------------
; ERROR MESSAGE STRINGS
; ------------------
E27:	db	E27L
	db	"Disk I/O Error"
E27L	EQU	$-E27-1
E2B:	db	E2BL
	db	"Disk write protected"
E2BL	EQU	$-E2B-1
E40:	db	E40L
	db	"Bad Filename"
E40L	EQU	$-E40-1
E44:	db	E44L
	db	"Path not found"
E44L:	EQU	$-E44-1
E45:	db	E45L
	db	"Volume not found"
E45L	EQU	$-E45-1
E46:	db	E46L
	db	"File Not Found"
E46L	EQU	$-E46-1
E48:	db	E48L
	db	"Disk Full"
E48L	EQU	$-E48-1
E49:    db      E49L
        db      "LaneDOS limit: 12 files/directory"
E49L    EQU     $-E49-1
E4E:    db      E4EL
        db      "LaneDOS limit: No writes to TREE files"
E4EL    EQU     $-E4E-1
E4C:	db	E4CL
	db	"Unexpected EOF"
E4CL	EQU	$-E4C-1

ELIST:	db	$27
	dw	E27
	db	$2B
	dw	E2B
	db	$40
	dw	E40
	db	$44
	dw	E44
	db	$45
	dw	E45
	db	$46
	dw	E46
	db	$48
	dw	E48
        db      $49
        dw      E49
	db	$4C
	dw	E4C
        db      $4E
        dw      E4E
ELISTL	EQU	$-ELIST-3	; mark last error code

	END

