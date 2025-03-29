		; +============================================+
		; |  PC-1350/60/60K �����\���V�X�e��           |
		; |                       by �������񁗂���    |
		; |                          (@pockecom_love)  |
		; |                                            |
		; |  �\�����[�h�F25��4�s, 30��4�s, 37��4�s     |
		; |  �����t�H���g�F5x7dot, 7x7dot, 11x7dot     |
		; |  ���p�t�H���g�F4x7dot, 5x7dot              |
		; |                                            |
		; |  [�ӎ�]                                    |
		; |  �T�C�g Little Limit �Ō��J����Ă�����{  |
		; |  ��t�H���g�𗘗p�����Ă��������܂����B    |
		; |  https://littlelimit.net/font.htm          |
		; +============================================+

		; =======================================================
		; �ݒ�
		; =======================================================
TARGET		equ   1360	; PC-1350�� 1350�APC-1360/60K�� 1360 ���w��
KANJI		equ   7		; �����t�H���g�̉��h�b�g��(5 or 7 or 11)���w��
COLUMN		equ   37	; ����(25 or 30 or 37)���w��
				;  (11�h�b�g�����t�H���g�g�p����37�w��s��)
FONT		equ   1		; �t�H���g�ǂݍ��݁c1
TEXT		equ   1		; �e�L�X�g�f�[�^�ǂݍ��݁c1

				; --- �c�[���̐ݒ� ---
TOOL		equ   3		; �����c�[���̑I��
				;  (1�c�S�p�����\���A2�c�e�L�X�g�\��
				;   3�c�e�L�X�g�r���[�A�A4�c�x���`�}�[�N�e�X�g)
NOSCROLLUP	equ   0		; [TOOL1]�X�N���[���A�b�v�Ȃ��c1
KEYSTOP		equ   0		; [TOOL1,2]�L�[�X�g�b�v����c1
KEYSCAN		equ   1		; [TOOL1,2,3]�L�[���̓��[�`��(1�c�L��)
CRMARK		equ   1		; [TOOL3]���s�}�[�N(1�c�\��)

				; --- ���܂� ---
STRING_FLAG	equ   0		; ������\��(API)(1�c�L��)
CURSOR_FLAG	equ   0		; �J�[�\���ݒ�(API)(1�c�L��)
PRINT_FLAG	equ   0		; �g��PRINT��(1�c�L��) �� PC-1350��p

		if TARGET = 1350
LOAD_ADR		equ   $2040	; �I�u�W�F�N�g���[�h�A�h���X
TOOL_ADR		equ   $6960	; �c�[���擪�A�h���X
LINENUMBER_BUF		equ   $6D00	; [TOOL3]�s�ԍ��|�C���^�o�b�t�@
LINE_MAX		equ   127	; [TOOL3]�ő�s�ԍ�(4�`255)
		else
LOAD_ADR		equ   $8040
TOOL_ADR		equ   $F600
LINENUMBER_BUF		equ   $FB00
LINE_MAX		equ   255
		endif



		; =======================================================
		; ���x����`�t�@�C���A�t�H���g�t�@�C���ǂݍ���
		; �Ή������R�[�h�̖�����`
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
END_CODE			equ   $4F54		; �S�p�t�H���g�ŏIJIS�R�[�h + 1
			endif
			if KANJI = 7
				if FONT = 1
					include(kanji7_font_1350.s)
				else
KANJI_FONT				equ   LOAD_ADR + $0280
				endif
END_CODE			equ   $454A		; �S�p�t�H���g�ŏIJIS�R�[�h + 1
			endif
			if KANJI = 11
				if FONT = 1
					include(kanji11_font_1350.s)
				else
KANJI_FONT				equ   LOAD_ADR + $0280
				endif
END_CODE			equ   $3B60		; �S�p�t�H���g�ŏIJIS�R�[�h + 1
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
END_CODE			equ   $4F54		; �S�p�t�H���g�ŏIJIS�R�[�h + 1
			endif
			if KANJI = 7
				if FONT = 1
					include(kanji7_font_1360.s)
				else
KANJI_FONT				equ   LOAD_ADR + $0280
				endif
END_CODE			equ   $4F54		; �S�p�t�H���g�ŏIJIS�R�[�h + 1
			endif
			if KANJI = 11
				if FONT = 1
					include(kanji11_font_1360.s)
				else
KANJI_FONT				equ   LOAD_ADR + $0280
				endif
END_CODE			equ   $457F		; �S�p�t�H���g�ŏIJIS�R�[�h + 1
			endif
		endif
		list



		; =======================================================
		; �e�L�X�g�f�[�^
		;
		; �V�t�gJIS�R�[�h�̃o�C�i���f�[�^��z�u����
		; �I�[�� 00
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
		; �c�[��(1�`4)�擪�A�h���X
		; =======================================================
		org   TOOL_ADR


		; =======================================================
		; [TOOL1]�S�p�����\��
		;
		; JIS�R�[�h 21�`25��A30�`44��܂ŏ����\������
		; KEYSTOP = 1�̏ꍇ�A���L�[��1�s�������\��
		; Mode or Break�L�[�ŏI��
		;
		; ���[�N (31,32) �\��JIS�R�[�h
		; =======================================================
		if TOOL = 1

		CALL  CLS_START		; ��ʃN���A
		LIA   $21		; ����JIS�R�[�h�ݒ�
		LP    $30
		EXAM
		LDM
		LP    $31
		EXAM

		if KEYSTOP = 1
			LP    $32		; �L�[���s�[�g�t���OON
			LIA   1			; �N������Enter�L�[���L�����Z�����邽��
			EXAM
		endif

		LIA   3
		PUSH
ALL_LOOP1:	CALL  JIS_LINE		; 4�s���\��
		LOOP  ALL_LOOP1

ALL_LOOP2:
		if KEYSTOP = 1
			CALL  KEY_REPEAT	; �L�[����(�L�[���s�[�g�t��)
			CPIA  Key_CLS		; CLS�L�[
			JRZP  ALL_JMP2		;     �I��
			CPIA  Key_DOWN		; ���L�[
			JRZP  ALL_JMP1
			CPIA  Key_ENTER		; Enter�L�[
			JRZP  ALL_JMP1
			JRM   ALL_LOOP2
		endif

ALL_JMP1:	CALL  JIS_LINE		; 1�s�\��
		JRNCM ALL_LOOP2		; C=0�Ȃ�΃��[�v
ALL_JMP2:	RTN



		; =======================================================
		; JIS�R�[�h����1�s�\��
		;
		; ���� (30,31) = JIS�R�[�h
		; =======================================================
JIS_LINE:
		if KANJI = 5		; ����5�h�b�g�t�H���g�̏ꍇ
			LIA   COLUMN - 1
		else			; ����7or11�h�b�g�t�H���g�̏ꍇ
			LIA   COLUMN / 2 - 1
		endif
		PUSH			; 1�s�����[�v
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
		; JIS�R�[�h����1�����\��
		;
		; ���� AB = JIS�R�[�h
		; =======================================================
JIS_PRINT:	PUSH			; A�ۑ�
		EXAB
		PUSH			; B�ۑ�
		EXAB
		CALL  KANJI_CHAR

		if NOSCROLLUP = 1		; �X�N���[���A�b�v���Ȃ�
			LIDP  CSRY		; Y���W = 3
			LDD
			CPIA  3
			JRNZP JISPRT_JMP1
			LIDL  CSRX & $FF	;     X���W < COLUMN - 1
			LDD
			CPIA  COLUMN - 1
			JRCP  JISPRT_JMP1	; �E���܂ŏo�͂�����
			CALL  CSR_CLEAR		;     �J�[�\�����W�N���A
		endif

JISPRT_JMP1:	POP			; B���A
		EXAB
		POP			; A���A
		INCB			; B = B + 1
		LP    B_Reg
		CPIM  $7F		; B��7F�����Ȃ烊�^�[��
		JRCP  JISPRT_JMP3
		ANIM  0
		ORIM  $21		; B = 21
		INCA			; A = A + 1
		CPIA  $26		; A = 26 �Ȃ��
		JRNZP JISPRT_JMP2
		ADIA  10		;     A = A + 10 (26�`2F��̓X�L�b�v)
JISPRT_JMP2:	CPIA  $46		; 46�ɂȂ�����
		JRCP  JISPRT_JMP3
		SC			;     C = 1
		RTN
JISPRT_JMP3:	RC			;     C = 0
		RTN

		endif



		; =======================================================
		; [TOOL2]�e�L�X�gTYPE�\��
		;
		; TEXT_DATA = �e�L�X�g�f�[�^(�I�[0)
		; =======================================================
		if TOOL = 2

		CALL  CLS_START		; ��ʃN���A
		LIB   (TEXT_DATA - 1) >> 8
		LIA   (TEXT_DATA - 1) & $FF
		CAL   TOX		; X = �e�L�X�g�f�[�^ - 1
		CALL  MOJI_START
		RTN

		endif



		; =======================================================
		; [TOOL3]�e�L�X�g�r���[�A
		;
		; TEXT_DATA = �e�L�X�g�f�[�^(�I�[0)
		; ���[�N (35) �\���s�ԍ�(1�s�ڂ̍s�ԍ�)
		; =======================================================
		if TOOL = 3

TEXT_VIEWER:	CALL  TIMER_RESET	; �I�[�g�p���[�I�t�^�C�}�[���Z�b�g
		LII   9
		CLRA
		LIDP  LINENUMBER_BUF
		FILD			; 5�s���̍s�ԍ��o�b�t�@�N���A
		CALL  TEXT_INIT		; ����4�s�\��
		LP    $35
		ANIM  0			; �����\���s�ԍ�

		; ----------------------- ���C�����[�v -----------------------
TEXT_JMP2:	CALL  KEY_REPEAT
		CPIA  Key_CLS		; CLS�L�[�ŏI��
		JRZP  TEXT_END
		CPIA  Key_UP		; ���L�[
		JRZP  TEXT_UP
		CPIA  Key_DOWN		; ���L�[
		JRZP  TEXT_DOWN
		CPIA  Key_ENTER		; ENTER�L�[��
		JRZP  TEXT_DOWN		;   ���L�[�Ɠ���
		CPIA  Key_SHIFT		; SHIFT�L�[
		JRZP  TEXT_SHIFT
		JRM   TEXT_JMP2

		; ----------------------- ���L�[���� -----------------------
TEXT_DOWN:	LP    $35
		LDM
		CPIA  LINE_MAX - 4
		JRNCM TEXT_JMP2		; �ő�s�ԍ��Ȃ�X�L�b�v
		ADIA  4
		CALL  LINE_SEARCH	; �\���s�ԍ� + 4 �̍s�ԍ��T�[�`
		JRCM  TEXT_JMP2		; C=1(�t�@�C���I�[)�Ȃ��

		LIDP  CSRX
		ANID  0			; X���W = 0
		LIDL  CSRY & $FF
		LIA   4
		STD			; Y���W = 4

		CALL  LINE_PRINT
		JRNCP TEXT_JMP4		; �f�[�^�I�[�łȂ����
		LP    X_Reg		;     X = $0000
		ANIM  0
		LP    X_Reg + 1
		ANIM  0
TEXT_JMP4:	LP    $35
		LDM
		ADIA  5
		CALL  LINE_REGISTER	; ���̍s�ԍ��o�^
		LP    $35
		ADIM  1			; �\���s�ԍ� + 1
		JRM   TEXT_JMP2

		; ----------------------- ���L�[���� -----------------------
TEXT_UP:	LIDP  INDICATOR_ADR
		TSID  $01		; SHIFT���[�h��
		JRNZP TEXT_SUP		;     SHIFT+���L�[������
		LP    $35
		CPIM  0
		JRZM  TEXT_JMP2		; 0�s�ڂȂ�X�L�b�v
		SBIM  1			; �\���s�ԍ� - 1
		CALL  SCROLL_DOWN	; �X�N���[���_�E��
		LP    $35
		LDM
		CALL  LINE_SEARCH	; X = A�s�ԍ��̃A�h���X - 1
		CALL  LINE_PRINT
		JRM   TEXT_JMP2

		; ------------------- SHIFT + ���L�[���� -------------------
TEXT_SUP:	CALL  TEXT_INIT
		LIDP  INDICATOR_ADR
		ANID  $FE		; SHIFT�C���W�P�[�^����
		LP    $35
		ANIM  0			; �����\���s�ԍ�
		JRM   TEXT_JMP2

		; --------------------- SHIFT�L�[���� ---------------------
TEXT_SHIFT:	LIDP  INDICATOR_ADR
		TSID  $01
		JRZP  TEXT_JMP6
		ANID  $FE		; SHIFT�C���W�P�[�^����
		JRM   TEXT_JMP2
TEXT_JMP6:	ORID  $01		; SHIFT�C���W�P�[�^�_��
		JRM   TEXT_JMP2

		; ----------------------- CLS�L�[���� -----------------------
TEXT_END:	LIDP  INDICATOR_ADR
		ANID  $FE		; SHIFT�C���W�P�[�^����
		RTN

		; ----------------------- ����4�s�\�� -----------------------
TEXT_INIT:	CALL  CLS_START		; ��ʃN���A
		LIB   (TEXT_DATA - 1) >> 8
		LIA   (TEXT_DATA - 1) & $FF
		CAL   TOX		; X = �e�L�X�g�f�[�^ - 1
		LP    $32		; �L�[���s�[�g�t���OON
		LIA   1			; �N������Enter�L�[���L�����Z�����邽��
		EXAM
		CLRA
		CALL  LINE_REGISTER	; 0�s�ړo�^
		LP    $35		; �\���s�ԍ� = 0
		ANIM  0
		LIA   3
		PUSH
TEXT_LOOP1:	CALL  LINE_PRINT
		JRNCP TEXT_JMP1		; C=1(�f�[�^�I�[)�Ȃ�
		POP			;     ���[�v�E�o
		RTN
TEXT_JMP1:	LP    $35
		ADIM  1
		LDM
		CALL  LINE_REGISTER	; ���̍s�ԍ��o�^
		LOOP  TEXT_LOOP1
		RTN

		; ----------------------- 1�s�\�� -----------------------
LINE_PRINT:	LIDP  CSRY
		LDD
		CPIA  4
		JRCP  LPRINT_JMP1
		CALL  CARRIAGE_RETURN
LPRINT_JMP1:	IXL			; �f�[�^�ǂݍ���
		CPIA  0			; 0�Ȃ�I�[
		JRNZP LPRINT_JMP2
		SC			;     C = 1
		RTN			;     ���^�[��
LPRINT_JMP2:	CPIA  $0D		; 0D�͒P�ɃX�L�b�v
		JRZM  LPRINT_JMP1
		CPIA  $0A		; ���s�R�[�h�Ȃ�
		JRNZP LPRINT_JMP4

		if CRMARK = 1		; ���s�}�[�N��\������Ȃ��
			LIA   $7F	;     ���s�}�[�N�R�[�h
			CAL   XTO38	;     (38,39) = X
			CALL  CHAR	;     ���p1�����\��
			CAL   R38TOX	;     X = (38,39)
		endif
LPRINT_JMP3:	LIDP  CSRX
		ANID  0			;     X���W = 0
		LIDL  CSRY & $FF
		LDD
		INCA			;     Y���W + 1
		STD
		RTN			;     ���^�[��

		; ----------------------- �S�p���� -----------------------
LPRINT_JMP4:	CPIA  $81		; 81�ȏ�Ȃ��
		JRCP  LPRINT_JMP5
		CPIA  $9F		; 9F�ȉ��Ȃ��
		JRCP  LPRINT_JMP6

		; ----------------------- ���p���� -----------------------
LPRINT_JMP5:	CAL   XTO38		; (38,39) = X
		CALL  CHAR		; ���p1�����\��
LRPINT_JMP8:	CAL   R38TOX		; X = (38,39)
		LIDP  CSRX
		LDD
		CPIA  COLUMN
		JRNCM LPRINT_JMP3	; �E�[�܂ŕ\��������
		JRM   LINE_PRINT

		; ----------------------- �S�p���� -----------------------
LPRINT_JMP6:	EXAB
		LIDP  CSRX
		LDD
		if (KANJI = 5) & (COLUMN = 25)	; ����5�h�b�g�t�H���g�̏ꍇ
			CPIA  COLUMN 		; X���W���E�[�Ȃ��
		else				; ����7or11�h�b�g�t�H���g�̏ꍇ
			CPIA  COLUMN - 1	; �S�p�E��������ʂ���͂ݏo��ꍇ
		endif
		JRCP  LPRINT_JMP7
		DX				;     1�o�C�g�߂�
		JRM   LPRINT_JMP3		;     ���s���ă��^�[��
LPRINT_JMP7:	IXL			; 2�o�C�g�ړǂݍ���
		EXAB			; A=��1�o�C�g,B=��2�o�C�g
		CAL   XTO38		; (38,39) = X
		CALL  KANJI_CHAR	; �S�p1�����\��
		JRM   LRPINT_JMP8



		; =======================================================
		; �s�ԍ��o�^
		;
		; ���� A = �s�ԍ�(�_���s)
		;      X = �Y���s�̃e�L�X�g�|�C���^ - 1
		; �j�󃌃W�X�^ B,Y,P,Q,DP
		; =======================================================
LINE_REGISTER:	PUSH
		LIB   (LINENUMBER_BUF - 1) >> 8
		LIA   (LINENUMBER_BUF - 1) & $FF
		CAL   TOY		; Y = (LINENUMBER_BUF) - 1
		LIB   0
		POP
		PUSH			; A�ۑ�
		LP    Y_Reg
		ADB			; Y = Y + BA
		LP    Y_Reg
		ADB			; Y = Y + BA
		LP    X_Reg
		LDM
		IYS			; ���ʃA�h���X��������
		LP    X_Reg + 1
		LDM
		IYS			; ��ʃA�h���X��������
		POP			; A���A
		RTN



		; =======================================================
		; �s�ԍ��T�[�`
		;
		; ���� A = �s�ԍ�(�_���s)
		; �o�� X = �Y���s�̃e�L�X�g�|�C���^ - 1
		;      C = 0�c���������A1�c������Ȃ�(X=0)
		; �j�󃌃W�X�^ A,B,P,Q,DP
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
		JRNZP LINE_JMP1		; �A�h���X�̏�� = 0 �Ȃ��
		SC			;     C = 1
LINE_JMP1:	RTN

		endif



		; =======================================================
		; [TOOL4]2000�����o�̓x���`�}�[�N�e�X�g
		; =======================================================
		if TOOL = 4

		CALL  CLS_START		; ��ʃN���A
		LIA   99		; 100�񃋁[�v
		PUSH
BENCH_LOOP1:	CALL  STRING_PRINT
		db    "**PC-1350/PC-1360K**", 0
		LOOP  BENCH_LOOP1
		RTN

		endif



		; =======================================================
		; [TOOL5]�J���p
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



;������������������������������������������������������������������������
;�� �@         �ȉ��A�����V�X�e���{�́A���܂��A�g��PRINT��         �@�@��
;������������������������������������������������������������������������

		; =======================================================
		; ���p1�����\��
		;
		; ���� A = �����R�[�h
		;      (CSRX) = X���W
		;      (CSRY) = Y���W
		; �j�󃌃W�X�^ A,B,X,Y,K,N,P,Q,DP
		; =======================================================
CHAR:		CPIA  $0A		; A = 0A �Ȃ��
		JRNZP CHAR_JMP1
		CALL  CARRIAGE_RETURN	;     ���s����
		RTN
CHAR_JMP1:	CPIA  $FE		; A = FE �Ȃ��
		JRNZP CHAR_JMP2		;     �X�L�b�v
		RTN
CHAR_JMP2:
		if COLUMN = 25		; 25�����[�h�ŉ��s�}�[�N�\���p
			if (TOOL = 3) & (CRMARK = 1)
				CPIA  $7F	; ���s�}�[�N�R�[�h
				JRNZP CHAR_JMP5
				if TARGET = 1350	; PC-1350�͌�납����o��
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
		CPIA  COLUMN		; X���W���E�[�Ȃ��
		JRCP  CHAR_JMP3
		CALL  CURSOR_UPDATE	;     �J�[�\���E�ړ�
CHAR_JMP3:
		if COLUMN = 25
			CALL  VRAM1_ADR

			if TARGET = 1350
				CAL   PRINT1		; 1�`5�h�b�g�o��+�]��
			else
				LIDP  BANK_SELECT
				LDD
				PUSH			; ���݂�BANK�ۑ�
				LIA   1			; BANK1�I��
				STD
				LIB   5
				CAL   BLOCK		; 1�`5�h�b�g�o��
				POP
				LIDP  BANK_SELECT
				STD			; BANK���A
				CLRA			; �]��
				IYS
			endif
		endif

		if COLUMN = 30
			CALL  VRAM1_ADR
			LIB   4
			CAL   BLOCK		; 1�`4�h�b�g�o��
			CLRA			; �]��
			IYS
		endif

		if COLUMN = 37
			LIA   3			; 4�񃋁[�v
			PUSH
			CALL  CSR2GCSR		; ���W���O���t�B�b�N���W
			CALL  VRAM2_ADR		; VRAM�A�h���X�Z�o
CHAR_LOOP1:		IXL			; 1�`4�h�b�g�o��
			IYS
			INCK			; X���W+1
			DECN
			JRNZP CHAR_JMP4		; VRAM���E����
			CALL  VRAM2_ADR		;     VRAM�A�h���X�Čv�Z
CHAR_JMP4:		LOOP  CHAR_LOOP1
		endif

		CALL  CURSOR_UPDATE	; �J�[�\���E�ړ�
		RTN

		if CRMARK = 1
			if (TARGET= 1350) & (COLUMN = 25)
CRMARK_FONT:			db $0F, $10, $54, $38, $10	; ���s�}�[�N�t��
			endif
			if (TARGET= 1360) & (COLUMN = 25)
CRMARK_FONT:			db $10, $38, $54, $10, $0F	; ���s�}�[�N
			endif
		endif



		; =======================================================
		; ���p�t�H���g�A�h���X�v�Z
		;
		; ���� A = �����R�[�h
		; �o�� X = �t�H���g�A�h���X - 1
		;          �� PC-1350����25���̏ꍇ�́A�t�H���g�A�h���X + 1
		; �j�󃌃W�X�^ A,B,P,Q,DP
		; =======================================================
FONTADR_CALC:	CPIA  $F0		; F0�ȏ�Ȃ�
		JRCP  FONT_JMP1
		SBIA  $10		;     10���Z
FONT_JMP1:	CPIA  $A0		; A0�ȏ�Ȃ�
		JRCP  FONT_JMP2
		SBIA  $20		;     20���Z
FONT_JMP2:	SBIA  $20		; 20���Z
		JRNCP FONT_JMP3
		LIA   $20		; 00-1F��20�ɂ���
FONT_JMP3:	LIB   $00
		if COLUMN = 25			; 25���̏ꍇ
			if TARGET = 1350
				INCA		; 1���
			endif
			CAL   TOX
			LP    A_Reg
			ADB			; BA = BA + BA (2�{)
			LP    A_Reg
			ADB			; BA = BA + BA (4�{)
			LP    X_Reg
			ADB			; X = X + BA (5�{����)
			LIB   FONT_ADR >> 8
			LIA   FONT_ADR & $FF	; �����L�����N�^�t�H���g�A�h���X
			LP    X_Reg
			ADB			; X = X + BA
			if TARGET <> 1350
				DX
			endif
		else				; 30,37���̏ꍇ
			LP    A_Reg
			ADB			; BA = BA + BA (2�{)
			LP    A_Reg
			ADB			; BA = BA + BA (4�{)
			CAL   TOX
			LIB   ASCII4_FONT >> 8
			LIA   ASCII4_FONT & $FF	; 4dot�L�����N�^�t�H���g�A�h���X
			LP    X_Reg
			ADB			; X = X + BA
			DX
		endif
		RTN



		; =======================================================
		; �S�p1�����\��
		;
		; ���� AB = �����R�[�h(JIS or ShiftJIS)
		;      (CSRX) = X���W
		;      (CSRY) = Y���W
		; �j�󃌃W�X�^ A,B,X,Y,P,Q,DP
		; =======================================================
KANJI_CHAR:	CPIA  $81		; ��1�o�C�g��81�ȏ�Ȃ�
		JRCP  KANJI_JMP1
		CALL  JIS_CONV		;     ShiftJIS��JIS�ϊ�
KANJI_JMP1:	CPIA  $26
		JRCP  KANJI_JMP2
		CPIA  $30
		JRCP  KANJI_JMP3	; 25�`2F��Ȃ�΁��ɕϊ�
KANJI_JMP2:	CAL   TOX		; X = AB
		EXAB
		CAL   TOY		; Y = AB
		LIA   END_CODE & $FF
		LIB   END_CODE >> 8
		LP    Y_Reg
		SBB			; Y - BA  �� END_CODE - JIS�R�[�h
		LP    A_Reg
		LIQ   X_Reg
		MVB			; AB = X
		JRCP  KANJI_JMP4	; END_CODE�ȍ~��JIS�R�[�h��
KANJI_JMP3:	LIA   $22		;     ���ɕϊ�
		LIB   $23
KANJI_JMP4:	CALL  KFONTADR_CALC	; �t�H���g�A�h���X�v�Z

		LIDP  CSRX
		LDD
		if (KANJI = 5) & (COLUMN = 25)	; ����5�h�b�g�t�H���g�̏ꍇ
			CPIA  COLUMN 		; X���W���E�[�Ȃ��
		else				; ����7or11�h�b�g�t�H���g�̏ꍇ
			CPIA  COLUMN - 1	; �S�p�E��������ʂ���͂ݏo��ꍇ
		endif
		JRCP  KANJI_JMP5
		CALL  CARRIAGE_RETURN

KANJI_JMP5:
		if (COLUMN = 25) | (COLUMN = 30)	; 25,30���̏ꍇ
			if KANJI = 5			; ����5�h�b�g�t�H���g�̏ꍇ
				CALL  VRAM1_ADR
				LIB   5			; 1�`5�h�b�g��
				CAL   BLOCK
				if COLUMN = 25		; 25�����[�h�ł͑S�p�̕������͔��p�Ɠ���
					CLRA		; �]��
					IYS
				else			; 30�����[�h��
					CLRA		; �]��
					IY
					LII   3
					FILD
					CALL  CURSOR_UPDATE	; �J�[�\���E�ړ�(�S�p������)
				endif
			else
				CALL  VRAM1_ADR		; ������
				if COLUMN = 25
					LIB   6		; 1�`6�h�b�g��
				endif
				if COLUMN = 30
					LIB   5		; 1�`5�h�b�g��
				endif
				CAL   BLOCK
				CALL  CURSOR_UPDATE	; �J�[�\���E�ړ�(�S�p������)

				CALL  VRAM1_ADR		; �E����
				if KANJI = 7
					if COLUMN = 25	; ����7�h�b�g�t�H���g�A25���̏ꍇ
						IXL		; 7�h�b�g��
						IYS
						CLRA		; �]��5�h�b�g
						IY
						LII   4
						FILD
					endif
					if COLUMN = 30	; ����7�h�b�g�t�H���g�A30���̏ꍇ
						IXL		; 6,7�h�b�g��
						IYS
						IXL
						IYS
						CLRA		; �]��3�h�b�g
						IYS
						IYS
						IYS
					endif
				endif
				if KANJI = 11		; ����11�h�b�g�t�H���g�̏ꍇ
					if COLUMN = 25
						LIB   5		; 7�`11�h�b�g��
						CAL   BLOCK
						CLRA		; �]��1�h�b�g
						IYS
					endif
					if COLUMN = 30
						LIB   5		; 6�`10�h�b�g��
						CAL   BLOCK	; (11�h�b�g�ڂ͌���)
					endif
				endif
			endif
		endif
		if COLUMN = 37			; 37���̏ꍇ
			if KANJI = 5			; ����5�h�b�g�t�H���g�̏ꍇ
				LIA   4			;     5�h�b�g��
			else				; ����7�h�b�g�t�H���g�̏ꍇ
				LIA   6			;     7�h�b�g��
			endif
			PUSH
			CALL  CSR2GCSR			; ���W���O���t�B�b�N���W
			CALL  VRAM2_ADR			; VRAM�A�h���X�Z�o
KANJI_LOOP1:		IXL				; 1�`7�h�b�g��
			IYS
			INCK				; X���W+1
			DECN
			JRNZP KANJI_JMP6		; VRAM���E����
			CALL  VRAM2_ADR			;     VRAM�A�h���X�Čv�Z
KANJI_JMP6:		LOOP  KANJI_LOOP1

			if KANJI = 5			; ����5�h�b�g�t�H���g�̏ꍇ
				LIA   2			;     �]��3�h�b�g
				PUSH
				CLRA
KANJI_LOOP2:			IYS
				INCK
				DECN
				JRNZP KANJI_JMP7	;     VRAM���E����
				CALL  VRAM2_ADR		;         VRAM�A�h���X�Čv�Z
KANJI_JMP7:			LOOP  KANJI_LOOP2
			else				; ����7�h�b�g�t�H���g�̏ꍇ
				CLRA			;     �]��1�h�b�g
				IYS
			endif
			CALL  CURSOR_UPDATE	; �J�[�\���E�ړ�(�S�p������)
		endif

		CALL  CURSOR_UPDATE	; �J�[�\���E�ړ�(�S�p�E����)
		RTN



		; =======================================================
		; �V�t�gJIS �� JIS�ϊ�
		;
		; ���� AB = �V�t�gJIS�R�[�h(A=��1�o�C�gC1, B=��2�o�C�gC2)
		; �o�� AB = JIS�R�[�h
		; �j�󃌃W�X�^ Q
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
		; �S�p�t�H���g�A�h���X�v�Z
		;
		; ���� AB = JIS�R�[�h(A=��1�o�C�g,B=��2�o�C�g)
		; �o�� X = �t�H���g�A�h���X - 1
		; �j�󃌃W�X�^ A,B,P,Q,DP
		; =======================================================
KFONTADR_CALC:	CPIA  $30
		JRCP  KFONT_JMP1
		SBIA  10		; 26�`2F��J�b�g
KFONT_JMP1:	SBIA  $21		; ��
		EXAB
		SBIA  $21		; �_
		EXAB			; A=C1��,B=C2�_
		PUSH
		CLRA
		EXAB
		CAL   TOX		; X = BA
		LIB   00
		LIA   94
KFONT_LOOP1:	LP    X_Reg
		ADB			; X = X + 94
		LOOP  KFONT_LOOP1
		LP    X_Reg		; �������������̏C��
		SBB			; X = X - 94
		LP    A_Reg
		LIQ   X_Reg
		MVB			; BA = X
		LP    A_Reg
		ADB			; BA = BA + BA (2�{)
		LP    A_Reg
		ADB			; BA = BA + BA (4�{)

		if KANJI = 5		; ����5�h�b�g�t�H���g�̏ꍇ(5�{)
			LP    X_Reg
			ADB			; X = X + BA
		else			; ����7or11�h�b�g�t�H���g�̏ꍇ
			LP    A_Reg
			ADB			; BA = BA + BA (8�{)
			LP    X_Reg
			LIQ   A_Reg
			EXB			; X <> BA
		endif
		if KANJI = 7		; ����7�h�b�g�t�H���g�̏ꍇ(X��7�{����)
			LP    X_Reg
			SBB			; X = X - BA (7�{)
		endif
		if KANJI = 11		; ����11�h�b�g�t�H���g�̏ꍇ(X��11�{����)
			LP    X_Reg
			ADB			; X = X + BA ( 9�{)
			LP    X_Reg
			ADB			; X = X + BA (10�{)
			LP    X_Reg
			ADB			; X = X + BA (11�{)
		endif

		LP    X_Reg
		LIB   KANJI_FONT >> 8
		LIA   KANJI_FONT & $FF	; �t�H���g�擪�A�h���X���Z
		ADB
		DX
		RTN



		; =======================================================
		; �J�[�\�����O���t�B�b�N���W
		;
		; ���� (CSRX) = X���W(0-36)
		;      (CSRY) = Y���W(0-3)
		; �o�� K(08) = X���W(0-149)
		;      L(09) = Y���W(0-3)
		; �j�󃌃W�X�^ A,P,DP
		;
		; �� 37�����[�h�Ŏg�p
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
		; VRAM�A�h���X�Z�o(1)
		;
		; ���� (CSRX) = X���W(0-29)
		;      (CSRY) = Y���W(0-3)
		; �o�� Y = VRAM�A�h���X - 1
		; �j�󃌃W�X�^ A,B,Y,P,Q,DP
		;
		; �� 25,30�����[�h�Ŏg�p
		; =======================================================
		if (COLUMN = 25) | (COLUMN = 30)

VRAM1_ADR:	LIB   VRAM >> 8
		LIDP  CSRX
		LDD
VRAM1_LOOP1:	SBIA  COLUMN / 5	; ����/5 �������邾������
		JRCP  VRAM1_JMP1
		LP    B_Reg
		ADIM  $02		; ����/5 �Ŋ��������̕����� $200���Z
		JRM   VRAM1_LOOP1
VRAM1_JMP1:	ADIA  COLUMN / 5	; �����������������Z

		if COLUMN = 25		; 25�����[�h�̏ꍇ�AA��6�{����
			RC
			SL
			PUSH		; 2�{��ۑ�
			SL
			LP    Y_Reg
			EXAM		; 4�{��YL��
			POP
			ADM		; 2�{ + 4�{
			LDM
		else			; 25�����[�h�̏ꍇ�AA��5�{����
			PUSH
			LP    Y_Reg
			EXAM
			POP
			RC
			SL
			SL		; 4�{
			ADM		; 1�{ + 4�{
			LDM
		endif

		CAL   TOY		; Y = BA
		LIDP  CSRY
		LDD			; A = Y���W
		LP    Y_Reg
		TSIA  $01
		JRZP  VRAM1_JMP2	; �����Ȃ�
		ADIM  $40		; 	$40���Z
VRAM1_JMP2:	CPIA  2
		JRCP  VRAM1_JMP3	; 1�ȏ�Ȃ�
		ADIM  $1E		; 	$1E���Z
VRAM1_JMP3:	DY			; Y = Y - 1
		RTN

		endif



		; =======================================================
		; VRAM�A�h���X�Z�o(2)
		;
		; ���� K(08) = X���W(0-149)
		;      L(09) = Y���W(0-3)
		; �o�� Y = VRAM�A�h���X - 1
		;      N = 30 - X���W % 30  (��VRAM���E����ɗ��p)
		; �j�󃌃W�X�^ A,B,Y,P,Q,DP
		;
		; �� 37�����[�h�Ŏg�p
		; =======================================================
		if COLUMN = 37

VRAM2_ADR:	LIB   VRAM >> 8
		LP    K_Reg
		LDM			; A = X���W
VRAM2_LOOP1:	SBIA  30		; 30�������邾������
		JRCP  VRAM2_JMP1
		LP    B_Reg
		ADIM  $02		; 30�Ŋ��������̕����� $200���Z
		JRM   VRAM2_LOOP1
VRAM2_JMP1:	ADIA  30		; �����������������Z
		PUSH			; 30�Ŋ������]���ۑ�
		CAL   TOY		; Y = BA
		LP    L_Reg
		LDM			; A = Y���W
		LP    Y_Reg
		TSIA  $01
		JRZP  VRAM2_JMP2	; Y���W��0or2�Ȃ�
		ORIM  $40		; 	$40���Z
VRAM2_JMP2:	CPIA  2
		JRCP  VRAM2_JMP3	; Y���W��2or3�Ȃ�
		ADIM  $1E		; 	$1E���Z
VRAM2_JMP3:	DY			; Y = Y - 1
		LP    N_Reg
		LIA   30
		EXAM			; N = 30
		POP			; �]�蕜�A
		SBM			; N = 30 - A
		RTN

		endif



		; =======================================================
		; ���͑҂��L�[����(�L�[���s�[�g�t��)
		;
		; �o�� A = �L�[�R�[�h
		; �j�󃌃W�X�^ I,A,P,Q,DP
		; ���[�N (32) ���s�[�g�t���O
		; =======================================================
		if KEYSCAN = 1

KEY_REPEAT:	CALL  INKEY_WAIT
		LP    $32
		TSIM  $01		; ���s�[�g���蒆(1)�Ȃ��
		JRNZP KEY_JMP2		;     ���s�[�g�����
		TSIM  $FF		; ���s�[�gOFF(0)�Ȃ��
		JRNZP KEY_JMP1
		ORIM  $01		;    ���s�[�g���蒆(1)��
KEY_JMP1:	RTN			; ���s�[�g��(2)�Ȃ烊�^�[��

					; ���s�[�g����
KEY_JMP2:	CPIA  Key_ENTER		; ���s�[�g���O�L�[
		JRZM  KEY_REPEAT
		CPIA  Key_SHIFT
		JRZM  KEY_REPEAT
		LIA   $03
		CAL   OUTC		; �J�E���^���Z�b�g
KEY_LOOP1:	CALL  INKEY_WAIT
		LP    $32
		TSIM  $FF		; ���s�[�gOFF(0)�Ȃ��
		JRZM  KEY_REPEAT	;     ���s�[�g���蒆�ɃL�[�𗣂���
		TEST  $01
		JRZM  KEY_LOOP1		; 500ms�҂�
		ANIM  $00
		ORIM  $02		;     ���s�[�g��(2)�ɂ���
		RTN



		; =======================================================
		; ���͑҂��L�[����
		;
		; �o�� A = �L�[�R�[�h
		; �j�󃌃W�X�^ I,A,P,Q,DP
		; ���[�N (32) ���s�[�g�t���O
		;        (33,34) �I�[�g�p���[�I�t�^�C�}�[
		; =======================================================
INKEY_WAIT:	CAL   INKEY
		CAL   T6WAIT		; 6ms�҂�
		JRNCP INKEY_JMP1	; �L�[���͂���
		CALL  TIMER_RESET	;     �I�[�g�p���[�I�t�^�C�}�[���Z�b�g
		RTN

INKEY_JMP1:	LP    $32		; �L�[���s�[�gOFF(0)
		ANIM  $00
		CLRA			; �I�[�g�p���[�I�t�^�C�}�[ + 1
		SC
		LP    $34
		ADCM			; (34) = (34) + 0 + 1
		LP    $33
		ADCM			; (33) = (33) + C
		CPIM  120		; 120*2.5s=300�b�ŃI�[�g�p���[�I�t
		JRCM  INKEY_WAIT
		CALL  TIMER_RESET	;     �I�[�g�p���[�I�t�^�C�}�[���Z�b�g
		LIA   $0C
		CAL   OUTC		;     �p���[�I�t
		RTN



		; =======================================================
		; �I�[�g�p���[�I�t�^�C�}�[���Z�b�g
		;
		; �j�󃌃W�X�^ P
		; ���[�N (33,34) �I�[�g�p���[�I�t�^�C�}�[
		; =======================================================
TIMER_RESET:	LP    $33
		ANIM  0			; (33) = 0
		LP    $34
		ANIM  0			; (34) = 0
		RTN

		endif



		; =======================================================
		; �X�N���[���A�b�v
		;
		; �j�󃌃W�X�^ I,A,P,Q,DP
		; =======================================================
SCROLL_UP:
		if (TOOL = 2) & (KEYSTOP = 1)
SCRLUP_JMP1:		CALL  KEY_REPEAT	; �L�[����(�L�[���s�[�g�t��)
			CPIA  Key_CLS		; CLS�L�[
			JRNZP SCRLUP_JMP3	;     �I��
			LDR			; 3�i���X�^�b�N����
			ADIA  6
			STR
			RTN
SCRLUP_JMP3:		CPIA  Key_DOWN		; ���L�[
			JRNZM SCRLUP_JMP1
		endif

		LIA   4			; 0-29, 30-59, 60-89, 90-119, 120-149
		PUSH			; �h�b�g���ɏ���(5�񃋁[�v)
		LII   29
		LIA   VRAM >> 8
		LIDP  SCRLUP_LOOP1 + 1	; ���ȏ�������
		STD
SCRLUP_LOOP1:	LIDP  VRAM + $40	; 2�s�ڂ�1�s�ڂɃR�s�[
		LP    $10
		MVWD
		LIDL  $00
		LP    $10
		EXWD

		LIDL  $1E		; 3�s�ڂ�2�s�ڂɃR�s�[
		LP    $10
		MVWD
		LIDL  $40
		LP    $10
		EXWD

		LIDL  $5E		; 4�s�ڂ�3�s�ڂɃR�s�[
		LP    $10
		MVWD
		LIDL  $1E
		LP    $10
		EXWD

		LIDL  $5E		; 4�s�ڂ��N���A
		CLRA
		FILD

		LIDP  SCRLUP_LOOP1 + 1	; ���ȏ�������
		LDD
		ADIA  $02
		STD
		LOOP  SCRLUP_LOOP1
		RTN



		; =======================================================
		; �X�N���[���_�E��
		;
		; �j�󃌃W�X�^ I,A,P,Q,DP
		; =======================================================
		if TOOL > 1

SCROLL_DOWN:	LIA   4			; 0-29, 30-59, 60-89, 90-119, 120-149
		PUSH			; �h�b�g���ɏ���(5�񃋁[�v)
		LII   29
		LIA   VRAM >> 8
		LIDP  SCRLDW_LOOP1 + 1	; ���ȏ�������
		STD
SCRLDW_LOOP1:	LIDP  VRAM + $1E	; 3�s�ڂ�4�s�ڂɃR�s�[
		LP    $10
		MVWD
		LIDL  $5E
		LP    $10
		EXWD

		LIDL  $40		; 2�s�ڂ�3�s�ڂɃR�s�[
		LP    $10
		MVWD
		LIDL  $1E
		LP    $10
		EXWD

		LIDL  $00		; 1�s�ڂ�2�s�ڂɃR�s�[
		LP    $10
		MVWD
		LIDL  $40
		LP    $10
		EXWD

		LIDL  $00		; 1�s�ڂ��N���A
		CLRA
		FILD

		LIDP  SCRLDW_LOOP1 + 1	; ���ȏ�������
		LDD
		ADIA  $02
		STD
		LOOP  SCRLDW_LOOP1

		CALL CSR_CLEAR		; �J�[�\�����W�N���A
		RTN

		endif



		; =======================================================
		; �S��ʃN���A�iCLS�j ���J�[�\�����W�������������
		;
		; �j�󃌃W�X�^ I,A,X,P,Q,DP
		; =======================================================
CLS_START:	LIA   4
		PUSH
		LIB   VRAM >> 8
		LIA   VRAM & $FF
		CAL   TOXM
		LII   59		; 60�h�b�g��
		CLRA
CLS_LOOP1:	IX
		FILD			; 1,3�s�ڃN���A
		LP    X_Reg
		ORIM  $3F
		IX
		FILD			; 2,4�s�ڃN���A
		ORIM  $FF
		LP    X_Reg + 1
		ADIM  1			; ���̃u���b�N
		LOOP  CLS_LOOP1



		; =======================================================
		; �J�[�\�����W������
		;
		; �j�󃌃W�X�^ I,A,DP
		; =======================================================
CSR_CLEAR:	CLRA
		LII  1
		LIDP CSRX
		FILD
		RTN



		; =======================================================
		; �J�[�\���X�V
		;
		; ���� (CSRX) = X���W(0-24)
		;      (CSRY) = X���W(0-3)
		; �j�󃌃W�X�^ A,DP
		; =======================================================
CURSOR_UPDATE:	LIDP  CSRX
		LDD
		INCA			; X���W+1
		CPIA  COLUMN + 1	; X���W >= 26 or 31 or 37�Ȃ��
		JRNCP CARRIAGE_RETURN	; ���s
CURSOR_JMP1:	STD			; X���W�X�V
		RTN



		; =======================================================
		; ���s
		;
		; �j�󃌃W�X�^ A,DP
		; =======================================================
CARRIAGE_RETURN:LIDP  CSRX
		ANID  0			; X���W = 0
		LIDL  CSRY & $FF	; Y���W += 1
		LDD
		INCA
		STD
		CPIA  4			; Y���W >= 4 �Ȃ��
		JRCP  CARRIAGE_JMP1
		LIA   3			;     Y���W = 3
		STD
		CALL  SCROLL_UP		;     �X�N���[���A�b�v
CARRIAGE_JMP1:	RTN



		; =======================================================
		; ������\��
		;
		; ���� X = �e�L�X�g�f�[�^�A�h���X - 1
		; �j�󃌃W�X�^ I,A,B,X,Y,(38),(39),P,Q,DP
		; =======================================================
MOJI_START:	IXL			; ��1�o�C�g�ǂݍ���
		CPIA  0			; 0�Ȃ�I�[
		JRZP  MOJI_END
		CPIA  $0D		; 0D�͒P�ɃX�L�b�v
		JRZM  MOJI_START
		CPIA  $81		; 81�����͔��p
		JRCP  MOJI_JMP1
		CPIA  $A0		; A0�����Ȃ�S�p
		JRCP  MOJI_JMP2
		CPIA  $E0		; E0�ȏ�Ȃ�S�p
		JRNCP MOJI_JMP2

MOJI_JMP1:	CAL   XTO38		; (38,39) = X
		CALL  CHAR		; ���p1�����\��
		JRP   MOJI_JMP3

MOJI_JMP2:	EXAB
		IXL			; ��2�o�C�g�ǂݍ���
		EXAB			; A=��1�o�C�g,B=��2�o�C�g
		CAL   XTO38		; (38,39) = X
		CALL  KANJI_CHAR	; �S�p1�����\��
MOJI_JMP3:	CAL   R38TOX		; X = (38,39)
		JRM   MOJI_START
MOJI_END:	RTN



		; =======================================================
		; [���܂�]������\��(API)
		;
		; ���� 78(STRING_PRINT)������R�[�h...00
		; ��j 78FA2841424300 (ABC�ƕ\�������)
		;
		; �}�V����ŕ�����(���p�A�S�p����)��\������B
		; =======================================================
		if STRING_FLAG = 1

STRING_PRINT:	LDR
		STQ
		LP    X_Reg
		MVB			; X = (R,R+1)
		DX			; X = ������A�h���X - 1
		CALL  MOJI_START
		IX
		LDR
		STP
		LIQ   X_Reg
		MVB			; PC = ������̏I�[ + 1
		RTN

		endif



		; =======================================================
		; [���܂�]�J�[�\���ݒ�(API)
		;
		; ���� 78(CURSOR)(X���W)(Y���W)
		; ��j 78FA400503 (CURSOR 5,3)
		;
		; �}�V����ŃJ�[�\�����W�̎w�������B�G���[�`�F�b�N�͍s
		; ���Ă��Ȃ��B
		; =======================================================
		if CURSOR_FLAG = 1

CURSOR_START:	LDR
		STQ
		LP    X_Reg
		MVB			; X = (R,R+1)
		DX			; X = X���W�p�����[�^�A�h���X - 1
		IXL
		LIDP  CSRX
		STD			; (CSRX) = X���W
		IXL
		LIDP  CSRY
		STD			; (CSRY) = Y���W
		IX
		LDR
		STP
		LIQ   X_Reg
		MVB			; PC = �p�����[�^ + 1
		RTN

		endif



		; =======================================================
		; [���܂�]�g��PRINT����(BASIC)
		;
		; ���� CALL PRINT_START,�f�[�^[;�f�[�^...]
		;      �f�[�^1) "������"
		;      �f�[�^2) ASCII�R�[�h(20�`DF)
		;      �f�[�^3) JIS�R�[�h(2121�`)
		;      �f�[�^4) �V�t�gJIS�R�[�h(8440�`)
		; ��j CALL &xxxx, "ABC�ݼ�";33;65;&3021;&8250
		;
		; BASIC�ŕ������\������B�����R�[�h���w�肷��Ί������\
		; ���\�B�f�[�^1)�͕����񎮂��w�肵�A���l�͎w��ł��Ȃ�
		; �̂ŁA�K�v�Ȃ��STR$�ŕ����񉻂��邱�ƁB�Ȃ������ŉ��s
		; �͍s��Ȃ��B�����Z�~�R�����͕s�v�B
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
PRINT_JMP3:	CAL   CULC		; ���]��
		JRCM  PRINT_JMP1	; �G���[�Ȃ��
		CAL   PUSHX		; X�ۑ�
		CAL   Check
		JRCP  PRINT_JMP4	; ������Ȃ��
		LP    $17		;     ������
		LDM
		ADIA  STR_BUF & $FF
		LIDP  PRINT_STR + 2	;     ������̖���(���ȏ�������)
		STD
PRINT_STR:	LIDP  STR_BUF
		ANID  0			;     ������̖���+1�� 0����������
		LIB   STR_BUF >> 8
		LIA   STR_BUF & $FF
		CAL   TOXM		;     X = 6E60 - 1
		CALL  MOJI_START	;     ������\��
		JRP   PRINT_JMP6
PRINT_JMP4:				; ���l�Ȃ��
		CAL   DTOH		;     (18,19) = RA
		LP    $19
		CPIM  $00
		JRNZP PRINT_JMP5	;     ���p�����Ȃ��
		LP    $18
		LDM			;         A = (18) �����R�[�h
		CALL  CHAR		;         1�����\��
		JRP   PRINT_JMP6
PRINT_JMP5:	LP    A_Reg		;     �S�p�����̂Ƃ�
		LIQ   $18
		MVB			;         AB = (18,19) �S�p�����R�[�h
		EXAB
		CALL  KANJI_CHAR	;         �S�p1�����\��
PRINT_JMP6:	CAL   POPX		; X���A
		IXL
		CPIA  ';'
		JRZM  PRINT_JMP3	; �p��
		DX
		RC
		JRM   PRINT_JMP2	; ����I��

		endif
