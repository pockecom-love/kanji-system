; �|�P�R�� PC-1360/60K�p�V���{���e�[�u��
; (C) �������񁗂���

; =================================================================
; PC-1360/60K ����ROM���[�`��
; =================================================================
INKEY		equ   $1E9C	; A = �L�[�R�[�h
DSPON		equ   $13C8	; �\��ON
DSPOFF		equ   $13C4	; �\��OFF
OUTC		equ   $13CA	; A��OUTC
TOX		equ   $110D	; X = BA
TOY		equ   $1108	; Y = BA
TOXP		equ   $1112	; X = BA + 1
TOYP		equ   $1118	; Y = BA + 1
TOXM 		equ   $111E	; X = BA - 1
TOYM		equ   $1124	; Y = BA - 1
EXX		equ   $119C	; X <> AB
XTOY		equ   $112A	; Y = X
YTOX		equ   $112F	; X = Y
PUSHX		equ   $1153	; PUSH X
POPX		equ   $115E	; POP X
BLOCK		equ   $1233	; [(++Y) = (++X)]B
XTOCD		equ   $1134	; (C,D) = X
YTOCD		equ   $1139	; (C,D) = Y
XEXCD		equ   $1143	; X <> (C,D)
YEXCD		equ   $113E	; Y <> (C,D)
;CDTOX		equ   $____	; X = (C,D)
;XTO1C		equ   $____	; (1C,1D) = X
;NCTOX		equ   $____	; X = (1C,1D)
XTO38		equ   $1188	; (38,39) = X
R38TOX		equ   $1192	; X = (38,39)
R38EXX		equ   $1197	; X <> (38,39)
R1DTOXM		equ   $11A1	; X = (1D,1E) - 1
R15TOXM		equ   $11A5	; X = (15,16) - 1
DTOH		equ   $091D	; (18,19) = RA   (�����m�F)
DSPTOX		equ   $11C7	; X = FD80 - 1 (�e�L�X�g�o�b�t�@)
DSPTOY		equ   $11CE	; Y = FD80 - 1 (�e�L�X�g�o�b�t�@)
CULC		equ   $0000	; ���]��  (���s���B�_�~�[�l)
Check		equ   $18A3	; ������`�F�b�N
CLRSCR		equ   $14B6	; �e�L�X�g�o�b�t�@�N���A(FD80-FDDF)
CLRTEXT		equ   $14C8	; ���̓o�b�t�@�N���A(FD20-FD7F))
;PRINT		equ   $____	; �e�L�X�g�o�b�t�@�\��
T6WAIT		equ   $13B7	; 6ms�҂�

; =================================================================
; ���[�N�G���A
; =================================================================
STR_BUF		equ   $FC60	; ������o�b�t�@(FC60-FCAF)
INP_BUF		equ   $FD20	; ���̓o�b�t�@(FD20-FD6F)
DSP_BUF		equ   $FD80	; �e�L�X�g�o�b�t�@(FD80-FD6F)
CSRX		equ   $FD09	; CURSOR X���W(0-24)
CSRY		equ   $FD0A	; CURSOR Y���W(0-3)
VRAM		equ   $2800	; VRAM�A�h���X
FONT_ADR	equ   $418B	; �L�����N�^�t�H���g�A�h���X(BANK1)
KEY_TABLE	equ   $4360	; �L�[�e�[�u��(BANK1)
INDICATOR_ADR   equ   $303C     ; MODE�C���W�P�[�^
BANK_SELECT	equ   $3400	; ROM�o���N�I��I/O�|�[�g

; =================================================================
; SC61860���W�X�^
; =================================================================
I_Reg		equ   $00
J_Reg		equ   $01
A_Reg		equ   $02
B_Reg		equ   $03
X_Reg		equ   $04
Y_Reg		equ   $06
K_Reg		equ   $08
L_Reg		equ   $09
M_Reg		equ   $0A
N_Reg		equ   $0B
IA_Port		equ   $5C
IB_Port		equ   $5D
FO_Port		equ   $5E
OUTC_Port	equ   $5F

; =================================================================
; INKEY�R�[�h
; =================================================================
Inkey_SPC	equ   $08
Inkey_CLS	equ   $04
Inkey_INS	equ   $09
Inkey_ENTER	equ   $0D
Inkey_LEFT	equ   $42
Inkey_RIGHT	equ   $43
Inkey_DOWN	equ   $3C
Inkey_UP	equ   $3B
Inkey_SHIFT	equ   $15
Inkey_BREAK	equ   $46
Inkey_MODE	equ   $44

; =================================================================
; BASIC�����R�[�h
; =================================================================
ASC_SPC		equ   $20
ASC_CLS		equ   $02
ASC_MODE	equ   $08
ASC_ENTER	equ   $0D
ASC_RIGHT	equ   $0E
ASC_LEFT	equ   $0F
ASC_DOWN	equ   $05
ASC_UP		equ   $04
ASC_BREAK	equ   $07
ASC_SHIFT	equ   $10
ASC_DEF		equ   $12

; =================================================================
; ���̑�
; =================================================================
WAIT		equ   $13AF	; A*2ms�҂�  6B02390343290637
SWITCH_CHK      equ   $0139     ; ���m�F
