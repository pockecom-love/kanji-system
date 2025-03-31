; �|�P�R�� PC-1350�p�V���{���e�[�u��
; (C) �������񁗂���

; =================================================================
; PC-1350 ����ROM���[�`��
; =================================================================
INKEY		equ   $0436	; A = �L�[�R�[�h
DSPON		equ   $04B1	; �\��ON
DSPOFF		equ   $04AD	; �\��OFF
OUTC		equ   $04B3	; A��OUTC
TOX		equ   $0282	; X = BA
TOY		equ   $027D	; Y = BA
TOXP		equ   $0287	; X = BA + 1
TOYP		equ   $028D	; Y = BA + 1
TOXM 		equ   $0297	; X = BA - 1
TOYM		equ   $02B5	; Y = BA - 1
XTOY		equ   $1414	; Y = X
YTOX		equ   $1419	; X = Y
PUSHX		equ   $115C	; PUSH X
POPX		equ   $1167	; POP X
BLOCK		equ   $1175	; [(++Y) = (++X)]B
PRINT1		equ   $1DB0	; [(++Y) = (--X)]5 1�����\��
XTOCD		equ   $1553	; (C,D) = X
YTOCD		equ   $1558	; (C,D) = Y
CDTOX		equ   $161A	; X = (C,D)
XTO1C		equ   $1200	; (1C,1D) = X
NCTOX		equ   $1899	; X = (1C,1D)
XTO38		equ   $141E	; (38,39) = X
R38TOX		equ   $140B	; X = (38,39)
DTOH		equ   $163A	; (18,19) = RA
INPTOX		equ   $0293	; X = 6EB0 - 1 (���͕�����o�b�t�@)
INPTOY		equ   $02B1	; Y = 6EB0 - 1 (���͕�����o�b�t�@)
DSPTOX		equ   $02A3	; X = 6D00 - 1 (�e�L�X�g�o�b�t�@)
DSPTOY		equ   $02AA	; Y = &D00 - 1 (�e�L�X�g�o�b�t�@)
CULC		equ   $0AB8	; ���]��
Check		equ   $1410	; ������`�F�b�N
CLRSCR		equ   $1E0C	; �e�L�X�g�o�b�t�@�N���A
PRINT		equ   $1DDF	; �e�L�X�g�o�b�t�@�\��
T6WAIT		equ   $09E8	; 8mm�b�҂�

; =================================================================
; ���[�N�G���A
; =================================================================
STR_BUF		equ   $6E60	; ������o�b�t�@(6E60-6EAF)
DSP_BUF		equ   $6D00	; �e�L�X�gVRAM(6D00-6D5F)
CSRX		equ   $788B	; CURSOR X���W(0-24)
CSRY		equ   $788C	; CURSOR Y���W(0-3)
VRAM		equ   $7000	; VRAM�A�h���X
FONT_ADR	equ   $808A	; �L�����N�^�t�H���g�A�h���X
INDICATOR_ADR   equ   $783C     ; MODE�C���W�P�[�^

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
Key_SPC		equ   $0D
Key_CLS		equ   $0E
Key_MODE	equ   $09
Key_ENTER	equ   $11
Key_RIGHT	equ   $3B
Key_LEFT	equ   $3C
Key_DOWN	equ   $3D
Key_UP		equ   $3E
Key_BREAK	equ   $3F
Key_SHIFT       equ   $15

; =================================================================
; ���̑�
; =================================================================
SWITCH_CHK      equ   $04F2     ; ���m�F
