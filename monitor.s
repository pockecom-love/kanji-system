; +========================================================+
; |  30桁表示マシン語モニター for PC-1350/60/60K           |
; |                           (C) けいくん＠ちた           |
; |                           (X account @pockecom_love)   |
; |                                                        |
; |  [一次配布サイト]                                      |
; |  https://github.com/pockecom-love/kanji-system         |
; |                                                        |
; |  [License] MIT                                         |
; |                                                        |
; +========================================================+



		; =======================================================
		; 設定
		; =======================================================
TARGET		equ   1350	; PC-1350は 1350、PC-1360/60Kは 1360 を指定



		; =======================================================
		; ラベル定義ファイル
		; =======================================================
		nolist
		if TARGET = 1350
			org   $6600	; オブジェクトロードアドレス
			include(SYMBOL1350.h)
HEX_A			equ   '('
HEX_B			equ   '/'
HEX_C			equ   '*'
HEX_D			equ   '-'
HEX_E			equ   '+'
HEX_F			equ   '.'
		else
			org   $F200
			include(SYMBOL1360.h)
HEX_A			equ   ','
HEX_B			equ   '/'
HEX_C			equ   '*'
HEX_D			equ   '-'
HEX_E			equ   '+'
HEX_F			equ   '.'
		endif
		list



		; =======================================================
		; 30桁表示マシン語モニター for PC-1350
		;
		; ワーク (2E) モード
		;             bit0  1…キャラ表示、0…グラフィック表示
		;             bit1  1…編集モード、0…閲覧モード
		;             bit2  1…カーソルON、0…カーソルOFF
		;        (2F) 編集用ニブル位置(0-15)
		;        (30,31) X座標,Y座標
		;        (32) キーリピートフラグ
		;        (33,34) オートパワーオフタイマー
		;        (35,36) 1行目の表示アドレス(L,H)
		;        (37) チェックサム
		;        (38,39) Xレジスタ退避用
		; =======================================================
MONITOR:	LII   9
		CLRA
		LP    $2E
		FILM			; ワーククリア
		IXL
		CPIA  ','		; カンマでなければ
		JRNZP MON_JMP2		;     アドレス指定省略へ
		POP
		POP
		LIB   4			; 4回ループ
MON_LOOP3:	LII   1
		LP    $36
		SLW			; (35,36)左4ビットシフト
		IXL
		CALL  HEX2BIN
		JRCP  MON_JMP1		; エラー
		LP    $36
		ORMA
		DECB
		JRNZM MON_LOOP3
		LP    $35
		LIQ   $36
		LII   0
		EXW
		JRP   MON_JMP2
MON_JMP1:	LIA   1			;     ERROR 1
		SC
		RTN

MON_JMP2:	CAL   PUSHX		; X保存
		CALL  CLS_START		; 画面クリア
		LP    $32		; キーリピートフラグON
		LIA   1			; 起動時のEnterキーをキャンセルするため
		EXAM

		; ----------------------- 初期4行出力 -----------------------
MON_INIT:	LIA   3
		PUSH
		LP    K_Reg
		LIQ   $35
		MVB			; KL = (35,36)
MON_LOOP1:	CALL  LINE_PRINT	; 1行出力
		LOOP  MON_LOOP1
		CALL  CURSOR_ON		; カーソルON

		; ----------------------- メインループ -----------------------
MON_LOOP2:	CALL  KEY_REPEAT
		CPIA  ASC_CLS		; CLSキーで終了
		JRZP  MON_END
		CPIA  ASC_UP		; ↑キー
		JRZP  MON_UP
		CPIA  ASC_DOWN		; ↓キー
		JRZP  MON_DOWN
		CPIA  ASC_LEFT		; ←キー
		JRZP  MON_LEFT
		CPIA  ASC_RIGHT		; →キー
		JRZP  MON_RIGHT
		CPIA  ASC_ENTER		; ENTERキー
		JRZP  MON_ENTER
		CPIA  ASC_MODE		; MODEキー
		JRZP  MON_MODE
		LP    $2E
		TSIM  $02
		JRZM  MON_LOOP2		; 閲覧モードならループ

		CPIA  HEX_A
		JRNZP MAIN_SKIP1
		LIA   'A'
MAIN_SKIP1:	CPIA  HEX_B
		JRNZP MAIN_SKIP2
		LIA   'B'
MAIN_SKIP2:	CPIA  HEX_C
		JRNZP MAIN_SKIP3
		LIA   'C'
MAIN_SKIP3:	CPIA  HEX_D
		JRNZP MAIN_SKIP4
		LIA   'D'
MAIN_SKIP4:	CPIA  HEX_E
		JRNZP MAIN_SKIP5
		LIA   'E'
MAIN_SKIP5:	CPIA  HEX_F
		JRNZP MAIN_SKIP6
		LIA   'F'

MAIN_SKIP6:	CPIA  '0'		; 1～9,A～Fキー
		JRCM  MON_LOOP2
		CPIA  ':'		; 9の次
		JRCP  MAIN_JMP1
		CPIA  'A'
		JRCM  MON_LOOP2
		CPIA  'G'
		JRCP  MAIN_JMP2
		JRM   MON_LOOP2
MAIN_JMP1:	SBIA  $30
		JRP   INPUT
MAIN_JMP2:	SBIA  $37
		JRP   INPUT

		; --------------------- ENTERキー処理 ---------------------
MON_ENTER:	CALL  CURSOR_OFF	; カーソルOFF
		LP    $2E
		TSIM  $02		; 閲覧モードなら
		JRZP  MON_DOWN		;     ↓キー処理へ
		ANIM  $F9		; 閲覧モードにする
		JRM   MON_LOOP2

		; ----------------------- ↓キー処理 -----------------------
MON_DOWN:	CALL  CURSOR_OFF	; カーソルOFF
		LIB   $00
		LIA   $08
		LP    $35
		ADB			; (35,36) += 8
		LP    K_Reg
		LIQ   $35
		MVB			; KL = (35,36)
		LP    K_Reg
		LIA   $18
		ADB			; KL += 24
		CALL  SCROLL_UP
		CALL  LINE_PRINT	; 1行出力
		CALL  CURSOR_ON		; カーソルON
		JRM   MON_LOOP2

		; ----------------------- ↑キー処理 -----------------------
MON_UP:		CALL  CURSOR_OFF	; カーソルOFF
		LIB   $00
		LIA   $08
		LP    $35
		SBB			; (35,36) -= 8
		LP    K_Reg
		LIQ   $35
		MVB			; KL = (35,36)
		CALL  SCROLL_DOWN
		CALL  LINE_PRINT	; 1行出力
		CALL  CURSOR_ON		; カーソルON
		JRM   MON_LOOP2

		; ----------------------- ←キー処理 -----------------------
MON_LEFT:	LP    $2E
		TSIM  $02
		JRZP  LEFT_JMP1		; 編集モードならば
		CALL  CURSOR_OFF	;     カーソルOFF
		LP    $2F
		SBIM  1			;     編集用ニブル1つ右へ
		JRNCP LEFT_JMP2		;     右端までいったら
		LIA   15
		EXAM			;         (2F) = 15
		JRM   MON_UP		;         ↑キー処理へ
LEFT_JMP1:	ORIM  $02		; 編集モードにする
		LP    $2F
		LIA   15
		EXAM			; (2F) = 15
LEFT_JMP2:	CALL  CURSOR_ON		; カーソルON
		JRM   MON_LOOP2

		; ----------------------- →キー処理 -----------------------
MON_RIGHT:	LP    $2E
		TSIM  $02
		JRZP  RIGHT_JMP1	; 編集モードならば
		CALL  CURSOR_OFF	;     カーソルOFF
		LP    $2F
		ADIM  1			;     編集用ニブル1つ右へ
		CPIM  16
		JRCP  RIGHT_JMP2	;     右端までいったら
		ANIM  0			;         (2F) = 0
		JRM   MON_DOWN		;         ↓キー処理へ
RIGHT_JMP1:	ORIM  $02		; 編集モードにする
		LP    $2F
		ANIM  0			; (2F) = 0
RIGHT_JMP2:	CALL  CURSOR_ON		; カーソルON
		JRM   MON_LOOP2

		; ----------------------- MODEキー処理 -----------------------
MON_MODE:	LP    $2E
		TSIM  $01
		JRZP  MODE_JMP1		; 編集モードならば
		ANIM  $FE		;     MODE = 0
		JRP   MODE_JMP2
MODE_JMP1:	ORIM  $01		;     MODE = 1
MODE_JMP2:	CALL  CSR_CLEAR		; カーソル座標クリア
		JRM   MON_INIT

		; ----------------------- CLSキー処理 -----------------------
MON_END:	CALL  CLS_START		; 画面クリア
		CAL   POPX		; X復帰
		RC
		RTN   			; BASICへ

		; --------------------- 0-9,A-Fキー処理 ---------------------
INPUT:		PUSH
		LIQ   $35
		LP    K_Reg
		MVB			; KL = (35,36)
		LP    $2F
		LDM
		RC
		SR			; A = ニブル位置 / 2
		ADIA  $0F
		LIB   0
		LP    K_Reg
		ADB			; KL = KL + $10
		LP    X_Reg
		LIQ   K_Reg
		MVB
		POP
		LP    $2F
		TSIM  1
		JRNZP INPUT_JMP1
		SWP
		LIDP  INPUT_VALUE1 + 1
		STD
		IX
		ANID  $0F
INPUT_VALUE1:	ORID  $00
		JRP   INPUT_JMP2
INPUT_JMP1:	LIDP  INPUT_VALUE2 + 1
		STD
		IX
		ANID  $F0
INPUT_VALUE2:	ORID  $00
INPUT_JMP2:	LP    $2E
		TSIM  $01
		JRNZP INPUT_JMP3
		CALL  CHECK_SUM		; チェックサム再計算
		CALL  GRAPH_PRINT	; グラフィック再表示
		JRM   MON_RIGHT
INPUT_JMP3:	CALL  CHAR_PRINT	; キャラクタ再表示
		JRM   MON_RIGHT



		; =======================================================
		; 1行出力
		;
		; 入力 KL = 左端のアドレス
		; =======================================================
LINE_PRINT:	LP    $37
		ANIM  0			; チェックサム初期化
		LIA   7
		PUSH
		LP    L_Reg
		LDM
		CALL  BYTE_PRINT	; アドレス上位出力
		LP    K_Reg
		LDM
		CALL  BYTE_PRINT	; アドレス下位出力
		LIA   ' '
		CALL  CHAR		; ' '出力
LPRINT_LOOP1:	CALL  BYTE_READ		; 1バイト読み込み
		LP    $37
		ADM			; チェックサム加算
		CALL  BYTE_PRINT	; 1バイト出力
		LP    $2E
		TSIM  $01		; MODE = 1 なら
		JRNZP LPRINT_JMP1	;     '-'を出力しない
		LDR
		STP
		CPIM  4
		JRNZP LPRINT_JMP1
		LIA   '-'
		CALL  CHAR		; '-'出力
LPRINT_JMP1:	LOOP  LPRINT_LOOP1
		LP    $2E
		TSIM  $01		; MODE = 1 なら
		JRNZP LPRINT_JMP2	;     キャラクタ表示へ

		LIA   ':'
		CALL  CHAR		; ':'出力
		LP    $37
		LDM
		CALL  BYTE_PRINT	; チェックサム出力

		LIA   ' '
		CALL  CHAR		; ' '出力
		LIA   '['
		CALL  CHAR		; '['出力
		LIB   0
		LIA   $08
		LP    K_Reg
		SBB
		LIA   7
		PUSH
LPRINT_LOOP2:	CALL  BYTE_READ
		IYS			; グラフィック出力
		LOOP  LPRINT_LOOP2
		LP    $30
		ADIM  2			; X座標+2
		LIA   ']'
		CALL  CHAR		; ']'出力
		RTN

LPRINT_JMP2:	LIA   '|'
		CALL  CHAR		; '|'出力
		LIB   0
		LIA   $08
		LP    K_Reg
		SBB
		LIA   7
		PUSH
LPRINT_LOOP3:	CALL  BYTE_READ		; 1バイト読み込み
		CALL  CHAR		; キャラクタ表示
		LOOP  LPRINT_LOOP3
		RTN

		; ----------------------- 変換 -----------------------
HEX2BIN:	SBIA  $30
		JRCP  HEX_JMP2
		CPIA  $17
		JRNCP HEX_JMP2
		CPIA  10
		JRCP  HEX_JMP1
		SBIA  7
HEX_JMP1:	RC
		RTN
HEX_JMP2:	SC
		RTN



		; =======================================================
		; チェックサム計算＆出力
		;
		; 3行目のチェックサムを再計算し表示する
		; =======================================================
CHECK_SUM:	LP    $37
		ANIM  0			; チェックサム初期化
		LP    K_Reg
		LIQ   $35
		MVB			; KL = (35,36)
		LIB   0
		LIA   $10
		LP    K_Reg
		ADB			; KL = (35,36) + $10
		LIA   7
		PUSH
CHECK_LOOP1:	CALL  BYTE_READ		; 1バイト読み込み
		LP    $37
		ADM			; チェックサム加算
		LOOP  CHECK_LOOP1
		LP    $30
		LIA   $17
		EXAM			; X座標 = 23
		LP    $37
		LDM
		CALL  BYTE_PRINT	; チェックサム出力
		RTN



		; =======================================================
		; キャラクタ出力
		;
		; 3行目のキャラクタを再表示する
		; =======================================================
CHAR_PRINT:	LP    K_Reg
		LIQ   $35
		MVB			; KL = (35,36)
		LIB   0
		LIA   $10
		LP    K_Reg
		ADB			; KL = (35,36) + $10
		LIA   7
		PUSH
		LP    $30
		LIA   $16
		EXAM			; X座標 = 26
CHARA_LOOP1:	CALL  BYTE_READ		; 1バイト読み込み
		CALL  CHAR		; キャラクタ表示
		LOOP  CHARA_LOOP1
		RTN



		; =======================================================
		; グラフィック出力
		;
		; 3行目のグラフィックを再表示する
		; =======================================================
GRAPH_PRINT:	LP    K_Reg
		LIQ   $35
		MVB			; KL = (35,36)
		LIB   0
		LIA   $10
		LP    K_Reg
		ADB			; KL = (35,36) + $10
		LP    $30
		LIA   $1B
		EXAM			; X座標 = 26
		CALL  VRAM1_ADR
		LIA   7
		PUSH
GRAPH_LOOP1:	CALL  BYTE_READ		; 1バイト読み込み
		IYS
		LOOP  GRAPH_LOOP1
		RTN



		; =======================================================
		; 1バイトデータ読み出し(オートインクリメント)
		;
		; 入力 KL = アドレス(LH)
		; 出力 A = 読み出し値
		; 破壊レジスタ I,A,B,P,Q,DP
		; =======================================================
BYTE_READ:	LII   0
		LIQ   K_Reg
		LP    A_Reg
		MVB			; AB = KL
		LP    A_Reg
		RST			; A = (AB)
		PUSH
		INCK
		LP    L_Reg
		CLRA
		ADCM
		POP
		RTN


		; =======================================================
		; 1バイト16進表示
		;
		; 入力 A = 1バイトデータ
		; 破壊レジスタ A,B,X,Y,P,Q,DP
		; =======================================================
BYTE_PRINT:	PUSH
		SWP
		CALL  BYTE_JMP1		; 上位ニブル
		POP
		CALL  BYTE_JMP1		; 下位ニブル
		RTN

		; --------------------- 1ニブル表示 ---------------------
BYTE_JMP1:	ANIA  $0F
		ORIA  $30		; 0～9文字コードに
		CPIA  $3A
		JRCP  BYTE_JMP2
		ADIA  $07		; A～F文字コードに
BYTE_JMP2:	CALL  CHAR
		RTN



		; =======================================================
		; 半角1文字表示
		;
		; 入力 A = 文字コード
		;      (30) = X座標
		;      (31) = Y座標
		; 破壊レジスタ A,B,X,Y,P,Q,DP
		; =======================================================
CHAR:		CALL  FONTADR_CALC
		CALL  VRAM1_ADR
		IXL			; 1～4ドット出力
		IYS			;  LIB  4
		IXL			;  CAL  BLOCK
		IYS			; をループ展開したもの
		IXL
		IYS
		IXL
		IYS
		CLRA			; 余白
		IYS
		CALL  CURSOR_UPDATE	; カーソル右移動
		RTN



		; =======================================================
		; 半角フォントアドレス計算
		;
		; 入力 A = 文字コード
		; 出力 X = フォントアドレス - 1
		; 破壊レジスタ A,B,P,Q,DP
		; =======================================================
FONTADR_CALC:	CPIA  $E0		; E0以上は
		JRNCP FONT_JMP3		;     0にする
FONT_JMP1:	CPIA  $80
		JRCP  FONT_JMP2
		CPIA  $A0		; A0以下は
		JRCP  FONT_JMP3		;     0にする
		SBIA  $20		; 20減算
FONT_JMP2:	SBIA  $20		; 20減算
		JRNCP FONT_JMP4
FONT_JMP3:	CLRA			; 00-1Fは20にする
FONT_JMP4:	LIB   $00
		LP    A_Reg
		ADB			; BA = BA + BA (2倍)
		LP    A_Reg
		ADB			; BA = BA + BA (4倍)
		CAL   TOX
		LIB   ASCII4_FONT >> 8
		LIA   ASCII4_FONT & $FF	; 4dotキャラクタフォントアドレス
		LP    X_Reg
		ADB			; X = X + BA
		DX
		RTN



		; =======================================================
		; VRAMアドレス算出
		;
		; 入力 (30) = X座標(0-29)
		;      (31) = Y座標(0-3)
		; 出力 Y = VRAMアドレス - 1
		; 破壊レジスタ A,B,Y,P,Q,DP
		; =======================================================
VRAM1_ADR:	LIB   VRAM >> 8
		LP    $30
		LDM
VRAM1_LOOP1:	SBIA  6			; 桁数/5 を引けるだけ引く
		JRCP  VRAM1_JMP1
		LP    B_Reg
		ADIM  $02		; 桁数/5 で割った商の分だけ $200加算
		JRM   VRAM1_LOOP1
VRAM1_JMP1:	ADIA  6			; 引きすぎた分を加算
		PUSH
		LP    Y_Reg
		EXAM
		POP
		RC
		SL
		SL			; 4倍
		ADM			; 1倍 + 4倍
		LDM
		CAL   TOY		; Y = BA
		LP    $31
		LDM			; A = Y座標
		LP    Y_Reg
		TSIA  $01
		JRZP  VRAM1_JMP2	; 偶数なら
		ADIM  $40		; 	$40加算
VRAM1_JMP2:	CPIA  2
		JRCP  VRAM1_JMP3	; 1以上なら
		ADIM  $1E		; 	$1E加算
VRAM1_JMP3:	DY			; Y = Y - 1
		RTN



		; =======================================================
		; 入力待ちキー入力(キーリピート付き)
		;
		; 出力 A = キーコード
		; 破壊レジスタ I,A,P,Q,DP
		; ワーク (32) リピートフラグ
		; =======================================================
KEY_REPEAT:	CALL  INKEY_WAIT
		LP    $32
		TSIM  $01		; リピート判定中(1)ならば
		JRNZP KEY_JMP2		;     リピート判定へ
		TSIM  $FF		; リピートOFF(0)ならば
		JRNZP KEY_JMP1
		ORIM  $01		;    リピート判定中(1)に
KEY_JMP1:				;    ASCIIコードに変換
		if TARGET = 1350
			ADIA  $03	; キーテーブルが $8403～
		else
			ADIA  $60	; キーテーブルが $4360～
		endif
		LIDP  KEY_WRITE + 2
		STD
		if TARGET = 1360
			LIDP  BANK_SELECT
			LDD
			EXAB		; B = 現在のBANK番号
			LIA   0		; BANK1選択
			STD
		endif
KEY_WRITE:	LIDP  KEY_TABLE
		LDD
		if TARGET = 1360
			LP    B_Reg
			LIDP  BANK_SELECT
			MVDM		; BANK復帰
		endif
		RTN			; リピート中(2)ならリターン

					; リピート判定
KEY_JMP2:	CPIA  Inkey_ENTER		; リピート除外キー
		JRZM  KEY_REPEAT
		CPIA  Inkey_MODE		; リピート除外キー
		JRZM  KEY_REPEAT
		CPIA  Inkey_SHIFT
		JRZM  KEY_REPEAT
		LIA   $03
		CAL   OUTC		; カウンタリセット
KEY_LOOP1:	CALL  INKEY_WAIT
		LP    $32
		TSIM  $FF		; リピートOFF(0)ならば
		JRZM  KEY_REPEAT	;     リピート判定中にキーを離した
		TEST  $01
		JRZM  KEY_LOOP1		; 500ms待ち
		ANIM  $00
		ORIM  $02		;     リピート中(2)にする
		JRM   KEY_JMP1



		; =======================================================
		; リアルタイムキー入力
		;
		; 出力 A = キーコード
		; 破壊レジスタ I,A,P,Q,DP
		; ワーク (32) リピートフラグ
		;        (33,34) オートパワーオフタイマー
		; =======================================================
INKEY_WAIT:	CAL   INKEY		; リアルタイムキースキャン
		CAL   T6WAIT		; 6ms待ち
		JRNCP INKEY_JMP1	; キー入力がない場合
		CALL  TIMER_RESET	;     オートパワーオフタイマーリセット
		RTN
					; キー入力ありの場合
INKEY_JMP1:	LP    $32		; キーリピートOFF(0)
		ANIM  $00
		CLRA			; オートパワーオフタイマー + 1
		SC
		LP    $34
		ADCM			; (34) = (34) + 0 + 1
		LP    $33
		ADCM			; (33) = (33) + C
		CPIM  200		; 200*1.5s = 300秒で
		JRNCP POWER_OFF		;     オートパワーオフへ
		LP    $2E
		TSIM  $02		; bit1 = 0
		JRZM  INKEY_WAIT	; 閲覧モードならループ
		TEST  $01
		JRZM  INKEY_WAIT	; 500ms待ち
		LP    $2E
		TSIM  $04
		JRZP  INKEY_JMP2	; カーソルONならば
		CALL  CURSOR_OFF	;     カーソル表示OFF
		RTN
INKEY_JMP2:	CALL  CURSOR_ON		;     カーソル表示ON
		RTN
POWER_OFF:	CALL  TIMER_RESET	; オートパワーオフタイマーリセット
		LIA   $0C
		CAL   OUTC		; パワーオフ(OUTC ← $0C)
		RTN



		; =======================================================
		; カーソルON
		; 入力 (30,31) カーソル座標
		; =======================================================
CURSOR_ON:	LP    $2E
		TSIM  $02
		JRNZP CSRON_JMP1	; 閲覧モードならば
		RTN			;     リターン
CSRON_JMP1:	ORIM  $04		; カーソルONにする
		LP    $31
		LIA   2
		EXAM			; (31) = 2  (Y座標)
		LP    $2F
		LDM
		LP    $30
		EXAM			; (30) = (2F)
		LP    $2E
		TSIM  $01
		JRNZP CSRON_JMP2
		LP    $30
		CPIM  8
		JRCP  CSRON_JMP2
		ADIM  1
CSRON_JMP2:	LP    $30
		ADIM  5			; (30) = (30) + 5
		LIA   $A0
		CALL  CHAR		; ベタ出力
		RTN



		; =======================================================
		; カーソルOFF
		; 入力 (30,31) カーソル座標
		; =======================================================
CURSOR_OFF:	LP    $2E
		TSIM  $02
		JRNZP CSROFF_JMP1	; 閲覧モードならば
		RTN			;     リターン
CSROFF_JMP1:	ANIM  $FB		; カーソルOFFにする
		LP    $31
		LIA   2
		EXAM			; (31) = 2  (Y座標)
		LP    $2F
		LDM
		LP    $30
		EXAM			; (30) = (2F)
		ANIM  $FE		; 上位ニブル位置にする
		LP    $2E
		TSIM  $01
		JRNZP CSROFF_JMP2
		LP    $30
		CPIM  8
		JRCP  CSROFF_JMP2
		ADIM  1
CSROFF_JMP2:	LP    $30
		ADIM  5			; (30) = (30) + 5
		LIQ   $35
		LP    K_Reg
		MVB			; KL = (35,36)
		LP    $2F
		LDM
		RC
		SR			; A = ニブル位置 / 2
		ADIA  $10
		LIB   0
		LP    K_Reg
		ADB			; KL = KL + $10
		CALL  BYTE_READ
		CALL  BYTE_PRINT
		RTN



		; =======================================================
		; オートパワーオフタイマーリセット
		;
		; 破壊レジスタ P
		; ワーク (33,34) オートパワーオフタイマー
		; =======================================================
TIMER_RESET:	LP    $33
		ANIM  0			; (33) = 0
		LP    $34
		ANIM  0			; (34) = 0
		RTN



		; =======================================================
		; スクロールアップ
		;
		; 破壊レジスタ I,A,P,Q,DP
		; =======================================================
SCROLL_UP:	LIA   4			; 0-29, 30-59, 60-89, 90-119, 120-149
		PUSH			; ドット毎に処理(5回ループ)
		LII   29
		LIA   VRAM >> 8
		LIDP  SCRLUP_LOOP1 + 1	; 自己書き換え
		STD
SCRLUP_LOOP1:	LIDP  VRAM + $40	; 2行目を1行目にコピー
		LP    $10
		MVWD
		LIDL  $00
		LP    $10
		EXWD

		LIDL  $1E		; 3行目を2行目にコピー
		LP    $10
		MVWD
		LIDL  $40
		LP    $10
		EXWD

		LIDL  $5E		; 4行目を3行目にコピー
		LP    $10
		MVWD
		LIDL  $1E
		LP    $10
		EXWD

		LIDL  $5E		; 4行目をクリア
		CLRA
		FILD

		LIDP  SCRLUP_LOOP1 + 1	; 自己書き換え
		LDD
		ADIA  $02
		STD
		LOOP  SCRLUP_LOOP1

		LP    $30
		ANIM  0
		LP    $31
		LIA   3
		EXAM
		RTN



		; =======================================================
		; スクロールダウン
		;
		; 破壊レジスタ I,A,P,Q,DP
		; =======================================================
SCROLL_DOWN:	LIA   4			; 0-29, 30-59, 60-89, 90-119, 120-149
		PUSH			; ドット毎に処理(5回ループ)
		LII   29
		LIA   VRAM >> 8
		LIDP  SCRLDW_LOOP1 + 1	; 自己書き換え
		STD
SCRLDW_LOOP1:	LIDP  VRAM + $1E	; 3行目を4行目にコピー
		LP    $10
		MVWD
		LIDL  $5E
		LP    $10
		EXWD

		LIDL  $40		; 2行目を3行目にコピー
		LP    $10
		MVWD
		LIDL  $1E
		LP    $10
		EXWD

		LIDL  $00		; 1行目を2行目にコピー
		LP    $10
		MVWD
		LIDL  $40
		LP    $10
		EXWD

		LIDL  $00		; 1行目をクリア
		CLRA
		FILD

		LIDP  SCRLDW_LOOP1 + 1	; 自己書き換え
		LDD
		ADIA  $02
		STD
		LOOP  SCRLDW_LOOP1

		CALL CSR_CLEAR		; カーソル座標クリア
		RTN



		; =======================================================
		; 全画面クリア（CLS） ※カーソル座標も初期化される
		;
		; 破壊レジスタ I,A,X,P,Q,DP
		; =======================================================
CLS_START:	LIA   4
		PUSH
		LIB   VRAM >> 8
		LIA   VRAM & $FF
		CAL   TOXM
		LII   59		; 60ドット分
		CLRA
CLS_LOOP1:	IX
		FILD			; 1,3行目クリア
		LP    X_Reg
		ORIM  $3F
		IX
		FILD			; 2,4行目クリア
		ORIM  $FF
		LP    X_Reg + 1
		ADIM  1			; 次のブロック
		LOOP  CLS_LOOP1



		; =======================================================
		; カーソル座標初期化
		;
		; 破壊レジスタ I,A,DP
		; =======================================================
CSR_CLEAR:	CLRA
		LII   1
		LP    $30
		FILM
		RTN



		; =======================================================
		; カーソル更新
		;
		; 入力 (30) = X座標(0-29)
		;      (31) = X座標(0-3)
		; 破壊レジスタ A,DP
		; =======================================================
CURSOR_UPDATE:	LP    $30
		ADIM  1			; X座標+1
		CPIM  30
		JRCP  CSRUP_JMP1
		ANIM  0
		LP    $31
		ADIM  1
CSRUP_JMP1:	RTN



		; =======================================================
		; 4x7ドット半角文字フォント
		; =======================================================
		nolist
		include(ascii4_font.s)
