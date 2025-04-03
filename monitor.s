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

;   0         1         2         3
;   0123456789012345678901234567890
; ┌───────────────┐
; │6700 00112233-44556677:XX [12]│
; │6700 00112233-44556677:XX [12]│
; │6700 00112233-44556677:XX [12]│
; │6700 0011223344556677 12345678│
; └───────────────┘


		; =======================================================
		; 設定
		; =======================================================
TARGET		equ   1350	; PC-1350は 1350、PC-1360/60Kは 1360 を指定



		; =======================================================
		; ラベル定義ファイル
		; =======================================================
		nolist
		if TARGET = 1350
			org   $6800	; オブジェクトロードアドレス
			include(SYMBOL1350.h)
		else
			org   $F300
			include(SYMBOL1360.h)
		endif
		list



		; =======================================================
		; 30桁表示マシン語モニター
		;
		; ワーク (2F) 編集モード(1…ON、0…OFF)
		;        (30,31) X座標,Y座標
		;        (32) キーリピートフラグ
		;        (33,34) オートパワーオフタイマー
		;        (35,36) 1行目の表示アドレス(L,H)
		;        (37) チェックサム
		; =======================================================
MONITOR:	LII   8
		CLRA
		LP    $2F
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

		; ----------------------- メインループ -----------------------
MON_LOOP2:	CALL  KEY_REPEAT
		CPIA  Key_CLS		; CLSキーで終了
		JRZP  MON_END
		CPIA  Key_UP		; ↑キー
		JRZP  MON_UP
		CPIA  Key_DOWN		; ↓キー
		JRZP  MON_DOWN
		CPIA  Key_ENTER		; ENTERキーは
		JRZP  MON_DOWN		;   ↓キーと同じ
		CPIA  Key_MODE		; MODEキー
		JRZP  MON_MODE
		JRM   MON_LOOP2

		; ----------------------- ↓キー処理 -----------------------
MON_DOWN:	LIB   $00
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
		JRM   MON_LOOP2

		; ----------------------- ↑キー処理 -----------------------
MON_UP:		LIB   $00
		LIA   $08
		LP    $35
		SBB			; (35,36) -= 8
		LP    K_Reg
		LIQ   $35
		MVB			; KL = (35,36)
		CALL  SCROLL_DOWN
		CALL  LINE_PRINT	; 1行出力
		JRM   MON_LOOP2

		; ----------------------- CLSキー処理 -----------------------
MON_END:	CALL  CLS_START		; 画面クリア
		CAL   POPX		; X復帰
		RC
		RTN   			; BASICへ

		; ----------------------- MODEキー処理 -----------------------
MON_MODE:	LP    $2F
		TSIM  $FF
		JRZP  MODE_JMP1
		ANIM  0			; MODE = 0
		JRP   MODE_JMP2
MODE_JMP1:	ORIM  1			; MODE = 1
MODE_JMP2:	CALL  CSR_CLEAR		; カーソル座標クリア
		JRM   MON_INIT

		; ----------------------- 1行表示 -----------------------
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
		LP    $2F
		TSIM  $01		; MODE = 1 なら
		JRNZP LPRINT_JMP1	;     '-'を出力しない
		LDR
		STP
		CPIM  4
		JRNZP LPRINT_JMP1
		LIA   '-'
		CALL  CHAR		; '-'出力
LPRINT_JMP1:	LOOP  LPRINT_LOOP1
		LP    $2F
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
		LIQ   K_Reg
		LP    X_Reg
		MVB			; X = KL
		LIB   0
		LIA   9
		LP    X_Reg
		SBB			; X = X - 9
		LIA   7
		PUSH
LPRINT_LOOP2:	IXL
		IYS
		LOOP  LPRINT_LOOP2
		LP    $30
		ADIM  2			; X座標+2
		LIA   ']'
		CALL  CHAR		; ']'出力
		RTN

LPRINT_JMP2:	LIA   '|'
		CALL  CHAR		; '|'出力
		LIQ   K_Reg
		LP    X_Reg
		MVB			; X = KL
		LIB   0
		LIA   9
		LP    X_Reg
		SBB			; X = X - 9
		LIA   7
		PUSH
LPRINT_LOOP3:	IXL
		CAL   XTO38
		CALL  CHAR		; キャラクタ表示
		CAL   R38TOX
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
		; 1バイトデータ読み出し(オートインクリメント)
		;
		; 入力 KL = アドレス(LH)
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
		LIB   4
		CAL   BLOCK		; 1～4ドット出力
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
FONTADR_CALC:	CPIA  $F0		; F0以上なら
		JRCP  FONT_JMP1
		SBIA  $10		;     10減算
FONT_JMP1:	CPIA  $A0		; A0以上なら
		JRCP  FONT_JMP2
		SBIA  $20		;     20減算
FONT_JMP2:	SBIA  $20		; 20減算
		JRNCP FONT_JMP3
		LIA   $00		; 00-1Fは20にする
FONT_JMP3:	LIB   $00
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
KEY_JMP1:	RTN			; リピート中(2)ならリターン

					; リピート判定
KEY_JMP2:	CPIA  Key_ENTER		; リピート除外キー
		JRZM  KEY_REPEAT
		CPIA  Key_MODE		; リピート除外キー
		JRZM  KEY_REPEAT
		CPIA  Key_SHIFT
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
		RTN



		; =======================================================
		; 入力待ちキー入力
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
		CPIM  200		; 200*1.5s=300秒でオートパワーオフ
		JRCM  INKEY_WAIT
		CALL  TIMER_RESET	;     オートパワーオフタイマーリセット
		LIA   $0C
		CAL   OUTC		;     パワーオフ(OUTC ← $0C)
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
		JRCP  CURSOR_JMP1
		ANIM  0
		LP    $31
		ADIM  1
CURSOR_JMP1:	RTN



		; =======================================================
		; 4x7ドット半角文字フォント
		; =======================================================
		nolist
		include(ascii4_font.s)
