; +========================================================+
; |  30���\���}�V���ꃂ�j�^�[ for PC-1350/60/60K           |
; |                           (C) �������񁗂���           |
; |                           (X account @pockecom_love)   |
; |                                                        |
; |  [�ꎟ�z�z�T�C�g]                                      |
; |  https://github.com/pockecom-love/kanji-system         |
; |                                                        |
; |  [License] MIT                                         |
; |                                                        |
; +========================================================+



		; =======================================================
		; �ݒ�
		; =======================================================
TARGET		equ   1350	; PC-1350�� 1350�APC-1360/60K�� 1360 ���w��



		; =======================================================
		; ���x����`�t�@�C��
		; =======================================================
		nolist
		if TARGET = 1350
			org   $6600	; �I�u�W�F�N�g���[�h�A�h���X
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
		; 30���\���}�V���ꃂ�j�^�[ for PC-1350
		;
		; ���[�N (2E) ���[�h
		;             bit0  1�c�L�����\���A0�c�O���t�B�b�N�\��
		;             bit1  1�c�ҏW���[�h�A0�c�{�����[�h
		;             bit2  1�c�J�[�\��ON�A0�c�J�[�\��OFF
		;        (2F) �ҏW�p�j�u���ʒu(0-15)
		;        (30,31) X���W,Y���W
		;        (32) �L�[���s�[�g�t���O
		;        (33,34) �I�[�g�p���[�I�t�^�C�}�[
		;        (35,36) 1�s�ڂ̕\���A�h���X(L,H)
		;        (37) �`�F�b�N�T��
		;        (38,39) X���W�X�^�ޔ�p
		; =======================================================
MONITOR:	LII   9
		CLRA
		LP    $2E
		FILM			; ���[�N�N���A
		IXL
		CPIA  ','		; �J���}�łȂ����
		JRNZP MON_JMP2		;     �A�h���X�w��ȗ���
		POP
		POP
		LIB   4			; 4�񃋁[�v
MON_LOOP3:	LII   1
		LP    $36
		SLW			; (35,36)��4�r�b�g�V�t�g
		IXL
		CALL  HEX2BIN
		JRCP  MON_JMP1		; �G���[
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

MON_JMP2:	CAL   PUSHX		; X�ۑ�
		CALL  CLS_START		; ��ʃN���A
		LP    $32		; �L�[���s�[�g�t���OON
		LIA   1			; �N������Enter�L�[���L�����Z�����邽��
		EXAM

		; ----------------------- ����4�s�o�� -----------------------
MON_INIT:	LIA   3
		PUSH
		LP    K_Reg
		LIQ   $35
		MVB			; KL = (35,36)
MON_LOOP1:	CALL  LINE_PRINT	; 1�s�o��
		LOOP  MON_LOOP1
		CALL  CURSOR_ON		; �J�[�\��ON

		; ----------------------- ���C�����[�v -----------------------
MON_LOOP2:	CALL  KEY_REPEAT
		CPIA  ASC_CLS		; CLS�L�[�ŏI��
		JRZP  MON_END
		CPIA  ASC_UP		; ���L�[
		JRZP  MON_UP
		CPIA  ASC_DOWN		; ���L�[
		JRZP  MON_DOWN
		CPIA  ASC_LEFT		; ���L�[
		JRZP  MON_LEFT
		CPIA  ASC_RIGHT		; ���L�[
		JRZP  MON_RIGHT
		CPIA  ASC_ENTER		; ENTER�L�[
		JRZP  MON_ENTER
		CPIA  ASC_MODE		; MODE�L�[
		JRZP  MON_MODE
		LP    $2E
		TSIM  $02
		JRZM  MON_LOOP2		; �{�����[�h�Ȃ烋�[�v

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

MAIN_SKIP6:	CPIA  '0'		; 1�`9,A�`F�L�[
		JRCM  MON_LOOP2
		CPIA  ':'		; 9�̎�
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

		; --------------------- ENTER�L�[���� ---------------------
MON_ENTER:	CALL  CURSOR_OFF	; �J�[�\��OFF
		LP    $2E
		TSIM  $02		; �{�����[�h�Ȃ�
		JRZP  MON_DOWN		;     ���L�[������
		ANIM  $F9		; �{�����[�h�ɂ���
		JRM   MON_LOOP2

		; ----------------------- ���L�[���� -----------------------
MON_DOWN:	CALL  CURSOR_OFF	; �J�[�\��OFF
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
		CALL  LINE_PRINT	; 1�s�o��
		CALL  CURSOR_ON		; �J�[�\��ON
		JRM   MON_LOOP2

		; ----------------------- ���L�[���� -----------------------
MON_UP:		CALL  CURSOR_OFF	; �J�[�\��OFF
		LIB   $00
		LIA   $08
		LP    $35
		SBB			; (35,36) -= 8
		LP    K_Reg
		LIQ   $35
		MVB			; KL = (35,36)
		CALL  SCROLL_DOWN
		CALL  LINE_PRINT	; 1�s�o��
		CALL  CURSOR_ON		; �J�[�\��ON
		JRM   MON_LOOP2

		; ----------------------- ���L�[���� -----------------------
MON_LEFT:	LP    $2E
		TSIM  $02
		JRZP  LEFT_JMP1		; �ҏW���[�h�Ȃ��
		CALL  CURSOR_OFF	;     �J�[�\��OFF
		LP    $2F
		SBIM  1			;     �ҏW�p�j�u��1�E��
		JRNCP LEFT_JMP2		;     �E�[�܂ł�������
		LIA   15
		EXAM			;         (2F) = 15
		JRM   MON_UP		;         ���L�[������
LEFT_JMP1:	ORIM  $02		; �ҏW���[�h�ɂ���
		LP    $2F
		LIA   15
		EXAM			; (2F) = 15
LEFT_JMP2:	CALL  CURSOR_ON		; �J�[�\��ON
		JRM   MON_LOOP2

		; ----------------------- ���L�[���� -----------------------
MON_RIGHT:	LP    $2E
		TSIM  $02
		JRZP  RIGHT_JMP1	; �ҏW���[�h�Ȃ��
		CALL  CURSOR_OFF	;     �J�[�\��OFF
		LP    $2F
		ADIM  1			;     �ҏW�p�j�u��1�E��
		CPIM  16
		JRCP  RIGHT_JMP2	;     �E�[�܂ł�������
		ANIM  0			;         (2F) = 0
		JRM   MON_DOWN		;         ���L�[������
RIGHT_JMP1:	ORIM  $02		; �ҏW���[�h�ɂ���
		LP    $2F
		ANIM  0			; (2F) = 0
RIGHT_JMP2:	CALL  CURSOR_ON		; �J�[�\��ON
		JRM   MON_LOOP2

		; ----------------------- MODE�L�[���� -----------------------
MON_MODE:	LP    $2E
		TSIM  $01
		JRZP  MODE_JMP1		; �ҏW���[�h�Ȃ��
		ANIM  $FE		;     MODE = 0
		JRP   MODE_JMP2
MODE_JMP1:	ORIM  $01		;     MODE = 1
MODE_JMP2:	CALL  CSR_CLEAR		; �J�[�\�����W�N���A
		JRM   MON_INIT

		; ----------------------- CLS�L�[���� -----------------------
MON_END:	CALL  CLS_START		; ��ʃN���A
		CAL   POPX		; X���A
		RC
		RTN   			; BASIC��

		; --------------------- 0-9,A-F�L�[���� ---------------------
INPUT:		PUSH
		LIQ   $35
		LP    K_Reg
		MVB			; KL = (35,36)
		LP    $2F
		LDM
		RC
		SR			; A = �j�u���ʒu / 2
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
		CALL  CHECK_SUM		; �`�F�b�N�T���Čv�Z
		CALL  GRAPH_PRINT	; �O���t�B�b�N�ĕ\��
		JRM   MON_RIGHT
INPUT_JMP3:	CALL  CHAR_PRINT	; �L�����N�^�ĕ\��
		JRM   MON_RIGHT



		; =======================================================
		; 1�s�o��
		;
		; ���� KL = ���[�̃A�h���X
		; =======================================================
LINE_PRINT:	LP    $37
		ANIM  0			; �`�F�b�N�T��������
		LIA   7
		PUSH
		LP    L_Reg
		LDM
		CALL  BYTE_PRINT	; �A�h���X��ʏo��
		LP    K_Reg
		LDM
		CALL  BYTE_PRINT	; �A�h���X���ʏo��
		LIA   ' '
		CALL  CHAR		; ' '�o��
LPRINT_LOOP1:	CALL  BYTE_READ		; 1�o�C�g�ǂݍ���
		LP    $37
		ADM			; �`�F�b�N�T�����Z
		CALL  BYTE_PRINT	; 1�o�C�g�o��
		LP    $2E
		TSIM  $01		; MODE = 1 �Ȃ�
		JRNZP LPRINT_JMP1	;     '-'���o�͂��Ȃ�
		LDR
		STP
		CPIM  4
		JRNZP LPRINT_JMP1
		LIA   '-'
		CALL  CHAR		; '-'�o��
LPRINT_JMP1:	LOOP  LPRINT_LOOP1
		LP    $2E
		TSIM  $01		; MODE = 1 �Ȃ�
		JRNZP LPRINT_JMP2	;     �L�����N�^�\����

		LIA   ':'
		CALL  CHAR		; ':'�o��
		LP    $37
		LDM
		CALL  BYTE_PRINT	; �`�F�b�N�T���o��

		LIA   ' '
		CALL  CHAR		; ' '�o��
		LIA   '['
		CALL  CHAR		; '['�o��
		LIB   0
		LIA   $08
		LP    K_Reg
		SBB
		LIA   7
		PUSH
LPRINT_LOOP2:	CALL  BYTE_READ
		IYS			; �O���t�B�b�N�o��
		LOOP  LPRINT_LOOP2
		LP    $30
		ADIM  2			; X���W+2
		LIA   ']'
		CALL  CHAR		; ']'�o��
		RTN

LPRINT_JMP2:	LIA   '|'
		CALL  CHAR		; '|'�o��
		LIB   0
		LIA   $08
		LP    K_Reg
		SBB
		LIA   7
		PUSH
LPRINT_LOOP3:	CALL  BYTE_READ		; 1�o�C�g�ǂݍ���
		CALL  CHAR		; �L�����N�^�\��
		LOOP  LPRINT_LOOP3
		RTN

		; ----------------------- �ϊ� -----------------------
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
		; �`�F�b�N�T���v�Z���o��
		;
		; 3�s�ڂ̃`�F�b�N�T�����Čv�Z���\������
		; =======================================================
CHECK_SUM:	LP    $37
		ANIM  0			; �`�F�b�N�T��������
		LP    K_Reg
		LIQ   $35
		MVB			; KL = (35,36)
		LIB   0
		LIA   $10
		LP    K_Reg
		ADB			; KL = (35,36) + $10
		LIA   7
		PUSH
CHECK_LOOP1:	CALL  BYTE_READ		; 1�o�C�g�ǂݍ���
		LP    $37
		ADM			; �`�F�b�N�T�����Z
		LOOP  CHECK_LOOP1
		LP    $30
		LIA   $17
		EXAM			; X���W = 23
		LP    $37
		LDM
		CALL  BYTE_PRINT	; �`�F�b�N�T���o��
		RTN



		; =======================================================
		; �L�����N�^�o��
		;
		; 3�s�ڂ̃L�����N�^���ĕ\������
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
		EXAM			; X���W = 26
CHARA_LOOP1:	CALL  BYTE_READ		; 1�o�C�g�ǂݍ���
		CALL  CHAR		; �L�����N�^�\��
		LOOP  CHARA_LOOP1
		RTN



		; =======================================================
		; �O���t�B�b�N�o��
		;
		; 3�s�ڂ̃O���t�B�b�N���ĕ\������
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
		EXAM			; X���W = 26
		CALL  VRAM1_ADR
		LIA   7
		PUSH
GRAPH_LOOP1:	CALL  BYTE_READ		; 1�o�C�g�ǂݍ���
		IYS
		LOOP  GRAPH_LOOP1
		RTN



		; =======================================================
		; 1�o�C�g�f�[�^�ǂݏo��(�I�[�g�C���N�������g)
		;
		; ���� KL = �A�h���X(LH)
		; �o�� A = �ǂݏo���l
		; �j�󃌃W�X�^ I,A,B,P,Q,DP
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
		; 1�o�C�g16�i�\��
		;
		; ���� A = 1�o�C�g�f�[�^
		; �j�󃌃W�X�^ A,B,X,Y,P,Q,DP
		; =======================================================
BYTE_PRINT:	PUSH
		SWP
		CALL  BYTE_JMP1		; ��ʃj�u��
		POP
		CALL  BYTE_JMP1		; ���ʃj�u��
		RTN

		; --------------------- 1�j�u���\�� ---------------------
BYTE_JMP1:	ANIA  $0F
		ORIA  $30		; 0�`9�����R�[�h��
		CPIA  $3A
		JRCP  BYTE_JMP2
		ADIA  $07		; A�`F�����R�[�h��
BYTE_JMP2:	CALL  CHAR
		RTN



		; =======================================================
		; ���p1�����\��
		;
		; ���� A = �����R�[�h
		;      (30) = X���W
		;      (31) = Y���W
		; �j�󃌃W�X�^ A,B,X,Y,P,Q,DP
		; =======================================================
CHAR:		CALL  FONTADR_CALC
		CALL  VRAM1_ADR
		IXL			; 1�`4�h�b�g�o��
		IYS			;  LIB  4
		IXL			;  CAL  BLOCK
		IYS			; �����[�v�W�J��������
		IXL
		IYS
		IXL
		IYS
		CLRA			; �]��
		IYS
		CALL  CURSOR_UPDATE	; �J�[�\���E�ړ�
		RTN



		; =======================================================
		; ���p�t�H���g�A�h���X�v�Z
		;
		; ���� A = �����R�[�h
		; �o�� X = �t�H���g�A�h���X - 1
		; �j�󃌃W�X�^ A,B,P,Q,DP
		; =======================================================
FONTADR_CALC:	CPIA  $E0		; E0�ȏ��
		JRNCP FONT_JMP3		;     0�ɂ���
FONT_JMP1:	CPIA  $80
		JRCP  FONT_JMP2
		CPIA  $A0		; A0�ȉ���
		JRCP  FONT_JMP3		;     0�ɂ���
		SBIA  $20		; 20���Z
FONT_JMP2:	SBIA  $20		; 20���Z
		JRNCP FONT_JMP4
FONT_JMP3:	CLRA			; 00-1F��20�ɂ���
FONT_JMP4:	LIB   $00
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
		RTN



		; =======================================================
		; VRAM�A�h���X�Z�o
		;
		; ���� (30) = X���W(0-29)
		;      (31) = Y���W(0-3)
		; �o�� Y = VRAM�A�h���X - 1
		; �j�󃌃W�X�^ A,B,Y,P,Q,DP
		; =======================================================
VRAM1_ADR:	LIB   VRAM >> 8
		LP    $30
		LDM
VRAM1_LOOP1:	SBIA  6			; ����/5 �������邾������
		JRCP  VRAM1_JMP1
		LP    B_Reg
		ADIM  $02		; ����/5 �Ŋ��������̕����� $200���Z
		JRM   VRAM1_LOOP1
VRAM1_JMP1:	ADIA  6			; �����������������Z
		PUSH
		LP    Y_Reg
		EXAM
		POP
		RC
		SL
		SL			; 4�{
		ADM			; 1�{ + 4�{
		LDM
		CAL   TOY		; Y = BA
		LP    $31
		LDM			; A = Y���W
		LP    Y_Reg
		TSIA  $01
		JRZP  VRAM1_JMP2	; �����Ȃ�
		ADIM  $40		; 	$40���Z
VRAM1_JMP2:	CPIA  2
		JRCP  VRAM1_JMP3	; 1�ȏ�Ȃ�
		ADIM  $1E		; 	$1E���Z
VRAM1_JMP3:	DY			; Y = Y - 1
		RTN



		; =======================================================
		; ���͑҂��L�[����(�L�[���s�[�g�t��)
		;
		; �o�� A = �L�[�R�[�h
		; �j�󃌃W�X�^ I,A,P,Q,DP
		; ���[�N (32) ���s�[�g�t���O
		; =======================================================
KEY_REPEAT:	CALL  INKEY_WAIT
		LP    $32
		TSIM  $01		; ���s�[�g���蒆(1)�Ȃ��
		JRNZP KEY_JMP2		;     ���s�[�g�����
		TSIM  $FF		; ���s�[�gOFF(0)�Ȃ��
		JRNZP KEY_JMP1
		ORIM  $01		;    ���s�[�g���蒆(1)��
KEY_JMP1:				;    ASCII�R�[�h�ɕϊ�
		if TARGET = 1350
			ADIA  $03	; �L�[�e�[�u���� $8403�`
		else
			ADIA  $60	; �L�[�e�[�u���� $4360�`
		endif
		LIDP  KEY_WRITE + 2
		STD
		if TARGET = 1360
			LIDP  BANK_SELECT
			LDD
			EXAB		; B = ���݂�BANK�ԍ�
			LIA   0		; BANK1�I��
			STD
		endif
KEY_WRITE:	LIDP  KEY_TABLE
		LDD
		if TARGET = 1360
			LP    B_Reg
			LIDP  BANK_SELECT
			MVDM		; BANK���A
		endif
		RTN			; ���s�[�g��(2)�Ȃ烊�^�[��

					; ���s�[�g����
KEY_JMP2:	CPIA  Inkey_ENTER		; ���s�[�g���O�L�[
		JRZM  KEY_REPEAT
		CPIA  Inkey_MODE		; ���s�[�g���O�L�[
		JRZM  KEY_REPEAT
		CPIA  Inkey_SHIFT
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
		JRM   KEY_JMP1



		; =======================================================
		; ���A���^�C���L�[����
		;
		; �o�� A = �L�[�R�[�h
		; �j�󃌃W�X�^ I,A,P,Q,DP
		; ���[�N (32) ���s�[�g�t���O
		;        (33,34) �I�[�g�p���[�I�t�^�C�}�[
		; =======================================================
INKEY_WAIT:	CAL   INKEY		; ���A���^�C���L�[�X�L����
		CAL   T6WAIT		; 6ms�҂�
		JRNCP INKEY_JMP1	; �L�[���͂��Ȃ��ꍇ
		CALL  TIMER_RESET	;     �I�[�g�p���[�I�t�^�C�}�[���Z�b�g
		RTN
					; �L�[���͂���̏ꍇ
INKEY_JMP1:	LP    $32		; �L�[���s�[�gOFF(0)
		ANIM  $00
		CLRA			; �I�[�g�p���[�I�t�^�C�}�[ + 1
		SC
		LP    $34
		ADCM			; (34) = (34) + 0 + 1
		LP    $33
		ADCM			; (33) = (33) + C
		CPIM  200		; 200*1.5s = 300�b��
		JRNCP POWER_OFF		;     �I�[�g�p���[�I�t��
		LP    $2E
		TSIM  $02		; bit1 = 0
		JRZM  INKEY_WAIT	; �{�����[�h�Ȃ烋�[�v
		TEST  $01
		JRZM  INKEY_WAIT	; 500ms�҂�
		LP    $2E
		TSIM  $04
		JRZP  INKEY_JMP2	; �J�[�\��ON�Ȃ��
		CALL  CURSOR_OFF	;     �J�[�\���\��OFF
		RTN
INKEY_JMP2:	CALL  CURSOR_ON		;     �J�[�\���\��ON
		RTN
POWER_OFF:	CALL  TIMER_RESET	; �I�[�g�p���[�I�t�^�C�}�[���Z�b�g
		LIA   $0C
		CAL   OUTC		; �p���[�I�t(OUTC �� $0C)
		RTN



		; =======================================================
		; �J�[�\��ON
		; ���� (30,31) �J�[�\�����W
		; =======================================================
CURSOR_ON:	LP    $2E
		TSIM  $02
		JRNZP CSRON_JMP1	; �{�����[�h�Ȃ��
		RTN			;     ���^�[��
CSRON_JMP1:	ORIM  $04		; �J�[�\��ON�ɂ���
		LP    $31
		LIA   2
		EXAM			; (31) = 2  (Y���W)
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
		CALL  CHAR		; �x�^�o��
		RTN



		; =======================================================
		; �J�[�\��OFF
		; ���� (30,31) �J�[�\�����W
		; =======================================================
CURSOR_OFF:	LP    $2E
		TSIM  $02
		JRNZP CSROFF_JMP1	; �{�����[�h�Ȃ��
		RTN			;     ���^�[��
CSROFF_JMP1:	ANIM  $FB		; �J�[�\��OFF�ɂ���
		LP    $31
		LIA   2
		EXAM			; (31) = 2  (Y���W)
		LP    $2F
		LDM
		LP    $30
		EXAM			; (30) = (2F)
		ANIM  $FE		; ��ʃj�u���ʒu�ɂ���
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
		SR			; A = �j�u���ʒu / 2
		ADIA  $10
		LIB   0
		LP    K_Reg
		ADB			; KL = KL + $10
		CALL  BYTE_READ
		CALL  BYTE_PRINT
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



		; =======================================================
		; �X�N���[���A�b�v
		;
		; �j�󃌃W�X�^ I,A,P,Q,DP
		; =======================================================
SCROLL_UP:	LIA   4			; 0-29, 30-59, 60-89, 90-119, 120-149
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

		LP    $30
		ANIM  0
		LP    $31
		LIA   3
		EXAM
		RTN



		; =======================================================
		; �X�N���[���_�E��
		;
		; �j�󃌃W�X�^ I,A,P,Q,DP
		; =======================================================
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
		LII   1
		LP    $30
		FILM
		RTN



		; =======================================================
		; �J�[�\���X�V
		;
		; ���� (30) = X���W(0-29)
		;      (31) = X���W(0-3)
		; �j�󃌃W�X�^ A,DP
		; =======================================================
CURSOR_UPDATE:	LP    $30
		ADIM  1			; X���W+1
		CPIM  30
		JRCP  CSRUP_JMP1
		ANIM  0
		LP    $31
		ADIM  1
CSRUP_JMP1:	RTN



		; =======================================================
		; 4x7�h�b�g���p�����t�H���g
		; =======================================================
		nolist
		include(ascii4_font.s)
