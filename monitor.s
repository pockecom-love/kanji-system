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

;   0         1         2         3
;   0123456789012345678901234567890
; ����������������������������������
; ��6700 00112233-44556677:XX [12]��
; ��6700 00112233-44556677:XX [12]��
; ��6700 00112233-44556677:XX [12]��
; ��6700 0011223344556677 12345678��
; ����������������������������������


		; =======================================================
		; �ݒ�
		; =======================================================
TARGET		equ   1350	; PC-1350�� 1350�APC-1360/60K�� 1360 ���w��



		; =======================================================
		; ���x����`�t�@�C��
		; =======================================================
		nolist
		if TARGET = 1350
			org   $6800	; �I�u�W�F�N�g���[�h�A�h���X
			include(SYMBOL1350.h)
		else
			org   $F300
			include(SYMBOL1360.h)
		endif
		list



		; =======================================================
		; 30���\���}�V���ꃂ�j�^�[
		;
		; ���[�N (2F) �ҏW���[�h(1�cON�A0�cOFF)
		;        (30,31) X���W,Y���W
		;        (32) �L�[���s�[�g�t���O
		;        (33,34) �I�[�g�p���[�I�t�^�C�}�[
		;        (35,36) 1�s�ڂ̕\���A�h���X(L,H)
		;        (37) �`�F�b�N�T��
		; =======================================================
MONITOR:	LII   8
		CLRA
		LP    $2F
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

		; ----------------------- ���C�����[�v -----------------------
MON_LOOP2:	CALL  KEY_REPEAT
		CPIA  Key_CLS		; CLS�L�[�ŏI��
		JRZP  MON_END
		CPIA  Key_UP		; ���L�[
		JRZP  MON_UP
		CPIA  Key_DOWN		; ���L�[
		JRZP  MON_DOWN
		CPIA  Key_ENTER		; ENTER�L�[��
		JRZP  MON_DOWN		;   ���L�[�Ɠ���
		CPIA  Key_MODE		; MODE�L�[
		JRZP  MON_MODE
		JRM   MON_LOOP2

		; ----------------------- ���L�[���� -----------------------
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
		CALL  LINE_PRINT	; 1�s�o��
		JRM   MON_LOOP2

		; ----------------------- ���L�[���� -----------------------
MON_UP:		LIB   $00
		LIA   $08
		LP    $35
		SBB			; (35,36) -= 8
		LP    K_Reg
		LIQ   $35
		MVB			; KL = (35,36)
		CALL  SCROLL_DOWN
		CALL  LINE_PRINT	; 1�s�o��
		JRM   MON_LOOP2

		; ----------------------- CLS�L�[���� -----------------------
MON_END:	CALL  CLS_START		; ��ʃN���A
		CAL   POPX		; X���A
		RC
		RTN   			; BASIC��

		; ----------------------- MODE�L�[���� -----------------------
MON_MODE:	LP    $2F
		TSIM  $FF
		JRZP  MODE_JMP1
		ANIM  0			; MODE = 0
		JRP   MODE_JMP2
MODE_JMP1:	ORIM  1			; MODE = 1
MODE_JMP2:	CALL  CSR_CLEAR		; �J�[�\�����W�N���A
		JRM   MON_INIT

		; ----------------------- 1�s�\�� -----------------------
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
		LP    $2F
		TSIM  $01		; MODE = 1 �Ȃ�
		JRNZP LPRINT_JMP1	;     '-'���o�͂��Ȃ�
		LDR
		STP
		CPIM  4
		JRNZP LPRINT_JMP1
		LIA   '-'
		CALL  CHAR		; '-'�o��
LPRINT_JMP1:	LOOP  LPRINT_LOOP1
		LP    $2F
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
		ADIM  2			; X���W+2
		LIA   ']'
		CALL  CHAR		; ']'�o��
		RTN

LPRINT_JMP2:	LIA   '|'
		CALL  CHAR		; '|'�o��
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
		CALL  CHAR		; �L�����N�^�\��
		CAL   R38TOX
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
		; 1�o�C�g�f�[�^�ǂݏo��(�I�[�g�C���N�������g)
		;
		; ���� KL = �A�h���X(LH)
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
		LIB   4
		CAL   BLOCK		; 1�`4�h�b�g�o��
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
FONTADR_CALC:	CPIA  $F0		; F0�ȏ�Ȃ�
		JRCP  FONT_JMP1
		SBIA  $10		;     10���Z
FONT_JMP1:	CPIA  $A0		; A0�ȏ�Ȃ�
		JRCP  FONT_JMP2
		SBIA  $20		;     20���Z
FONT_JMP2:	SBIA  $20		; 20���Z
		JRNCP FONT_JMP3
		LIA   $00		; 00-1F��20�ɂ���
FONT_JMP3:	LIB   $00
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
KEY_JMP1:	RTN			; ���s�[�g��(2)�Ȃ烊�^�[��

					; ���s�[�g����
KEY_JMP2:	CPIA  Key_ENTER		; ���s�[�g���O�L�[
		JRZM  KEY_REPEAT
		CPIA  Key_MODE		; ���s�[�g���O�L�[
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
		CPIM  200		; 200*1.5s=300�b�ŃI�[�g�p���[�I�t
		JRCM  INKEY_WAIT
		CALL  TIMER_RESET	;     �I�[�g�p���[�I�t�^�C�}�[���Z�b�g
		LIA   $0C
		CAL   OUTC		;     �p���[�I�t(OUTC �� $0C)
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
		JRCP  CURSOR_JMP1
		ANIM  0
		LP    $31
		ADIM  1
CURSOR_JMP1:	RTN



		; =======================================================
		; 4x7�h�b�g���p�����t�H���g
		; =======================================================
		nolist
		include(ascii4_font.s)
