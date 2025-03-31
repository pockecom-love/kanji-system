; ポケコン PC-1350用シンボルテーブル
; (C) けいくん＠ちた

; =================================================================
; PC-1350 内部ROMルーチン
; =================================================================
INKEY		equ   $0436	; A = キーコード
DSPON		equ   $04B1	; 表示ON
DSPOFF		equ   $04AD	; 表示OFF
OUTC		equ   $04B3	; A→OUTC
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
PRINT1		equ   $1DB0	; [(++Y) = (--X)]5 1文字表示
XTOCD		equ   $1553	; (C,D) = X
YTOCD		equ   $1558	; (C,D) = Y
CDTOX		equ   $161A	; X = (C,D)
XTO1C		equ   $1200	; (1C,1D) = X
NCTOX		equ   $1899	; X = (1C,1D)
XTO38		equ   $141E	; (38,39) = X
R38TOX		equ   $140B	; X = (38,39)
DTOH		equ   $163A	; (18,19) = RA
INPTOX		equ   $0293	; X = 6EB0 - 1 (入力文字列バッファ)
INPTOY		equ   $02B1	; Y = 6EB0 - 1 (入力文字列バッファ)
DSPTOX		equ   $02A3	; X = 6D00 - 1 (テキストバッファ)
DSPTOY		equ   $02AA	; Y = &D00 - 1 (テキストバッファ)
CULC		equ   $0AB8	; 式評価
Check		equ   $1410	; 文字列チェック
CLRSCR		equ   $1E0C	; テキストバッファクリア
PRINT		equ   $1DDF	; テキストバッファ表示
T6WAIT		equ   $09E8	; 8mm秒待ち

; =================================================================
; ワークエリア
; =================================================================
STR_BUF		equ   $6E60	; 文字列バッファ(6E60-6EAF)
DSP_BUF		equ   $6D00	; テキストVRAM(6D00-6D5F)
CSRX		equ   $788B	; CURSOR X座標(0-24)
CSRY		equ   $788C	; CURSOR Y座標(0-3)
VRAM		equ   $7000	; VRAMアドレス
FONT_ADR	equ   $808A	; キャラクタフォントアドレス
INDICATOR_ADR   equ   $783C     ; MODEインジケータ

; =================================================================
; SC61860レジスタ
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
; INKEYコード
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
; その他
; =================================================================
SWITCH_CHK      equ   $04F2     ; 未確認
