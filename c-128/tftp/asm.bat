ECHO OFF
ECHO THIS BATCH FILE ASSEMBLES TFTP.ASM
ECHO IF NO ERRORS, TFTP.TSK WILL BE CREATED

\6502\2500AD_X\X6502 TFTP -ED
\6502\2500AD_X\LINK -Q -C TFTP -X
basica <b.bat

ECHO ON
