		; +============================================+
		; |  PC-1350/60/60K 漢字表示システム           |
		; |                       by けいくん＠ちた    |
		; |                          (@pockecom_love)  |
		; |                                            |
		; |  表示モード：25桁4行, 30桁4行, 37桁4行     |
		; |  漢字フォント：5x7dot, 7x7dot, 11x7dot     |
		; |  半角フォント：4x7dot, 5x7dot              |
		; |                                            |
		; |  [謝辞]                                    |
		; |  サイト Little Limit で公開されている日本  |
		; |  語フォントを利用させていただきました。    |
		; |  https://littlelimit.net/font.htm          |
		; +============================================+

		; =======================================================
		; 設定
		; =======================================================
TARGET		equ   1360	; PC-1350は 1350、PC-1360/60Kは 1360 を指定
KANJI		equ   7		; 漢字フォントの横ドット数(5 or 7 or 11)を指定
COLUMN		equ   37	; 桁数(25 or 30 or 37)を指定
				;  (11ドット漢字フォント使用時は37指定不可)
FONT		equ   1		; フォント読み込み…1
TEXT		equ   1		; テキストデータ読み込み…1

				; --- ツールの設定 ---
TOOL		equ   3		; 同梱ツールの選択
				;  (1…全角順次表示、2…テキスト表示
				;   3…テキストビューア、4…ベンチマークテスト)
NOSCROLLUP	equ   0		; [TOOL1]スクロールアップなし…1
KEYSTOP		equ   0		; [TOOL1,2]キーストップする…1
KEYSCAN		equ   1		; [TOOL1,2,3]キー入力ルーチン(1…有効)
CRMARK		equ   1		; [TOOL3]改行マーク(1…表示)

				; --- おまけ ---
STRING_FLAG	equ   0		; 文字列表示(API)(1…有効)
CURSOR_FLAG	equ   0		; カーソル設定(API)(1…有効)
PRINT_FLAG	equ   0		; 拡張PRINT文(1…有効) ※ PC-1350専用

		if TARGET = 1350
LOAD_ADR		equ   $2040	; オブジェクトロードアドレス
TOOL_ADR		equ   $6960	; ツール先頭アドレス
LINENUMBER_BUF		equ   $6D00	; [TOOL3]行番号ポインタバッファ
LINE_MAX		equ   127	; [TOOL3]最大行番号(4～255)
		else
LOAD_ADR		equ   $8040
TOOL_ADR		equ   $F600
LINENUMBER_BUF		equ   $FB00
LINE_MAX		equ   255
		endif



		; =======================================================
		; ラベル定義ファイル、フォントファイル読み込み
		; 対応漢字コードの末尾定義
		; =======================================================
		nolist
		if TARGET = 1350
			include(SYMBOL1350.h)

			if FONT = 1
				org   LOAD_ADR
			endif

			if FONT = 1
				include(ascii4_font.s)
			else
ASCII4_FONT			equ   LOAD_ADR
			endif

			if KANJI = 5
				if FONT = 1
					include(kanji5_font.s)
				else
KANJI_FONT				equ   LOAD_ADR + $0280
				endif
END_CODE			equ   $4F54		; 全角フォント最終JISコード + 1
			endif
			if KANJI = 7
				if FONT = 1
					include(kanji7_font_1350.s)
				else
KANJI_FONT				equ   LOAD_ADR + $0280
				endif
END_CODE			equ   $454A		; 全角フォント最終JISコード + 1
			endif
			if KANJI = 11
				if FONT = 1
					include(kanji11_font_1350.s)
				else
KANJI_FONT				equ   LOAD_ADR + $0280
				endif
END_CODE			equ   $3B60		; 全角フォント最終JISコード + 1
			endif
		endif

		if TARGET = 1360
			include(SYMBOL1360.h)

			if FONT = 1
				org   LOAD_ADR
			endif

			if FONT = 1
				include(ascii4_font.s)
			else
ASCII4_FONT			equ   LOAD_ADR
			endif

			if KANJI = 5
				if FONT = 1
					include(kanji5_font.s)
				else
KANJI_FONT				equ   LOAD_ADR + $0280
				endif
END_CODE			equ   $4F54		; 全角フォント最終JISコード + 1
			endif
			if KANJI = 7
				if FONT = 1
					include(kanji7_font_1360.s)
				else
KANJI_FONT				equ   LOAD_ADR + $0280
				endif
END_CODE			equ   $4F54		; 全角フォント最終JISコード + 1
			endif
			if KANJI = 11
				if FONT = 1
					include(kanji11_font_1360.s)
				else
KANJI_FONT				equ   LOAD_ADR + $0280
				endif
END_CODE			equ   $457F		; 全角フォント最終JISコード + 1
			endif
		endif
		list



		; =======================================================
		; テキストデータ
		;
		; シフトJISコードのバイナリデータを配置する
		; 終端は 00
		; =======================================================
		nolist
		if TEXT = 1
			if TARGET = 1350
TEXT_DATA:			incbin(text_data_1350.txt)
			else
TEXT_DATA:			incbin(text_data_1360.txt)
			endif
			db 0
		else
TEXT_DATA		equ   $68DC
		endif
		list



		; =======================================================
		; ツール(1～4)先頭アドレス
		; =======================================================
		org   TOOL_ADR


		; =======================================================
		; [TOOL1]全角順次表示
		;
		; JISコード 21～25区、30～44区まで順次表示する
		; KEYSTOP = 1の場合、↓キーで1行ずつ順次表示
		; Mode or Breakキーで終了
		;
		; ワーク (31,32) 表示JISコード
		; =======================================================
		if TOOL = 1

		CALL  CLS_START		; 画面クリア
		LIA   $21		; 初期JISコード設定
		LP    $30
		EXAM
		LDM
		LP    $31
		EXAM

		if KEYSTOP = 1
			LP    $32		; キーリピートフラグON
			LIA   1			; 起動時のEnterキーをキャンセルするため
			EXAM
		endif

		LIA   3
		PUSH
ALL_LOOP1:	CALL  JIS_LINE		; 4行分表示
		LOOP  ALL_LOOP1

ALL_LOOP2:
		if KEYSTOP = 1
			CALL  KEY_REPEAT	; キー入力(キーリピート付き)
			CPIA  Key_CLS		; CLSキー
			JRZP  ALL_JMP2		;     終了
			CPIA  Key_DOWN		; ↓キー
			JRZP  ALL_JMP1
			CPIA  Key_ENTER		; Enterキー
			JRZP  ALL_JMP1
			JRM   ALL_LOOP2
		endif

ALL_JMP1:	CALL  JIS_LINE		; 1行表示
		JRNCM ALL_LOOP2		; C=0ならばループ
ALL_JMP2:	RTN



		; =======================================================
		; JISコード順次1行表示
		;
		; 入力 (30,31) = JISコード
		; =======================================================
JIS_LINE:
		if KANJI = 5		; 漢字5ドットフォントの場合
			LIA   COLUMN - 1
		else			; 漢字7or11ドットフォントの場合
			LIA   COLUMN / 2 - 1
		endif
		PUSH			; 1行分ループ
		LP    A_Reg
		LIQ   $30
		MVB			; AB = (34,35)
JISLIN_LOOP1:	CALL  JIS_PRINT
		JRCP  JISLIN_JMP1
		LOOP  JISLIN_LOOP1
		RC
		JRP   JISLIN_JMP2
JISLIN_JMP1:	POP
JISLIN_JMP2:	LP    $30
		LIQ   A_Reg
		MVB			; (34,35) = AB
		RTN



		; =======================================================
		; JISコード順次1文字表示
		;
		; 入力 AB = JISコード
		; =======================================================
JIS_PRINT:	PUSH			; A保存
		EXAB
		PUSH			; B保存
		EXAB
		CALL  KANJI_CHAR

		if NOSCROLLUP = 1		; スクロールアップしない
			LIDP  CSRY		; Y座標 = 3
			LDD
			CPIA  3
			JRNZP JISPRT_JMP1
			LIDL  CSRX & $FF	;     X座標 < COLUMN - 1
			LDD
			CPIA  COLUMN - 1
			JRCP  JISPRT_JMP1	; 右下まで出力したら
			CALL  CSR_CLEAR		;     カーソル座標クリア
		endif

JISPRT_JMP1:	POP			; B復帰
		EXAB
		POP			; A復帰
		INCB			; B = B + 1
		LP    B_Reg
		CPIM  $7F		; Bが7F未満ならリターン
		JRCP  JISPRT_JMP3
		ANIM  0
		ORIM  $21		; B = 21
		INCA			; A = A + 1
		CPIA  $26		; A = 26 ならば
		JRNZP JISPRT_JMP2
		ADIA  10		;     A = A + 10 (26～2F区はスキップ)
JISPRT_JMP2:	CPIA  $46		; 46になったら
		JRCP  JISPRT_JMP3
		SC			;     C = 1
		RTN
JISPRT_JMP3:	RC			;     C = 0
		RTN

		endif



		; =======================================================
		; [TOOL2]テキストTYPE表示
		;
		; TEXT_DATA = テキストデータ(終端0)
		; =======================================================
		if TOOL = 2

		CALL  CLS_START		; 画面クリア
		LIB   (TEXT_DATA - 1) >> 8
		LIA   (TEXT_DATA - 1) & $FF
		CAL   TOX		; X = テキストデータ - 1
		CALL  MOJI_START
		RTN

		endif



		; =======================================================
		; [TOOL3]テキストビューア
		;
		; TEXT_DATA = テキストデータ(終端0)
		; ワーク (35) 表示行番号(1行目の行番号)
		; =======================================================
		if TOOL = 3

TEXT_VIEWER:	CALL  TIMER_RESET	; オートパワーオフタイマーリセット
		LII   9
		CLRA
		LIDP  LINENUMBER_BUF
		FILD			; 5行分の行番号バッファクリア
		CALL  TEXT_INIT		; 初期4行表示
		LP    $35
		ANIM  0			; 初期表示行番号

		; ----------------------- メインループ -----------------------
TEXT_JMP2:	CALL  KEY_REPEAT
		CPIA  Key_CLS		; CLSキーで終了
		JRZP  TEXT_END
		CPIA  Key_UP		; ↑キー
		JRZP  TEXT_UP
		CPIA  Key_DOWN		; ↓キー
		JRZP  TEXT_DOWN
		CPIA  Key_ENTER		; ENTERキーは
		JRZP  TEXT_DOWN		;   ↓キーと同じ
		CPIA  Key_SHIFT		; SHIFTキー
		JRZP  TEXT_SHIFT
		JRM   TEXT_JMP2

		; ----------------------- ↓キー処理 -----------------------
TEXT_DOWN:	LP    $35
		LDM
		CPIA  LINE_MAX - 4
		JRNCM TEXT_JMP2		; 最大行番号ならスキップ
		ADIA  4
		CALL  LINE_SEARCH	; 表示行番号 + 4 の行番号サーチ
		JRCM  TEXT_JMP2		; C=1(ファイル終端)ならば

		LIDP  CSRX
		ANID  0			; X座標 = 0
		LIDL  CSRY & $FF
		LIA   4
		STD			; Y座標 = 4

		CALL  LINE_PRINT
		JRNCP TEXT_JMP4		; データ終端でなければ
		LP    X_Reg		;     X = $0000
		ANIM  0
		LP    X_Reg + 1
		ANIM  0
TEXT_JMP4:	LP    $35
		LDM
		ADIA  5
		CALL  LINE_REGISTER	; 次の行番号登録
		LP    $35
		ADIM  1			; 表示行番号 + 1
		JRM   TEXT_JMP2

		; ----------------------- ↑キー処理 -----------------------
TEXT_UP:	LIDP  INDICATOR_ADR
		TSID  $01		; SHIFTモード時
		JRNZP TEXT_SUP		;     SHIFT+↑キー処理へ
		LP    $35
		CPIM  0
		JRZM  TEXT_JMP2		; 0行目ならスキップ
		SBIM  1			; 表示行番号 - 1
		CALL  SCROLL_DOWN	; スクロールダウン
		LP    $35
		LDM
		CALL  LINE_SEARCH	; X = A行番号のアドレス - 1
		CALL  LINE_PRINT
		JRM   TEXT_JMP2

		; ------------------- SHIFT + ↑キー処理 -------------------
TEXT_SUP:	CALL  TEXT_INIT
		LIDP  INDICATOR_ADR
		ANID  $FE		; SHIFTインジケータ消去
		LP    $35
		ANIM  0			; 初期表示行番号
		JRM   TEXT_JMP2

		; --------------------- SHIFTキー処理 ---------------------
TEXT_SHIFT:	LIDP  INDICATOR_ADR
		TSID  $01
		JRZP  TEXT_JMP6
		ANID  $FE		; SHIFTインジケータ消去
		JRM   TEXT_JMP2
TEXT_JMP6:	ORID  $01		; SHIFTインジケータ点灯
		JRM   TEXT_JMP2

		; ----------------------- CLSキー処理 -----------------------
TEXT_END:	LIDP  INDICATOR_ADR
		ANID  $FE		; SHIFTインジケータ消去
		RTN

		; ----------------------- 初期4行表示 -----------------------
TEXT_INIT:	CALL  CLS_START		; 画面クリア
		LIB   (TEXT_DATA - 1) >> 8
		LIA   (TEXT_DATA - 1) & $FF
		CAL   TOX		; X = テキストデータ - 1
		LP    $32		; キーリピートフラグON
		LIA   1			; 起動時のEnterキーをキャンセルするため
		EXAM
		CLRA
		CALL  LINE_REGISTER	; 0行目登録
		LP    $35		; 表示行番号 = 0
		ANIM  0
		LIA   3
		PUSH
TEXT_LOOP1:	CALL  LINE_PRINT
		JRNCP TEXT_JMP1		; C=1(データ終端)なら
		POP			;     ループ脱出
		RTN
TEXT_JMP1:	LP    $35
		ADIM  1
		LDM
		CALL  LINE_REGISTER	; 次の行番号登録
		LOOP  TEXT_LOOP1
		RTN

		; ----------------------- 1行表示 -----------------------
LINE_PRINT:	LIDP  CSRY
		LDD
		CPIA  4
		JRCP  LPRINT_JMP1
		CALL  CARRIAGE_RETURN
LPRINT_JMP1:	IXL			; データ読み込み
		CPIA  0			; 0なら終端
		JRNZP LPRINT_JMP2
		SC			;     C = 1
		RTN			;     リターン
LPRINT_JMP2:	CPIA  $0D		; 0Dは単にスキップ
		JRZM  LPRINT_JMP1
		CPIA  $0A		; 改行コードなら
		JRNZP LPRINT_JMP4

		if CRMARK = 1		; 改行マークを表示するならば
			LIA   $7F	;     改行マークコード
			CAL   XTO38	;     (38,39) = X
			CALL  CHAR	;     半角1文字表示
			CAL   R38TOX	;     X = (38,39)
		endif
LPRINT_JMP3:	LIDP  CSRX
		ANID  0			;     X座標 = 0
		LIDL  CSRY & $FF
		LDD
		INCA			;     Y座標 + 1
		STD
		RTN			;     リターン

		; ----------------------- 全角判定 -----------------------
LPRINT_JMP4:	CPIA  $81		; 81以上ならば
		JRCP  LPRINT_JMP5
		CPIA  $9F		; 9F以下ならば
		JRCP  LPRINT_JMP6

		; ----------------------- 半角処理 -----------------------
LPRINT_JMP5:	CAL   XTO38		; (38,39) = X
		CALL  CHAR		; 半角1文字表示
LRPINT_JMP8:	CAL   R38TOX		; X = (38,39)
		LIDP  CSRX
		LDD
		CPIA  COLUMN
		JRNCM LPRINT_JMP3	; 右端まで表示したら
		JRM   LINE_PRINT

		; ----------------------- 全角処理 -----------------------
LPRINT_JMP6:	EXAB
		LIDP  CSRX
		LDD
		if (KANJI = 5) & (COLUMN = 25)	; 漢字5ドットフォントの場合
			CPIA  COLUMN 		; X座標が右端ならば
		else				; 漢字7or11ドットフォントの場合
			CPIA  COLUMN - 1	; 全角右半分が画面からはみ出る場合
		endif
		JRCP  LPRINT_JMP7
		DX				;     1バイト戻す
		JRM   LPRINT_JMP3		;     改行してリターン
LPRINT_JMP7:	IXL			; 2バイト目読み込み
		EXAB			; A=第1バイト,B=第2バイト
		CAL   XTO38		; (38,39) = X
		CALL  KANJI_CHAR	; 全角1文字表示
		JRM   LRPINT_JMP8



		; =======================================================
		; 行番号登録
		;
		; 入力 A = 行番号(論理行)
		;      X = 該当行のテキストポインタ - 1
		; 破壊レジスタ B,Y,P,Q,DP
		; =======================================================
LINE_REGISTER:	PUSH
		LIB   (LINENUMBER_BUF - 1) >> 8
		LIA   (LINENUMBER_BUF - 1) & $FF
		CAL   TOY		; Y = (LINENUMBER_BUF) - 1
		LIB   0
		POP
		PUSH			; A保存
		LP    Y_Reg
		ADB			; Y = Y + BA
		LP    Y_Reg
		ADB			; Y = Y + BA
		LP    X_Reg
		LDM
		IYS			; 下位アドレス書き込み
		LP    X_Reg + 1
		LDM
		IYS			; 上位アドレス書き込み
		POP			; A復帰
		RTN



		; =======================================================
		; 行番号サーチ
		;
		; 入力 A = 行番号(論理行)
		; 出力 X = 該当行のテキストポインタ - 1
		;      C = 0…見つかった、1…見つからない(X=0)
		; 破壊レジスタ A,B,P,Q,DP
		; =======================================================
LINE_SEARCH:	PUSH
		LIB   (LINENUMBER_BUF - 1) >> 8
		LIA   (LINENUMBER_BUF - 1) & $FF
		CAL   TOX		; X = (LINENUMBER_BUF) - 1
		LIB   0
		POP
		LP    X_Reg
		ADB			; X = X + BA
		LP    X_Reg
		ADB			; X = X + BA
		IX			; X = X + 1, DP = X
		LP    X_Reg
		MVBD			; X = (DP)
		LP    X_Reg + 1
		CPIM  0
		JRNZP LINE_JMP1		; アドレスの上位 = 0 ならば
		SC			;     C = 1
LINE_JMP1:	RTN

		endif



		; =======================================================
		; [TOOL4]2000文字出力ベンチマークテスト
		; =======================================================
		if TOOL = 4

		CALL  CLS_START		; 画面クリア
		LIA   99		; 100回ループ
		PUSH
BENCH_LOOP1:	CALL  STRING_PRINT
		db    "**PC-1350/PC-1360K**", 0
		LOOP  BENCH_LOOP1
		RTN

		endif



		; =======================================================
		; [TOOL5]開発用
		; =======================================================
		if TOOL = 5

		CALL  CLS_START
KAIHATSU_LOOP1:	CALL  KEY_REPEAT
		CPIA  Key_SHIFT
		JRNZP KAIHATSU_JMP2
		LIDP  INDICATOR_ADR
		TSID  $01
		JRZP  KAIHATSU_JMP1
		ANID  $FE
		JRM   KAIHATSU_LOOP1
KAIHATSU_JMP1:	ORID  $01
		JRM   KAIHATSU_LOOP1
KAIHATSU_JMP2:	CPIA  Key_CLS
		JRZP  KAIHATSU_END
		PUSH
		SWP
		ANIA  $0F
		ORIA  $30
		CPIA  $3A
		JRCP  KAIHATSU_JMP3
		ADIA  7
KAIHATSU_JMP3:	LIDP  KAIHATSU_STR + 1
		STD
		POP
		ANIA  $0F
		ORIA  $30
		CPIA  $3A
		JRCP  KAIHATSU_JMP4
		ADIA  7
KAIHATSU_JMP4:	LIDP  KAIHATSU_STR + 2
		STD
		CALL  STRING_PRINT
KAIHATSU_STR:	db    '[', 0, 0, '] ', 0
		JRM   KAIHATSU_LOOP1
KAIHATSU_END:	RTN

		endif



;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;■ 　         以下、漢字システム本体、おまけ、拡張PRINT文         　　■
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

		; =======================================================
		; 半角1文字表示
		;
		; 入力 A = 文字コード
		;      (CSRX) = X座標
		;      (CSRY) = Y座標
		; 破壊レジスタ A,B,X,Y,K,N,P,Q,DP
		; =======================================================
CHAR:		CPIA  $0A		; A = 0A ならば
		JRNZP CHAR_JMP1
		CALL  CARRIAGE_RETURN	;     改行する
		RTN
CHAR_JMP1:	CPIA  $FE		; A = FE ならば
		JRNZP CHAR_JMP2		;     スキップ
		RTN
CHAR_JMP2:
		if COLUMN = 25		; 25桁モードで改行マーク表示用
			if (TOOL = 3) & (CRMARK = 1)
				CPIA  $7F	; 改行マークコード
				JRNZP CHAR_JMP5
				if TARGET = 1350	; PC-1350は後ろから取り出す
					LIB   (CRMARK_FONT + 5) >> 8
					LIA   (CRMARK_FONT + 5) & $FF
					CAL   TOX
				else
					LIB   CRMARK_FONT >> 8
					LIA   CRMARK_FONT & $FF
					CAL   TOXM
				endif
				JRP   CHAR_JMP6
			endif
		endif

CHAR_JMP5:	CALL  FONTADR_CALC
CHAR_JMP6:	LIDP  CSRX
		LDD
		CPIA  COLUMN		; X座標が右端ならば
		JRCP  CHAR_JMP3
		CALL  CURSOR_UPDATE	;     カーソル右移動
CHAR_JMP3:
		if COLUMN = 25
			CALL  VRAM1_ADR

			if TARGET = 1350
				CAL   PRINT1		; 1～5ドット出力+余白
			else
				LIDP  BANK_SELECT
				LDD
				PUSH			; 現在のBANK保存
				LIA   1			; BANK1選択
				STD
				LIB   5
				CAL   BLOCK		; 1～5ドット出力
				POP
				LIDP  BANK_SELECT
				STD			; BANK復帰
				CLRA			; 余白
				IYS
			endif
		endif

		if COLUMN = 30
			CALL  VRAM1_ADR
			LIB   4
			CAL   BLOCK		; 1～4ドット出力
			CLRA			; 余白
			IYS
		endif

		if COLUMN = 37
			LIA   3			; 4回ループ
			PUSH
			CALL  CSR2GCSR		; 座標→グラフィック座標
			CALL  VRAM2_ADR		; VRAMアドレス算出
CHAR_LOOP1:		IXL			; 1～4ドット出力
			IYS
			INCK			; X座標+1
			DECN
			JRNZP CHAR_JMP4		; VRAM境界判定
			CALL  VRAM2_ADR		;     VRAMアドレス再計算
CHAR_JMP4:		LOOP  CHAR_LOOP1
		endif

		CALL  CURSOR_UPDATE	; カーソル右移動
		RTN

		if CRMARK = 1
			if (TARGET= 1350) & (COLUMN = 25)
CRMARK_FONT:			db $0F, $10, $54, $38, $10	; 改行マーク逆順
			endif
			if (TARGET= 1360) & (COLUMN = 25)
CRMARK_FONT:			db $10, $38, $54, $10, $0F	; 改行マーク
			endif
		endif



		; =======================================================
		; 半角フォントアドレス計算
		;
		; 入力 A = 文字コード
		; 出力 X = フォントアドレス - 1
		;          ※ PC-1350かつ25桁の場合は、フォントアドレス + 1
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
		LIA   $20		; 00-1Fは20にする
FONT_JMP3:	LIB   $00
		if COLUMN = 25			; 25桁の場合
			if TARGET = 1350
				INCA		; 1つ後ろ
			endif
			CAL   TOX
			LP    A_Reg
			ADB			; BA = BA + BA (2倍)
			LP    A_Reg
			ADB			; BA = BA + BA (4倍)
			LP    X_Reg
			ADB			; X = X + BA (5倍する)
			LIB   FONT_ADR >> 8
			LIA   FONT_ADR & $FF	; 内蔵キャラクタフォントアドレス
			LP    X_Reg
			ADB			; X = X + BA
			if TARGET <> 1350
				DX
			endif
		else				; 30,37桁の場合
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
		endif
		RTN



		; =======================================================
		; 全角1文字表示
		;
		; 入力 AB = 文字コード(JIS or ShiftJIS)
		;      (CSRX) = X座標
		;      (CSRY) = Y座標
		; 破壊レジスタ A,B,X,Y,P,Q,DP
		; =======================================================
KANJI_CHAR:	CPIA  $81		; 第1バイトが81以上なら
		JRCP  KANJI_JMP1
		CALL  JIS_CONV		;     ShiftJIS→JIS変換
KANJI_JMP1:	CPIA  $26
		JRCP  KANJI_JMP2
		CPIA  $30
		JRCP  KANJI_JMP3	; 25～2F区ならば■に変換
KANJI_JMP2:	CAL   TOX		; X = AB
		EXAB
		CAL   TOY		; Y = AB
		LIA   END_CODE & $FF
		LIB   END_CODE >> 8
		LP    Y_Reg
		SBB			; Y - BA  ※ END_CODE - JISコード
		LP    A_Reg
		LIQ   X_Reg
		MVB			; AB = X
		JRCP  KANJI_JMP4	; END_CODE以降のJISコードは
KANJI_JMP3:	LIA   $22		;     ■に変換
		LIB   $23
KANJI_JMP4:	CALL  KFONTADR_CALC	; フォントアドレス計算

		LIDP  CSRX
		LDD
		if (KANJI = 5) & (COLUMN = 25)	; 漢字5ドットフォントの場合
			CPIA  COLUMN 		; X座標が右端ならば
		else				; 漢字7or11ドットフォントの場合
			CPIA  COLUMN - 1	; 全角右半分が画面からはみ出る場合
		endif
		JRCP  KANJI_JMP5
		CALL  CARRIAGE_RETURN

KANJI_JMP5:
		if (COLUMN = 25) | (COLUMN = 30)	; 25,30桁の場合
			if KANJI = 5			; 漢字5ドットフォントの場合
				CALL  VRAM1_ADR
				LIB   5			; 1～5ドット目
				CAL   BLOCK
				if COLUMN = 25		; 25桁モードでは全角の文字幅は半角と同じ
					CLRA		; 余白
					IYS
				else			; 30桁モード時
					CLRA		; 余白
					IY
					LII   3
					FILD
					CALL  CURSOR_UPDATE	; カーソル右移動(全角左半分)
				endif
			else
				CALL  VRAM1_ADR		; 左半分
				if COLUMN = 25
					LIB   6		; 1～6ドット目
				endif
				if COLUMN = 30
					LIB   5		; 1～5ドット目
				endif
				CAL   BLOCK
				CALL  CURSOR_UPDATE	; カーソル右移動(全角左半分)

				CALL  VRAM1_ADR		; 右半分
				if KANJI = 7
					if COLUMN = 25	; 漢字7ドットフォント、25桁の場合
						IXL		; 7ドット目
						IYS
						CLRA		; 余白5ドット
						IY
						LII   4
						FILD
					endif
					if COLUMN = 30	; 漢字7ドットフォント、30桁の場合
						IXL		; 6,7ドット目
						IYS
						IXL
						IYS
						CLRA		; 余白3ドット
						IYS
						IYS
						IYS
					endif
				endif
				if KANJI = 11		; 漢字11ドットフォントの場合
					if COLUMN = 25
						LIB   5		; 7～11ドット目
						CAL   BLOCK
						CLRA		; 余白1ドット
						IYS
					endif
					if COLUMN = 30
						LIB   5		; 6～10ドット目
						CAL   BLOCK	; (11ドット目は欠落)
					endif
				endif
			endif
		endif
		if COLUMN = 37			; 37桁の場合
			if KANJI = 5			; 漢字5ドットフォントの場合
				LIA   4			;     5ドット分
			else				; 漢字7ドットフォントの場合
				LIA   6			;     7ドット分
			endif
			PUSH
			CALL  CSR2GCSR			; 座標→グラフィック座標
			CALL  VRAM2_ADR			; VRAMアドレス算出
KANJI_LOOP1:		IXL				; 1～7ドット目
			IYS
			INCK				; X座標+1
			DECN
			JRNZP KANJI_JMP6		; VRAM境界判定
			CALL  VRAM2_ADR			;     VRAMアドレス再計算
KANJI_JMP6:		LOOP  KANJI_LOOP1

			if KANJI = 5			; 漢字5ドットフォントの場合
				LIA   2			;     余白3ドット
				PUSH
				CLRA
KANJI_LOOP2:			IYS
				INCK
				DECN
				JRNZP KANJI_JMP7	;     VRAM境界判定
				CALL  VRAM2_ADR		;         VRAMアドレス再計算
KANJI_JMP7:			LOOP  KANJI_LOOP2
			else				; 漢字7ドットフォントの場合
				CLRA			;     余白1ドット
				IYS
			endif
			CALL  CURSOR_UPDATE	; カーソル右移動(全角左半分)
		endif

		CALL  CURSOR_UPDATE	; カーソル右移動(全角右半分)
		RTN



		; =======================================================
		; シフトJIS → JIS変換
		;
		; 入力 AB = シフトJISコード(A=第1バイトC1, B=第2バイトC2)
		; 出力 AB = JISコード
		; 破壊レジスタ Q
		; =======================================================
JIS_CONV:	CPIA  $E0		; if C1 >= E0
		JRCP  JIS_JMP1
		SBIA  $40		;     C1 = C1 - 40
JIS_JMP1:	EXAB
		CPIA  $80		; if C2 >= 80
		JRCP  JIS_JMP2
		DECA			;     C2 = C2 - 1

JIS_JMP2:	CPIA  $9E		; if C2 >= 9E
		JRCP  JIS_JMP3
		SBIA  $7D		;     C2 = C2 - 7D
		EXAB
		SBIA  $70		;     C1 = (C1 - 70) * 2
		SL
		RTN
					; else
JIS_JMP3:	SBIA  $1F		;     C2 = C2 - 1F
		EXAB
		SBIA  $70		;     C1 = (C1 - 70) * 2 - 1
		SL
		DECA
		RTN



		; =======================================================
		; 全角フォントアドレス計算
		;
		; 入力 AB = JISコード(A=第1バイト,B=第2バイト)
		; 出力 X = フォントアドレス - 1
		; 破壊レジスタ A,B,P,Q,DP
		; =======================================================
KFONTADR_CALC:	CPIA  $30
		JRCP  KFONT_JMP1
		SBIA  10		; 26～2F区カット
KFONT_JMP1:	SBIA  $21		; 区
		EXAB
		SBIA  $21		; 点
		EXAB			; A=C1区,B=C2点
		PUSH
		CLRA
		EXAB
		CAL   TOX		; X = BA
		LIB   00
		LIA   94
KFONT_LOOP1:	LP    X_Reg
		ADB			; X = X + 94
		LOOP  KFONT_LOOP1
		LP    X_Reg		; 足しすぎた分の修正
		SBB			; X = X - 94
		LP    A_Reg
		LIQ   X_Reg
		MVB			; BA = X
		LP    A_Reg
		ADB			; BA = BA + BA (2倍)
		LP    A_Reg
		ADB			; BA = BA + BA (4倍)

		if KANJI = 5		; 漢字5ドットフォントの場合(5倍)
			LP    X_Reg
			ADB			; X = X + BA
		else			; 漢字7or11ドットフォントの場合
			LP    A_Reg
			ADB			; BA = BA + BA (8倍)
			LP    X_Reg
			LIQ   A_Reg
			EXB			; X <> BA
		endif
		if KANJI = 7		; 漢字7ドットフォントの場合(Xを7倍する)
			LP    X_Reg
			SBB			; X = X - BA (7倍)
		endif
		if KANJI = 11		; 漢字11ドットフォントの場合(Xを11倍する)
			LP    X_Reg
			ADB			; X = X + BA ( 9倍)
			LP    X_Reg
			ADB			; X = X + BA (10倍)
			LP    X_Reg
			ADB			; X = X + BA (11倍)
		endif

		LP    X_Reg
		LIB   KANJI_FONT >> 8
		LIA   KANJI_FONT & $FF	; フォント先頭アドレス加算
		ADB
		DX
		RTN



		; =======================================================
		; カーソル→グラフィック座標
		;
		; 入力 (CSRX) = X座標(0-36)
		;      (CSRY) = Y座標(0-3)
		; 出力 K(08) = X座標(0-149)
		;      L(09) = Y座標(0-3)
		; 破壊レジスタ A,P,DP
		;
		; ※ 37桁モードで使用
		; =======================================================
		if COLUMN = 37

CSR2GCSR:	LIDP  CSRY
		LDD
		LP    L_Reg
		EXAM			; L = (CSRY)
		LIDL  CSRX & $FF
		LDD
		RC
		SL
		SL
		LP    K_Reg
		EXAM			; K = (CSRX) * 4
		RTN

		endif



		; =======================================================
		; VRAMアドレス算出(1)
		;
		; 入力 (CSRX) = X座標(0-29)
		;      (CSRY) = Y座標(0-3)
		; 出力 Y = VRAMアドレス - 1
		; 破壊レジスタ A,B,Y,P,Q,DP
		;
		; ※ 25,30桁モードで使用
		; =======================================================
		if (COLUMN = 25) | (COLUMN = 30)

VRAM1_ADR:	LIB   VRAM >> 8
		LIDP  CSRX
		LDD
VRAM1_LOOP1:	SBIA  COLUMN / 5	; 桁数/5 を引けるだけ引く
		JRCP  VRAM1_JMP1
		LP    B_Reg
		ADIM  $02		; 桁数/5 で割った商の分だけ $200加算
		JRM   VRAM1_LOOP1
VRAM1_JMP1:	ADIA  COLUMN / 5	; 引きすぎた分を加算

		if COLUMN = 25		; 25桁モードの場合、Aを6倍する
			RC
			SL
			PUSH		; 2倍を保存
			SL
			LP    Y_Reg
			EXAM		; 4倍をYLに
			POP
			ADM		; 2倍 + 4倍
			LDM
		else			; 25桁モードの場合、Aを5倍する
			PUSH
			LP    Y_Reg
			EXAM
			POP
			RC
			SL
			SL		; 4倍
			ADM		; 1倍 + 4倍
			LDM
		endif

		CAL   TOY		; Y = BA
		LIDP  CSRY
		LDD			; A = Y座標
		LP    Y_Reg
		TSIA  $01
		JRZP  VRAM1_JMP2	; 偶数なら
		ADIM  $40		; 	$40加算
VRAM1_JMP2:	CPIA  2
		JRCP  VRAM1_JMP3	; 1以上なら
		ADIM  $1E		; 	$1E加算
VRAM1_JMP3:	DY			; Y = Y - 1
		RTN

		endif



		; =======================================================
		; VRAMアドレス算出(2)
		;
		; 入力 K(08) = X座標(0-149)
		;      L(09) = Y座標(0-3)
		; 出力 Y = VRAMアドレス - 1
		;      N = 30 - X座標 % 30  (※VRAM境界判定に利用)
		; 破壊レジスタ A,B,Y,P,Q,DP
		;
		; ※ 37桁モードで使用
		; =======================================================
		if COLUMN = 37

VRAM2_ADR:	LIB   VRAM >> 8
		LP    K_Reg
		LDM			; A = X座標
VRAM2_LOOP1:	SBIA  30		; 30を引けるだけ引く
		JRCP  VRAM2_JMP1
		LP    B_Reg
		ADIM  $02		; 30で割った商の分だけ $200加算
		JRM   VRAM2_LOOP1
VRAM2_JMP1:	ADIA  30		; 引きすぎた分を加算
		PUSH			; 30で割った余りを保存
		CAL   TOY		; Y = BA
		LP    L_Reg
		LDM			; A = Y座標
		LP    Y_Reg
		TSIA  $01
		JRZP  VRAM2_JMP2	; Y座標が0or2なら
		ORIM  $40		; 	$40加算
VRAM2_JMP2:	CPIA  2
		JRCP  VRAM2_JMP3	; Y座標が2or3なら
		ADIM  $1E		; 	$1E加算
VRAM2_JMP3:	DY			; Y = Y - 1
		LP    N_Reg
		LIA   30
		EXAM			; N = 30
		POP			; 余り復帰
		SBM			; N = 30 - A
		RTN

		endif



		; =======================================================
		; 入力待ちキー入力(キーリピート付き)
		;
		; 出力 A = キーコード
		; 破壊レジスタ I,A,P,Q,DP
		; ワーク (32) リピートフラグ
		; =======================================================
		if KEYSCAN = 1

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
INKEY_WAIT:	CAL   INKEY
		CAL   T6WAIT		; 6ms待ち
		JRNCP INKEY_JMP1	; キー入力あり
		CALL  TIMER_RESET	;     オートパワーオフタイマーリセット
		RTN

INKEY_JMP1:	LP    $32		; キーリピートOFF(0)
		ANIM  $00
		CLRA			; オートパワーオフタイマー + 1
		SC
		LP    $34
		ADCM			; (34) = (34) + 0 + 1
		LP    $33
		ADCM			; (33) = (33) + C
		CPIM  120		; 120*2.5s=300秒でオートパワーオフ
		JRCM  INKEY_WAIT
		CALL  TIMER_RESET	;     オートパワーオフタイマーリセット
		LIA   $0C
		CAL   OUTC		;     パワーオフ
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

		endif



		; =======================================================
		; スクロールアップ
		;
		; 破壊レジスタ I,A,P,Q,DP
		; =======================================================
SCROLL_UP:
		if (TOOL = 2) & (KEYSTOP = 1)
SCRLUP_JMP1:		CALL  KEY_REPEAT	; キー入力(キーリピート付き)
			CPIA  Key_CLS		; CLSキー
			JRNZP SCRLUP_JMP3	;     終了
			LDR			; 3段分スタック除去
			ADIA  6
			STR
			RTN
SCRLUP_JMP3:		CPIA  Key_DOWN		; ↓キー
			JRNZM SCRLUP_JMP1
		endif

		LIA   4			; 0-29, 30-59, 60-89, 90-119, 120-149
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
		RTN



		; =======================================================
		; スクロールダウン
		;
		; 破壊レジスタ I,A,P,Q,DP
		; =======================================================
		if TOOL > 1

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

		endif



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
		LII  1
		LIDP CSRX
		FILD
		RTN



		; =======================================================
		; カーソル更新
		;
		; 入力 (CSRX) = X座標(0-24)
		;      (CSRY) = X座標(0-3)
		; 破壊レジスタ A,DP
		; =======================================================
CURSOR_UPDATE:	LIDP  CSRX
		LDD
		INCA			; X座標+1
		CPIA  COLUMN + 1	; X座標 >= 26 or 31 or 37ならば
		JRNCP CARRIAGE_RETURN	; 改行
CURSOR_JMP1:	STD			; X座標更新
		RTN



		; =======================================================
		; 改行
		;
		; 破壊レジスタ A,DP
		; =======================================================
CARRIAGE_RETURN:LIDP  CSRX
		ANID  0			; X座標 = 0
		LIDL  CSRY & $FF	; Y座標 += 1
		LDD
		INCA
		STD
		CPIA  4			; Y座標 >= 4 ならば
		JRCP  CARRIAGE_JMP1
		LIA   3			;     Y座標 = 3
		STD
		CALL  SCROLL_UP		;     スクロールアップ
CARRIAGE_JMP1:	RTN



		; =======================================================
		; 文字列表示
		;
		; 入力 X = テキストデータアドレス - 1
		; 破壊レジスタ I,A,B,X,Y,(38),(39),P,Q,DP
		; =======================================================
MOJI_START:	IXL			; 第1バイト読み込み
		CPIA  0			; 0なら終端
		JRZP  MOJI_END
		CPIA  $0D		; 0Dは単にスキップ
		JRZM  MOJI_START
		CPIA  $81		; 81未満は半角
		JRCP  MOJI_JMP1
		CPIA  $A0		; A0未満なら全角
		JRCP  MOJI_JMP2
		CPIA  $E0		; E0以上なら全角
		JRNCP MOJI_JMP2

MOJI_JMP1:	CAL   XTO38		; (38,39) = X
		CALL  CHAR		; 半角1文字表示
		JRP   MOJI_JMP3

MOJI_JMP2:	EXAB
		IXL			; 第2バイト読み込み
		EXAB			; A=第1バイト,B=第2バイト
		CAL   XTO38		; (38,39) = X
		CALL  KANJI_CHAR	; 全角1文字表示
MOJI_JMP3:	CAL   R38TOX		; X = (38,39)
		JRM   MOJI_START
MOJI_END:	RTN



		; =======================================================
		; [おまけ]文字列表示(API)
		;
		; 書式 78(STRING_PRINT)文字列コード...00
		; 例） 78FA2841424300 (ABCと表示される)
		;
		; マシン語で文字列(半角、全角文字)を表示する。
		; =======================================================
		if STRING_FLAG = 1

STRING_PRINT:	LDR
		STQ
		LP    X_Reg
		MVB			; X = (R,R+1)
		DX			; X = 文字列アドレス - 1
		CALL  MOJI_START
		IX
		LDR
		STP
		LIQ   X_Reg
		MVB			; PC = 文字列の終端 + 1
		RTN

		endif



		; =======================================================
		; [おまけ]カーソル設定(API)
		;
		; 書式 78(CURSOR)(X座標)(Y座標)
		; 例） 78FA400503 (CURSOR 5,3)
		;
		; マシン語でカーソル座標の指定をする。エラーチェックは行
		; っていない。
		; =======================================================
		if CURSOR_FLAG = 1

CURSOR_START:	LDR
		STQ
		LP    X_Reg
		MVB			; X = (R,R+1)
		DX			; X = X座標パラメータアドレス - 1
		IXL
		LIDP  CSRX
		STD			; (CSRX) = X座標
		IXL
		LIDP  CSRY
		STD			; (CSRY) = Y座標
		IX
		LDR
		STP
		LIQ   X_Reg
		MVB			; PC = パラメータ + 1
		RTN

		endif



		; =======================================================
		; [おまけ]拡張PRINT命令(BASIC)
		;
		; 書式 CALL PRINT_START,データ[;データ...]
		;      データ1) "文字列"
		;      データ2) ASCIIコード(20～DF)
		;      データ3) JISコード(2121～)
		;      データ4) シフトJISコード(8440～)
		; 例） CALL &xxxx, "ABCｶﾝｼﾞ";33;65;&3021;&8250
		;
		; BASICで文字列を表示する。文字コードを指定すれば漢字も表
		; 示可能。データ1)は文字列式を指定し、数値は指定できない
		; ので、必要ならばSTR$で文字列化すること。なお末尾で改行
		; は行わない。末尾セミコロンは不要。
		; =======================================================
		if PRINT_FLAG = 1

PRINT_START:	IXL
		CPIA  ','
		JRZP  PRINT_JMP3
PRINT_JMP1:	LIA   1			; ERROR1
		SC
PRINT_JMP2:	POP
		POP
		RTN
PRINT_JMP3:	CAL   CULC		; 式評価
		JRCM  PRINT_JMP1	; エラーならば
		CAL   PUSHX		; X保存
		CAL   Check
		JRCP  PRINT_JMP4	; 文字列ならば
		LP    $17		;     文字列長
		LDM
		ADIA  STR_BUF & $FF
		LIDP  PRINT_STR + 2	;     文字列の末尾(自己書き換え)
		STD
PRINT_STR:	LIDP  STR_BUF
		ANID  0			;     文字列の末尾+1に 0を書き込む
		LIB   STR_BUF >> 8
		LIA   STR_BUF & $FF
		CAL   TOXM		;     X = 6E60 - 1
		CALL  MOJI_START	;     文字列表示
		JRP   PRINT_JMP6
PRINT_JMP4:				; 数値ならば
		CAL   DTOH		;     (18,19) = RA
		LP    $19
		CPIM  $00
		JRNZP PRINT_JMP5	;     半角文字ならば
		LP    $18
		LDM			;         A = (18) 文字コード
		CALL  CHAR		;         1文字表示
		JRP   PRINT_JMP6
PRINT_JMP5:	LP    A_Reg		;     全角文字のとき
		LIQ   $18
		MVB			;         AB = (18,19) 全角文字コード
		EXAB
		CALL  KANJI_CHAR	;         全角1文字表示
PRINT_JMP6:	CAL   POPX		; X復帰
		IXL
		CPIA  ';'
		JRZM  PRINT_JMP3	; 継続
		DX
		RC
		JRM   PRINT_JMP2	; 正常終了

		endif
