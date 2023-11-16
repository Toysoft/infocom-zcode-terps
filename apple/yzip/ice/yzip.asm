	; --------------------------
	; YZIP
	; Z-CODE INTERPRETER PROGRAM
	; FOR APPLE ][e/][c/][gs
	; --------------------------

	; INFOCOM, INC.
	; 125 CAMBRIDGEPARK DRIVE
	; CAMBRIDGE, MA 02140

	; COMPANY PRIVATE -- NOT FOR DISTRIBUTION

        PAGE    200
DEBUG	EQU	0	; ASSEMBLY FLAG FOR DEBUGGER (1 = YES)

 	; -----------
	; ERROR CODES
	; -----------

	; 00 -- INSUFFICIENT RAM
	; 01 -- ILLEGAL X-OP
	; 02 -- ILLEGAL 0-OP
	; 03 -- ILLEGAL 1-OP
	; 04 -- ILLEGAL 2-OP
	; 05 -- Z-STACK UNDERFLOW
	; 06 -- Z-STACK OVERFLOW
	; 07 -- ILLEGAL PROPERTY LENGTH (GETP)
	; 08 -- DIVISION BY ZERO
	; 09 -- ILLEGAL ARGUMENT COUNT (EQUAL?)
	; 10 -- ILLEGAL PROPERTY ID (PUTP)
	; 11 -- ILLEGAL PROPERTY LENGTH (PUTP)
	; 12 -- DISK ADDRESS OUT OF RANGE
	; 13 -- IMPURE CODE TOO LARGE (BM 1/20/86)
	; 14 -- DRIVE ACCESS
	; 15 -- NOT AN EZIP GAME
	; 16 -- ILLEGAL EXTENDED RANGE X-OP
	; 17 -- BAD VIRTUAL PAGE
	; 18 -- SETPC NOT PRELOADED
	; 19 -- PREVIOUS (SPC/FPC) NOT POSSIBLE
	; 20 -- PICTURE NOT FOUND

	INCLUDE 	"ZIP.EQU"
	INCLUDE		"ZERO.EQU"
	INCLUDE		"PRODOS.EQU"
	INCLUDE 	"APPLE.EQU"
	INCLUDE		"MACROS.ASM"

	INCLUDE		"ZBEGIN.ASM"
	INCLUDE 	"MAIN.ASM"
	INCLUDE 	"SUBS.ASM"
	INCLUDE 	"DISPATCH.ASM"

	INCLUDE		"ZDOS.ASM"
	INCLUDE		"MACHINE.ASM"
	INCLUDE		"IO.ASM"
	INCLUDE		"VERIFY.ASM"
	INCLUDE		"SCREEN.ASM"
	INCLUDE		"TABLES.ASM"
	INCLUDE		"WINDOWS.ASM"
	INCLUDE		"DLINE.ASM"
	INCLUDE		"PIC.ASM"

	INCLUDE 	"OPS012.ASM"
	INCLUDE 	"OPSX.ASM"
	INCLUDE 	"READ.ASM"
	INCLUDE		"ZSAVRES.ASM"

	INCLUDE 	"XPAGING.ASM"
	INCLUDE 	"ZSTRING.ASM"
	INCLUDE 	"OBJECTS.ASM"

	END
