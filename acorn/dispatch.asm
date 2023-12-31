	PAGE
	SBTTL "--- OPCODE DISPATCH TABLES ---"

	; 0-OPS

OPT0:	DW	ZRTRUE		; 0
	DW	ZRFALS		; 1
	DW	ZPRI		; 2
	DW	ZPRR		; 3
	DW	ZNOOP		; 4
	DW	ZSAVE		; 5
	DW	ZREST		; 6
	DW	ZSTART		; 7
	DW	ZRSTAK		; 8
	DW	POPVAL		; 9
	DW	ZQUIT		; 10
	DW	ZCRLF		; 11
	DW	ZUSL		; 12
	DW	ZVER		; 13

NOPS0	EQU	14		; NUMBER OF 0-OPS

	; 1-OPS

OPT1:	DW	ZZERO		; 0
	DW	ZNEXT		; 1
	DW	ZFIRST		; 2
	DW	ZLOC		; 3
	DW	ZPTSIZ		; 4
	DW	ZINC		; 5
	DW	ZDEC		; 6
	DW	ZPRB		; 7
	DW	BADOP1		; 8 (UNDEFINED)
	DW	ZREMOV		; 9
	DW	ZPRD		; 10
	DW	ZRET		; 11
	DW	ZJUMP		; 12
	DW	ZPRINT		; 13
	DW	ZVALUE		; 14
	DW	ZBCOM		; 15

NOPS1	EQU	16		; NUMBER OF 1-OPS

	; 2-OPS

OPT2:	DW	BADOP2		; 0 (UNDEFINED)
	DW	ZEQUAL		; 1
	DW	ZLESS		; 2
	DW	ZGRTR		; 3
	DW	ZDLESS		; 4
	DW	ZIGRTR		; 5
	DW	ZIN		; 6
	DW	ZBTST		; 7
	DW	ZBOR		; 8
	DW	ZBAND		; 9
	DW	ZFSETP		; 10
	DW	ZFSET		; 11
	DW	ZFCLR		; 12
	DW	ZSET		; 13
	DW	ZMOVE		; 14
	DW	ZGET		; 15
	DW	ZGETB		; 16
	DW	ZGETP		; 17
	DW	ZGETPT		; 18
	DW	ZNEXTP		; 19
	DW	ZADD		; 20
	DW	ZSUB		; 21
	DW	ZMUL		; 22
	DW	ZDIV		; 23
	DW	ZMOD		; 24

NOPS2	EQU	25		; NUMBER OF 2-OPS

	; X-OPS

OPTX:	DW	ZCALL		; 0
	DW	ZPUT		; 1
	DW	ZPUTB		; 2
	DW	ZPUTP		; 3
	DW	ZREAD		; 4
	DW	ZPRC		; 5
	DW	ZPRN		; 6
	DW	ZRAND		; 7
	DW	ZPUSH		; 8
	DW	ZPOP		; 9
	DW	ZSPLIT		; 10
	DW	ZSCRN		; 11

NOPSX	EQU	12		; NUMBER OF X-OPS

	END

