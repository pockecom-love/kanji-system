		; +===================================+
		; |  PC-1350/60/60K 漢字表示システム  |
		; |  25桁4行, 30桁4行, 37桁4行        |
		; |  漢字フォント7x7dot, 11x7dot      |
		; |  半角フォント4x7dot, 5x7dot       |
		; +===================================+

		; =======================================================
		; 設定
		; =======================================================
TARGET		equ   1360	; PC-1350は 1350、PC-1360/60Kは 1360 を指定
KANJI		equ   11		; 漢字フォントのドット数(7 or 11)を指定
COLUMN		equ   25	; 桁数(25 or 30 or 37)を指定
				;  (11ドット漢字フォントの場合は25のみ指定可)
TOOL		equ   1		; 表示ツールを選択
				;  (1…全角順次表示、2…テキスト表示
				;   3…テキストビューワ、4…ベンチマークテスト)
FONT		equ   1		; フォント読み込み…1
TEXT		equ   1		; テキストデータ読み込み…1
NOSCROLLUP	equ   0		; [TOOL1]スクロールアップなし…1
KEYSTOP		equ   0		; [TOOL1,2]キーストップする…1
CRMARK		equ   1		; [TOOL3]改行マークを表示する…1
EXPRINT		equ   0		; 拡張PRINT文(1…有効、0…無効) ※ PC-1350専用
STRING_FLAG	equ   0		; 文字列表示(マシン語)(1…有効、0…無効)

		if TARGET = 1350
LOAD_ADR		equ   $2100	; オブジェクトロードアドレス
TOOL_ADR		equ   $6A00	; ツール先頭アドレス
LINENUMBER_BUF		equ   $6D00	; [TOOL3]行番号ポインタバッファ
LINE_MAX		equ   255	; [TOOL3]最大行番号
		else
LOAD_ADR		equ   $8080
TOOL_ADR		equ   $F780
LINENUMBER_BUF		equ   $FB00
LINE_MAX		equ   255
		endif



		; =======================================================
		; ラベル定義ファイル、漢字フォントファイル、半角フォント
		; ファイル読み込み、対応漢字コードの末尾定義
		; =======================================================
		nolist
		if TARGET = 1350
			include(SYMBOL1350.asm)

			if FONT = 1
				org   LOAD_ADR
			endif

			if FONT = 1
				include(4x7dot_font.asm)
			else
ASCII4_FONT			equ   LOAD_ADR
			endif

			if KANJI = 7
				if FONT = 1
					include(kanji7_font_1350.asm)
				else
KANJI_FONT				equ   LOAD_ADR + $0280
				endif
END_CODE			equ   $457F		; 全角フォント最終JISコード + 1
			else
				if FONT = 1
					include(kanji11_font_1350.asm)
				else
KANJI_FONT				equ   LOAD_ADR + $0280
				endif
END_CODE			equ   $3B60		; 全角フォント最終JISコード + 1
			endif
		endif

		if TARGET = 1360
			include(SYMBOL1360.asm)

			if FONT = 1
				org   LOAD_ADR
			endif

			if FONT = 1
				include(4x7dot_font.asm)
			else
ASCII4_FONT			equ   LOAD_ADR
			endif

			if KANJI = 7
				if FONT = 1
					include(kanji7_font_1360.asm)
				else
KANJI_FONT				equ   LOAD_ADR + $0280
				endif
END_CODE			equ   $4F54		; 全角フォント最終JISコード + 1
			else
				if FONT = 1
					include(kanji11_font_1360.asm)
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
		; ツール先頭アドレス
		; =======================================================
		org   TOOL_ADR


		; =======================================================
		; [TOOL1]全角順次表示
		;
		; JISコード 21～25区、30～44区まで順次表示する
		; ↓キーで1行ずつ順次表示
		; Mode or Breakキーで終了
		;
		; ワーク (31,32) 表示JISコード
		; =======================================================
		if TOOL = 1

		CALL  CLS_START		; 画面クリア
		LIA   $21		; 初期JISコード設定
		LP    $30
		EXAM
		LIA   $21
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
JIS_LINE:	LIA   COLUMN / 2 - 1
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
			JRCP  JISPRT_JMP1
			ANID  0			;         X座標 = 0
			LIDL  CSRY & $FF
			ANID  0			;         Y座標 = 0
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

TEXT_VIEWER:	CALL  CLS_START		; 画面クリア
		CALL  TIMER_RESET	; オートパワーオフタイマーリセット
		LII   LINE_MAX - 1
		LIDP  LINENUMBER_BUF	; 行番号バッファクリア
		FILD

		LIA   3			; 初期4行表示
		PUSH
		LIB   (TEXT_DATA - 1) >> 8
		LIA   (TEXT_DATA - 1) & $FF
		CAL   TOX		; X = テキストデータ - 1
		LP    $32		; キーリピートフラグON
		LIA   1			; 起動時のEnterキーをキャンセルするため
		EXAM
		LP    $35		; 表示行番号 = 0
		ANIM  0
		CLRA
		CALL  LINE_REGISTER	; 0行目登録

TEXT_LOOP1:	CALL  LINE_PRINT
		JRNCP TEXT_JMP1		; C=1なら
		POP			;     ループ脱出
		JRP   TEXT_JMP3
TEXT_JMP1:	LP    $35
		ADIM  1
		LDM
		CALL  LINE_REGISTER	; 次の行番号登録
		LOOP  TEXT_LOOP1

TEXT_JMP3:	LP    $35
		ANIM  0			; 初期表示行番号
TEXT_JMP2:	CALL  KEY_REPEAT
		CPIA  Key_CLS		; CLSキーで終了
		JRZP  TEXT_END
		CPIA  Key_UP		; ↑キー
		JRZP  TEXT_UP
		CPIA  Key_DOWN		; ↓キー
		JRZP  TEXT_DOWN
		CPIA  Key_ENTER		; Enterキーは
		JRZP  TEXT_DOWN		;   ↓キーと同じ
		JRM   TEXT_JMP2

TEXT_DOWN:	LP    $35		; ↓キー処理
		LDM
		CPIA  LINE_MAX
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
		JRCP  TEXT_JMP4		; データ終端ならば
		LP    $35
		LDM
		ADIA  5
		CALL  LINE_REGISTER	; 次の行番号登録
TEXT_JMP4:	LP    $35
		ADIM  1			; 表示行番号 + 1
		JRM   TEXT_JMP2

TEXT_UP:	LP    $35		; ↑キー処理
		LDM
		CPIA  0
		JRZM  TEXT_JMP2		; 0行目ならスキップ
		SBIM  1			; 表示行番号 - 1
		CALL  SCROLL_DOWN	; スクロールダウン
		LP    $35
		LDM
		CALL  LINE_SEARCH	; X = A行番号のアドレス - 1
		CALL  LINE_PRINT
		JRM   TEXT_JMP2
TEXT_END:	RTN



		; =======================================================
		; 1行表示
		;
		; 入力 X = テキストデータ - 1
		; ワーク (38,39) X保存
		; =======================================================
LINE_PRINT:	LIDP  CSRY
		LDD
		CPIA  4
		JRCP  LPRINT_x
		CALL  CARRIAGE_RETURN
LPRINT_x:	IXL
		CPIA  0			; 0なら終端
		JRNZP LPRINT_JMP1
		SC			;     C = 1
		RTN			;     リターン
LPRINT_JMP1:	CPIA  $0D		; 0Dは単にスキップ
		JRZM  LPRINT_x
LPRINT_JMP2:	CPIA  $0A		; 改行コードなら
		JRNZP LPRINT_JMP7

		if CRMARK = 1
			LIA   $7F		;     改行マーク
			CAL   XTO38		;     (38,39) = X
			CALL  CHAR		;     半角1文字表示
			CAL   R38TOX		;     X = (38,39)
		endif

		LIDP  CSRX
		ANID  0			;     X座標 = 0
		LIDL  CSRY & $FF
		LDD
		INCA			;     Y座標 + 1
		STD
		RTN			;     リターン
LPRINT_JMP7:	CPIA  $81		; 81以上ならば
		JRCP  LPRINT_JMP3
		CPIA  $9F		; 9F以下ならば
		JRCP  LPRINT_JMP4
					; === 半角 ===
LPRINT_JMP3:	CAL   XTO38		; (38,39) = X
		CALL  CHAR		; 半角1文字表示
		CAL   R38TOX		; X = (38,39)
		LIDP  CSRX
		LDD
		CPIA  COLUMN
		JRCM  LINE_PRINT	; 右端まで表示したら
		RTN			;     リターン

LPRINT_JMP4:	EXAB			; === 全角 ===
		IXL			; 2バイト目読み込み
		EXAB			; A=第1バイト,B=第2バイト
		CAL   XTO38		; (38,39) = X
		CALL  KANJI_CHAR	; 全角1文字表示
		CAL   R38TOX		; X = (38,39)
LPRINT_JMP5:	LIDP  CSRX
		LDD
		CPIA  COLUMN - 1
		JRCM  LINE_PRINT	; 右端-1まで表示したら
		RTN



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
		ADB			; Y = Y + BA * 2
		LP    Y_Reg
		ADB
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
		ADB
		LP    X_Reg
		ADB			; X = X + BA * 2
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

BENCHMARK_TEST:	CALL  CLS_START		; 画面クリア
		LIDP  CSRX		; X座標 = 0
		ANID  0
		LIDL  CSRY & $FF	; Y座標 = 0
		ANID  0
		LIA   99		; 100回ループ
		PUSH
BENCH_LOOP1:	LIB   BENCH_STR >> 8
		LIA   BENCH_STR & $FF
		CAL   TOXM
		CALL  MOJI_START
		LOOP  BENCH_LOOP1
		RTN
BENCH_STR:	db    "**PC-1350/PC-1360K**", 0

		endif



;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;■ 　以下は漢字システム本体、文字列表示CALL文、拡張PRINT文　　■
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

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
				;CAL   PRINT1		; DXL,IYS 5回実行
				DXL
				IYS
				DXL
				IYS
				DXL
				IYS
				DXL
				IYS
				DXL
				IYS
			else
				LIDP  BANK_SELECT
				LDD
				PUSH			; 現在のBANK保存
				LIA   1			; BANK1選択
				STD
				;LIB   5
				;CAL   BLOCK		; IXL,IYS 5回実行
				IXL
				IYS
				IXL
				IYS
				IXL
				IYS
				IXL
				IYS
				IXL
				IYS
				POP
				LIDP  BANK_SELECT
				STD			; BANK復帰
				CLRA			; 6ドット目
				IYS
			endif
		endif

		if COLUMN = 30
			CALL  VRAM1_ADR
			;LIB   4
			;CAL   BLOCK		; IXL,IYS 4回実行
			IXL
			IYS
			IXL
			IYS
			IXL
			IYS
			IXL
			IYS
			CLRA			; 5ドット目
			IYS
		endif

		if COLUMN = 37
			LIA   3			; 4回ループ
			PUSH
			CALL  CSR2GCSR		; 座標→グラフィック座標
			LP    N_Reg
			ANIM  $00		; N = 0
			CALL  VRAM2_ADR		; VRAMアドレス算出
CHAR_LOOP1:		IXL
			IYS
			INCK			; X座標+1
			DECN
			JRNZP CHAR_JMP4		; VRAM境界判定
			CALL  VRAM2_ADR		;     VRAM再計算
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
			;CAL   TOX
			LP    X_Reg
			LIQ   A_Reg
			MVB
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
KANJI_JMP2:	;CAL   TOX		; X = AB
		LP    X_Reg
		LIQ   A_Reg
		MVB
		EXAB
		;CAL   TOY		; Y = AB
		LP    Y_Reg
		LIQ   A_Reg
		MVB
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
		CPIA  COLUMN - 1	; X座標 >= 29ならば
		JRCP  KANJI_JMP5
		CALL  CARRIAGE_RETURN	;     改行する
KANJI_JMP5:
		if COLUMN <> 37			; 25,30桁の場合
			CALL  VRAM1_ADR		; 左半分
			if COLUMN = 25
				;LIB   6		; 漢字7ドットフォントの場合
				IXL
				IYS
				IXL
				IYS
				IXL
				IYS
				IXL
				IYS
				IXL
				IYS
				IXL
				IYS
			else
				;LIB   5		; 漢字11ドットフォントの場合
				IXL
				IYS
				IXL
				IYS
				IXL
				IYS
				IXL
				IYS
				IXL
				IYS
			endif
			;CAL   BLOCK		; IXL,IYSを5or6回
			CALL  CURSOR_UPDATE	; カーソル右移動(全角左半分)
			CALL  VRAM1_ADR		; 右半分
			if KANJI = 7
				if COLUMN = 25
					IXL	; 漢字7ドットフォント、25桁の場合
					IYS
					CLRA	; 8ドット目以降
					IY	; 空白出力
					LII   4
					FILD
				else
					IXL	; 漢字7ドットフォント、30桁の場合
					IYS
					IXL
					IYS
					CLRA	; 8ドット目以降
					IYS	; 空白出力
					IYS
					IYS
				endif
			else
				;LIB   5		; 漢字11ドットフォントの場合
				;CAL   BLOCK	; IXL,IYSを5回
				IXL
				IYS
				IXL
				IYS
				IXL
				IYS
				IXL
				IYS
				IXL
				IYS
				CLRA		; 12ドット目
				IYS
			endif
		else				; 37桁の場合
			LIA   6			; 7回ループ
			PUSH
			CALL  CSR2GCSR		; 座標→グラフィック座標
			CALL  VRAM2_ADR		; VRAMアドレス算出
KANJI_LOOP1:		IXL
			IYS
			INCK			; X座標+1
			DECN
			JRNZP KANJI_JMP6	; VRAM境界判定
			CALL  VRAM2_ADR		;     VRAMアドレス再計算
KANJI_JMP6:		LOOP  KANJI_LOOP1
			CLRA			; 8ドット目
			IYS
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
		; 入力 A = JISコード第1バイト
		; 　　 B =         第2バイト
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
		CAL   TOX		; X = BA;
		LP    X_Reg
		LIQ   A_Reg
		MVB
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
		LP    A_Reg
		ADB			; BA = BA + BA (8倍)
		LP    X_Reg
		LIQ   A_Reg
		EXB			; X <> BA

		if KANJI = 7		; 7dotフォントの場合
			LP    X_Reg
			SBB			; X = X - BA (7倍)
		else			; 11dotフォントの場合
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
VRAM1_LOOP1:	SBIA  COLUMN / 5	; 桁数/5を引けるだけ引く
		JRCP  VRAM1_JMP1
		LP    B_Reg
		ADIM  $02		; 桁数/5で割った商の分だけ$200加算
		JRM   VRAM1_LOOP1
VRAM1_JMP1:	ADIA  COLUMN / 5	; 引きすぎた分を加算

		if COLUMN = 25		; Aを6倍
			RC
			SL
			PUSH		; 2倍を保存
			SL
			LP    Y_Reg
			EXAM		; 4倍をYLに
			POP
			ADM		; 2倍+4倍
			LDM
		else			; Aを5倍
			PUSH
			LP    Y_Reg
			EXAM
			POP
			RC
			SL
			SL		; 4倍
			ADM		; 1倍+4倍
			LDM
		endif

		;CAL   TOY		; Y = BA
		LP    Y_Reg
		LIQ   A_Reg
		MVB
		LIDP  CSRY
		LDD			; A = Y座標
		LP    Y_Reg
		TSIA  $01
		JRZP  VRAM1_JMP2		; 偶数なら
		ADIM  $40		; 	$40加算
VRAM1_JMP2:	CPIA  2
		JRCP  VRAM1_JMP3		; 1以上なら
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
		LP    $08
		LDM
VRAM2_LOOP1:	SBIA  30		; 30を引けるだけ引く
		JRCP  VRAM2_JMP1
		LP    B_Reg
		ADIM  $02		; 30で割った商の分だけ$200加算
		JRM   VRAM2_LOOP1
VRAM2_JMP1:	ADIA  30		; 引きすぎた分を加算
		PUSH
		;CAL   TOY		; Y = BA
		LP    Y_Reg
		LIQ   A_Reg
		MVB
		LP    $09
		LDM
		LP    Y_Reg
		TSIA  $01
		JRZP  VRAM2_JMP2	; Y座標が0or2なら
		ORIM  $40		; 	$40加算
VRAM2_JMP2:	CPIA  2
		JRCP  VRAM2_JMP3	; Y座標が2or3なら
		ADIM  $1E		; 	$1E加算
VRAM2_JMP3:	DY			; Y = Y - 1
		POP
		LP    N_Reg
		ANIM  0
		ORIM  30
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
KEY_REPEAT:	CALL  INKEY_WAIT
		LP    $32
		TSIM  $01		; リピート判定中(1)ならば
		JRNZP KEY_JMP2		;     リピート判定へ
		TSIM  $FF		; リピートOFF(0)ならば
		JRNZP KEY_JMP1
		ORIM  $01		;    リピート判定中(1)に
KEY_JMP1:	RTN			; リピート中(2)ならリターン

KEY_JMP2:				; リピート判定
		CPIA  Key_ENTER		; リピート除外キー
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
		;       (33,34) オートパワーオフタイマー
		; =======================================================
INKEY_WAIT:	CAL   INKEY
		CAL   T6WAIT		; 6ms待ち
		JRNCP INKEY_JMP1	; キー入力あり
		CALL  TIMER_RESET	;     オートパワーオフタイマーリセット
		RTN
INKEY_JMP1:	LP    $32		; キー入力なしならば
		ANIM  $00		;     リピートOFF(0)
		LP    $34
		ADIM  1			;     オートパワーオフタイマー(L) + 1
		JRNCM INKEY_WAIT
		LP    $33
		ADIM  1			;     オートパワーオフタイマー(H) + 1
		CPIM  120
		JRCM  INKEY_WAIT	; 120*2.5s=300秒でオートパワーオフ
		CALL  TIMER_RESET	;     オートパワーオフタイマーリセット
		LIA   $0C
		CAL   OUTC		; パワーオフ
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
		; 全画面クリア（CLS）
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

CSR_CLEAR:	CLRA			; カーソル座標クリア
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
MOJI_START:	IXL
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
		IXL
		EXAB			; A=第1バイト,B=第2バイト
		CAL   XTO38		; (38,39) = X
		CALL  KANJI_CHAR	; 全角1文字表示
MOJI_JMP3:	CAL   R38TOX		; X = (38,39)
		JRM   MOJI_START
MOJI_END:	RTN



		; =======================================================
		; 文字列表示(マシン語)
		;
		; 書式 78(STRING_PRINT)文字列コード...00
		; 例） 78FA2841424300 (ABCと表示される)
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
		; 拡張PRINT命令(BASIC)
		;
		; 書式 CALL PRINT_START,データ[;データ...]
		;      データ(1) "文字列"
		;      データ(2) ASCIIコード(20～DF)
		;      データ(3) JISコード(2121～)
		;      データ(4) シフトJISコード(8440～)
		; 例） CALL &xxxx, "ABCｶﾝｼﾞ";33;65;&3021;&8250
		; ※ 末尾で改行しない、末尾セミコロン不可
		; =======================================================
		if EXPRINT = 1

PRINT_START:	IXL
		CPIA  ','
		JRZP  PRINT_JMP3
PRINT_JMP1:	LIA   1
		SC
PRINT_JMP2:	POP
		POP
		RTN			; ERROR1
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
