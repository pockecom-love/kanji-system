; PC-1360/60K 内部ROMルーチン

INKEY		equ   $1E9C	; A = キーコード
DSPON		equ   $13C8	; 表示ON
DSPOFF		equ   $13C4	; 表示OFF
OUTC		equ   $13CA	; A→OUTC
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
DTOH		equ   $091D	; (18,19) = RA   (※未確認)
DSPTOX		equ   $11C7	; X = FD80 - 1 (テキストバッファ)
DSPTOY		equ   $11CE	; Y = FD80 - 1 (テキストバッファ)
CULC		equ   $0000	; 式評価  (※不明。ダミー値)
Check		equ   $18A3	; 文字列チェック
CLRSCR		equ   $14B6	; テキストバッファクリア(FD80-FDDF)
;PRINT		equ   $____	; テキストバッファ表示
T6WAIT		equ   $13B7	; 6ms待ち

; ワークエリア

STR_BUF		equ   $FC60	; 文字列バッファ(FC60-FCAF)
DSP_BUF		equ   $FD80	; テキストバッファ
CSRX		equ   $FD09	; CURSOR X座標(0-24)
CSRY		equ   $FD0A	; CURSOR Y座標(0-3)
VRAM		equ   $2800	; VRAMアドレス
FONT_ADR	equ   $418B	; キャラクタフォントアドレス(BANK1)
INDICATOR_ADR   equ   $303C     ; MODEインジケータ
BANK_SELECT	equ   $3400	; ROMバンク選択I/Oポート

; SC61860レジスタ

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

; INKEYコード

Key_SPC		equ   $08
Key_CLS		equ   $04
Key_MODE	equ   $44
Key_ENTER	equ   $0D
Key_RIGHT	equ   $43
Key_LEFT	equ   $42
Key_DOWN	equ   $3C
Key_UP		equ   $3B
Key_BREAK	equ   $46
Key_SHIFT       equ   $15

; その他

WAIT		equ   $13AF	; A*2ms待ち  6B02390343290637
SWITCH_CHK      equ   $0139     ; 未確認
