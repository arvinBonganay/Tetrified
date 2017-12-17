TITLE TETRIFIED
.MODEL SMALL, STDCALL
;---------------------------------------------
.STACK 32
;---------------------------------------------
.DATA
  TITLE_SCRN1  DB 'screen_1.txt', 00H
  TITLE_SCRN2  DB 'screen_2.txt', 00H
  TITLE_SCRN3  DB 'screen_3.txt', 00H
  MAIN_MENU1 DB 'screen_4.txt', 00H
  MAIN_MENU2 DB 'screen_5.txt', 00H
  MAIN_MENU3 DB 'screen_6.txt', 00H
  MAIN_MENU4 DB 'screen_7.txt', 00H
  INGAME DB 'screen_8.txt', 00H
  BLOCK_A DB 'block_a.txt', 00H
  BLOCK_B DB 'block_b.txt', 00H
  BLOCK_C DB 'block_c.txt', 00H
  BLOCK_D DB 'block_d.txt', 00H
  BLOCK_E DB 'block_e.txt', 00H
  BLOCK_F DB 'block_f.txt', 00H
  BLOCK_G DB 'block_g.txt', 00H
  BLOCK_H DB 'block_h.txt', 00H
  BLOCK_I DB 'block_i.txt', 00H
  BLOCK_J DB 'block_j.txt', 00H
  BLOCK_K DB 'block_k.txt', 00H
  BLOCK_L DB 'block_l.txt', 00H
  BLOCK_M DB 'block_m.txt', 00H
  HIGHSCORE_FILE DB 'h.txt', 00H
  NAME_FILE DB 'h_name.TXT', 00H
  HIGHSCORE_SCRN DB 'h_screen.txt', 00H
  HELP_SCRN DB 'screen_9.txt', 00H
  GAME_OVER_SCRN DB 'gameover.txt', 00H
  NEW_HIGHSCORE_SCRN DB 'askname.txt', 00H

  MENU_COUNTER DW 0

  ROW_1 DB '0000000000$'
  ROW_2 DB '0000000000$'
  ROW_3 DB '0000000000$'
  ROW_4 DB '0000000000$'
  ROW_5 DB '0000000000$'
  ROW_6 DB '0000000000$'
  ROW_7 DB '0000000000$'
  ROW_8 DB '0000000000$'
  ROW_9 DB '0000000000$'
  ROW_10 DB '0000000000$'
  EMPTY_GRID DB '0000000000$'
  CURRENT_HIGHSCORE DB 8 DUP('$')
  INPUT_NAME DB 16 DUP ('$')
  NAME_HIGHSCORE DB 16 DUP ('$')

  CURR_X DW 1
  CURR_Y DW 0
  NEW_X DW 0
  NEW_Y DW 0
  TEMP_X DW 1
  TEMP_Y DW 0
  FREE_CELL DB '0' ; 0 = FREE , 1 = NOT FREE
  FREE_BLOCK DB '1'; 0 = FREE 1 = NOT FREE
  CURR_BLOCK DB 'B'
  NEXT_BLOCK DB ' '

  FOURBLOCKS DB '1111$'
  SPACE DB '0000$'
  CURRENT DB '....$'
  OVERLAP DB '////$'
  SCORE DB "0000000$"
  POINTS DB "0000000$"
  RESET_SCORE DB "0000000$"
  CARRY DB 0
  

  MODE DW 0 ; 0 = MOVING, 1 = ENCODE
  enter db 10, 13, '$'
  RECORD_STR DB 2000 DUP('$')
  FILEHANDLE    DW ?
;---------------------------------------------
.CODE
openfile MACRO filename, storage
  MOV AH, 3DH           ;requst open file
  MOV AL, 00            ;read
  LEA DX, filename
  INT 21H
  MOV FILEHANDLE, AX

   ;read file
  MOV AH, 3FH           ;request read record
  MOV BX, FILEHANDLE    ;file handle
  MOV CX, 1918         ;record length
  LEA DX, storage    ;address of input area
  INT 21H

  ;close file handle
  MOV AH, 3EH           ;request close file
  MOV BX, FILEHANDLE    ;file handle
  INT 21H
ENDM

WRITE_TO_FILE MACRO FILENAME, STRING
  ;create file
  MOV AH, 3CH           ;request create file
  MOV CX, 00            ;normal attribute
  LEA DX, FILENAME      ;load path and file name
  INT 21H
  MOV FILEHANDLE, AX

  ;write file
  MOV AH, 40H           ;request write record
  MOV BX, FILEHANDLE    ;file handle
  MOV CX, 16            ;record length
  LEA DX, STRING    ;address of output area
  INT 21H

  ;close file handle
  MOV AH, 3EH           ;request close file
  MOV BX, FILEHANDLE    ;file handle
  INT 21H
ENDM

SET_CURSOR MACRO X, Y
  MOV AH, 02H
  MOV BH, 0
  MOV DL, X
  MOV DH, Y
  INT 10H
ENDM

CLEAR_SCREEN MACRO RIGHT, LEFT
  MOV AX, 0600H     ;full screen
  MOV BH, 30H     ;white background (7), blue foreground (1)
  MOV CX, RIGHT   ;upper left row:column (0:0)
  MOV DX, LEFT   ;lower right row:column (24:79)
  INT 10H
ENDM
;------------------------------------------------------
; A macro procedure used for resetting game values. It accepts 
; three parameters: S, D, and length where S and D are strings
; to be loaded into SI and DI, and length (int) is the length of
; the string loaded.
;----------------------------------------------------------
RESET MACRO S, D, LENGTH
  CLD 
  MOV CX, LENGTH
  LEA DI, D
  LEA SI, S
  REP MOVSB
ENDM
;----------------------------------------------------------
;a macro procedure used to delay movement or a game_screen. 
;It accepts a parameter: seconds (int value).
;----------------------------------------------------------
DELAY_SEC MACRO SEC
  LOCAL delay_S

      mov bp, SEC  ;lower value faster
      mov si, SEC  ;lower value faster
    delay_S:
      dec bp
      nop
      jnz delay_S
      dec si
      cmp si,0
      jnz delay_S
      RET
ENDM


MAIN PROC FAR
  MOV AX, @data
  MOV DS, AX
  MOV ES, AX
  CALL TITLE_SCREEN
  CALL EXIT
MAIN ENDP
;----------------------------------------------------------
; a procedure to display the game title of the screen.
;----------------------------------------------------------
TITLE_SCREEN PROC NEAR
  CLEAR_SCREEN 0000H, 184FH
  BLINK:
    openfile  TITLE_SCRN1, RECORD_STR
    SET_CURSOR 0,1
    LEA SI, RECORD_STR
    CALL CONVERT
    CALL TITLE_SCRN_WAITKEY
    SET_CURSOR 22, 41
    CALL DELAY

    openfile  TITLE_SCRN2, RECORD_STR
    SET_CURSOR 0,1
    LEA SI, RECORD_STR
    CALL CONVERT
    CALL TITLE_SCRN_WAITKEY
    SET_CURSOR 22, 41
    CALL DELAY

    openfile  TITLE_SCRN3, RECORD_STR
    SET_CURSOR 0,1
    LEA SI, RECORD_STR
    CALL CONVERT
    CALL TITLE_SCRN_WAITKEY
    SET_CURSOR 22, 41
    CALL DELAY

    openfile  TITLE_SCRN2, RECORD_STR
    SET_CURSOR 0,1
    LEA SI, RECORD_STR
    CALL CONVERT
    CALL TITLE_SCRN_WAITKEY
    SET_CURSOR 22, 41
    CALL DELAY
    JMP BLINK
  RET
TITLE_SCREEN ENDP
;----------------------------------------------------------
; a procedure used to display the main menu of the game
;----------------------------------------------------------
MAIN_MENU_SCREEN PROC NEAR
  CLEAR_SCREEN 0000H, 184FH
  openfile  MAIN_MENU1, RECORD_STR
  SET_CURSOR 0,1
  LEA SI, RECORD_STR
  CALL CONVERT
  MOV MENU_COUNTER, 0
  H:
  CALL MENU_SCRN_WAITKEY
  JMP H
MAIN_MENU_SCREEN ENDP
;----------------------------------------------------------
; a procedure used for displaying the main game where the 
; board and the blocks are located. 
;---------------------------------------------------------
IN_GAME_SCREEN PROC NEAR
  CALL RESET_VALUES
  openfile HIGHSCORE_FILE, CURRENT_HIGHSCORE
  openfile  INGAME,RECORD_STR
  CLEAR_SCREEN 0000H, 184FH
  SET_CURSOR 0,1
  LEA SI, RECORD_STR
  CALL CONVERT
  CALL RANDOM_BLOCK
  MOV AL, NEXT_BLOCK
  MOV CURR_BLOCK, AL
  CALL RANDOM_BLOCK
  MOV MODE, 0
  CALL WRITE
  CALL DECODE
   H1:
    CALL INGAME_WAITkEY
  JMP H1
IN_GAME_SCREEN ENDP
;----------------------------------------------------------
; A procedure for clearing the board from the previous values 
; once the game is over. 
;----------------------------------------------------------
RESET_VALUES PROC NEAR
  RESET EMPTY_GRID, ROW_1 , 11
  RESET EMPTY_GRID, ROW_2 , 11
  RESET EMPTY_GRID, ROW_3 , 11
  RESET EMPTY_GRID, ROW_4 , 11
  RESET EMPTY_GRID, ROW_5 , 11
  RESET EMPTY_GRID, ROW_6 , 11
  RESET EMPTY_GRID, ROW_7 , 11
  RESET EMPTY_GRID, ROW_8 , 11
  RESET EMPTY_GRID, ROW_9 , 11
  RESET EMPTY_GRID, ROW_10 , 11
  RESET RESET_SCORE, SCORE, 8
  RET  
RESET_VALUES ENDP
;----------------------------------------------------------
; A procedure for displaying the How to Play screen of the game
;----------------------------------------------------------
HELP_SCREEN PROC NEAR
  openfile HELP_SCRN, RECORD_STR
  LEA SI, RECORD_STR
  SET_CURSOR 0, 1
  CALL CONVERT
  SET_CURSOR  81, 26
  CALL GET_NAME
  CALL MAIN_MENU_SCREEN
HELP_SCREEN ENDP
;----------------------------------------------------------
; A procedure responsible for displaying the highest score and the name 
; of the player
;----------------------------------------------------------
HIGHSCORE_SCREEN PROC NEAR
  openfile HIGHSCORE_SCRN, RECORD_STR
  LEA SI, RECORD_STR
  SET_CURSOR 0, 1
  CALL CONVERT
  openfile NAME_FILE, INPUT_NAME
  SET_CURSOR 23, 9
  MOV AH, 9
  LEA DX, INPUT_NAME
  INT 21H
  openfile HIGHSCORE_FILE, CURRENT_HIGHSCORE
  SET_CURSOR 55, 9
  MOV AH, 9
  LEA DX, CURRENT_HIGHSCORE
  INT 21H
  SET_CURSOR  81, 26
  CALL GET_NAME
  CALL MAIN_MENU_SCREEN
HIGHSCORE_SCREEN ENDP
;----------------------------------------------------------
;NOT USED, CONSIDER DELETING HSCORE_SCRN_wAITKEY
;----------------------------------------------------------
;HSCORE_SCRN_WAITKEY PROC NEAR
;  MOV     AH, 01H
;  INT     16H
;  JNZ     ENTERED_INPUT3
;  RET
;  ENTERED_INPUT3:
;    MOV     AH, 0H
;    INT     16H
;    CMP     AH, 01H
;    JE      EXIT_HSCORE
;    RET
;  EXIT_HSCORE:
;    CALL MAIN_MENU_SCREEN
;HSCORE_SCRN_WAITKEY ENDP

;----------------------------------------------------------
; The procedure resposible for getting key input from the
; playing while playing the game.
;----------------------------------------------------------
INGAME_WAITkEY PROC NEAR
  MOV     AH, 01H
  INT     16H
  JNZ     ENTERED_INPUT2
  RET
  ENTERED_INPUT2:
    MOV     AH, 0H
    INT     16H
    CMP     AH, 01H
    JE      E
    CMP     AL, 32
    JE      ENTER_BLOCK
    CMP     AH, 48H
    JE      MOVE_UP1
    CMP     AH, 4BH
    JE      MOVE_LEFT
    CMP     AH, 4DH
    JE      MOVE_RIGHT
    CMP     AH, 50H
    JE      MOVE_DOWN1
    RET
  E:
    CALL MAIN_MENU_SCREEN
  MOVE_UP1:
    CMP CURR_X, 1
    JE INVALID
    MOV MODE, 0
    DEC CURR_X
    CALL WRITE
    CALL DECODE
    RET
  MOVE_LEFT:
    CMP CURR_Y, 0
    JE INVALID
    MOV MODE, 0
    DEC CURR_Y
    CALL WRITE
    CALL DECODE
    RET
  MOVE_RIGHT:
    CMP CURR_Y, 9
    JE INVALID
    MOV MODE, 0
    INC CURR_Y
    CALL WRITE
    CALL DECODE
    RET
  MOVE_DOWN1:
    CMP CURR_X, 10
    JE INVALID
    MOV MODE, 0
    INC CURR_X
    CALL WRITE
    CALL DECODE
    RET
  INVALID:
    RET
  ENTER_BLOCK:
    MOV MODE, 0
    CALL CLEAR
    MOV AX, CURR_X
    MOV TEMP_X, AX
    MOV AX, CURR_Y
    MOV TEMP_Y, AX
    CALL IS_FREE_CELL
    CMP FREE_CELL, '0'
    JNE INVALID
    MOV FREE_BLOCK, '1'
    CALL CHECK_BLOCK
    CMP FREE_BLOCK, '0'
    JNE INVALID
    MOV MODE, 1
    CALL WRITE
    CALL CHECK_FULL
    CALL CLEAR
    MOV AL, NEXT_BLOCK
    MOV CURR_BLOCK, AL
    CALL RANDOM_BLOCK
    MOV MODE, 0
    CALL WRITE
    CALL DECODE
    SET_CURSOR 60,19
    MOV AH, 9
    LEA DX, SCORE
    INT 21H
    RET
INGAME_WAITkEY ENDP
;----------------------------------------------------------
; This procedure increments the player's score
; by the number of blocks placed and the number of blocks 
; cleared.
;----------------------------------------------------------
ADD_SCORE PROC NEAR
  MOV CX, 6
  LOOP_ADD_SCORE:
    MOV BX, CX
    MOV AL, SCORE[BX]
    MOV DL, POINTS[BX]
    SUB AL, '0'
    SUB DL, '0'
    ADD AL, DL
    ADD AL, CARRY
    MOV CARRY, 0
    CMP AL, 10
    JL NO_CARRY
    SUB AL, 10
    MOV CARRY, 1
    NO_CARRY:
      ADD AL, '0'
      MOV SCORE[BX], AL
    LOOP LOOP_ADD_SCORE
    RET
ADD_SCORE ENDP
;----------------------------------------------------------
; the procedure responsible for checking whether the row and
; column of the board is full. It also clears the blocks.
;----------------------------------------------------------
CHECK_FULL PROC NEAR
  MOV BX, 0
  CALL CHECK_COLUMN
  MOV BX, 1
  CALL CHECK_COLUMN
  MOV BX, 2
  CALL CHECK_COLUMN
  MOV BX, 3
  CALL CHECK_COLUMN
  MOV BX, 4
  CALL CHECK_COLUMN
  MOV BX, 5
  CALL CHECK_COLUMN
  MOV BX, 6
  CALL CHECK_COLUMN
  MOV BX, 7
  CALL CHECK_COLUMN
  MOV BX, 8
  CALL CHECK_COLUMN
  MOV BX, 9
  CALL CHECK_COLUMN
  LEA SI, ROW_1
  CALL CHECK_ROW
  LEA SI, ROW_2
  CALL CHECK_ROW
  LEA SI, ROW_3
  CALL CHECK_ROW
  LEA SI, ROW_4
  CALL CHECK_ROW
  LEA SI, ROW_5
  CALL CHECK_ROW
  LEA SI, ROW_6
  CALL CHECK_ROW
  LEA SI, ROW_7
  CALL CHECK_ROW
  LEA SI, ROW_8
  CALL CHECK_ROW
  LEA SI, ROW_9
  CALL CHECK_ROW
  LEA SI, ROW_10
  CALL CHECK_ROW
  RET
CHECK_FULL ENDP
;----------------------------------------------------------
; the procedure iterates through every row of the board
; and checks if all cells are full.
;----------------------------------------------------------
CHECK_ROW PROC NEAR
  MOV CX, 10
  LOOP_CHECK_ROW:
    MOV AL, [SI]
    CMP AL, '0'
    JE EXIT_CHECK_ROW
    INC SI
    LOOP LOOP_CHECK_ROW
  SUB SI, 10
  CALL MARK_ROW_FULL
  EXIT_CHECK_ROW:
    RET
CHECK_ROW ENDP
;----------------------------------------------------------
; Procedure resposible for adding the score of any blocks
; that are cleared row by row.
;----------------------------------------------------------
MARK_ROW_FULL PROC NEAR
  MOV CX, 10
  MARK_FULL:
    MOV AL, '.'
    MOV [SI], AL
    INC SI
    LOOP MARK_FULL
  MOV POINTS[5], '1'
  CALL ADD_SCORE
  RET
MARK_ROW_FULL ENDP
;----------------------------------------------------------
; This procedure iterates through every column of the board
; and checks if the cells are full.
;----------------------------------------------------------
CHECK_COLUMN PROC NEAR
  CMP ROW_1[BX], '0'
  JE EXIT_CHECK_COLUMN
  CMP ROW_2[BX], '0'
  JE EXIT_CHECK_COLUMN
  CMP ROW_3[BX], '0'
  JE EXIT_CHECK_COLUMN
  CMP ROW_4[BX], '0'
  JE EXIT_CHECK_COLUMN
  CMP ROW_5[BX], '0'
  JE EXIT_CHECK_COLUMN
  CMP ROW_6[BX], '0'
  JE EXIT_CHECK_COLUMN
  CMP ROW_7[BX], '0'
  JE EXIT_CHECK_COLUMN
  CMP ROW_8[BX], '0'
  JE EXIT_CHECK_COLUMN
  CMP ROW_9[BX], '0'
  JE EXIT_CHECK_COLUMN
  CMP ROW_10[BX], '0'
  JE EXIT_CHECK_COLUMN
  CALL MARK_COLUMN_FULL
  EXIT_CHECK_COLUMN:
    RET
CHECK_COLUMN ENDP
;----------------------------------------------------------
; Procedure resposible for adding the score of any blocks
; that are cleared column by column.
;----------------------------------------------------------
MARK_COLUMN_FULL PROC NEAR
  MOV ROW_1[BX], '.'
  MOV ROW_2[BX], '.'
  MOV ROW_3[BX], '.'
  MOV ROW_4[BX], '.'
  MOV ROW_5[BX], '.'
  MOV ROW_6[BX], '.'
  MOV ROW_7[BX], '.'
  MOV ROW_8[BX], '.'
  MOV ROW_9[BX], '.'
  MOV ROW_10[BX], '.'
  MOV POINTS[5], '1'
  CALL ADD_SCORE
  RET
MARK_COLUMN_FULL ENDP
;----------------------------------------------------------
; this procedure iterates through every row of the board
; and checks whether the cells contains blocks
;----------------------------------------------------------
decode proc near
  lea DI, row_1
  mov CL, 3
  call decode_row
  lea DI, row_2
  mov CL, 5
  call decode_row
  lea DI, row_3
  mov CL, 7
  call decode_row
  lea DI, row_4
  mov CL, 9
  call decode_row
  lea DI, row_5
  mov CL, 11
  call decode_row
  lea DI, row_6
  mov CL, 13
  call decode_row
  lea DI, row_7
  mov CL, 15
  call decode_row
  lea DI, row_8
  mov CL, 17
  call decode_row
  lea DI, row_9
  mov CL, 19
  call decode_row
  lea DI, row_10
  mov CL, 21
  call decode_row
  ret
decode endp
;----------------------------------------------------------
; this procedure permanently places the blocks into the
; board
;----------------------------------------------------------
decode_row proc near
  mov AL, [DI]
  SET_CURSOR 5, CL
  CALL PRINT_B
  INC DI
  MOV AL, [DI]
  SET_CURSOR 10, CL
  CALL PRINT_B
  INC DI
  MOV AL, [DI]
  SET_CURSOR 15, CL
  CALL PRINT_B
  INC DI
  MOV AL, [DI]
  SET_CURSOR 20, CL
  CALL PRINT_B
  INC DI
  MOV AL, [DI]
  SET_CURSOR 25, CL
  CALL PRINT_B
  INC DI
  MOV AL, [DI]
  SET_CURSOR 30, CL
  CALL PRINT_B
  INC DI
  MOV AL, [DI]
  SET_CURSOR 35, CL
  CALL PRINT_B
  INC DI
  MOV AL, [DI]
  SET_CURSOR 40, CL
  CALL PRINT_B
  INC DI
  MOV AL, [DI]
  SET_CURSOR 45, CL
  CALL PRINT_B
  INC DI
  MOV AL, [DI]
  SET_CURSOR 50, CL
  CALL PRINT_B
  RET
decode_row endp
;----------------------------------------------------------
; the procedure used for displaying each block placed into
; the board
;----------------------------------------------------------
print_b proc near
  P_BLOCK:
    CMP AL, '1'
    JNE P_SPACE
    LEA SI, FOURBLOCKS
    JMP EXIT_PRINT_B
  P_SPACE:
    CMP AL, '0'
    JNE P_CURRENT
    LEA SI, SPACE
    JMP EXIT_PRINT_B
  P_CURRENT:
    CMP AL, '.'
    JNE P_OVERLAP
    LEA SI, CURRENT
    JMP EXIT_PRINT_B
  P_OVERLAP:
    LEA SI, OVERLAP
  EXIT_PRINT_B:
    CALL CONVERT
    RET
print_b endp
;----------------------------------------------------------
; This procedure is resposible for  generating random values
; of the blocks to be placed into the board.
;----------------------------------------------------------
RANDOM_BLOCK PROC NEAR
  CALL GET_INDEX  ; BEFORE GETTING THE NEXT RANDOM BLOCK,
                  ; CHECK IF CURRENT BLOCK STILL FITS THE GRID
  MOV AH, 00h  ; interrupts to get system time
  INT 1AH      ; CX:DX now hold number of clock ticks since midnight
  mov  ax, dx
  xor  dx, dx
  mov  cx, 13
  div  cx       ; here dx contains the remainder of the division - from 0 to 9
  add  dl, '0'  ; to ascii from '0' to '9'

  RAND_A:
    cmp DL, '0'
    JNE RAND_B
    openfile BLOCK_A, RECORD_STR
    MOV NEXT_BLOCK, 'A'
    JMP PRINT_RANDOM_BLOCK
  RAND_B:
    cmp DL, '1'
    JNE RAND_C
    openfile BLOCK_B, RECORD_STR
    MOV NEXT_BLOCK, 'B'
    JMP PRINT_RANDOM_BLOCK
  RAND_C:
    cmp DL, '2'
    JNE RAND_D
    openfile BLOCK_C, RECORD_STR
    MOV NEXT_BLOCK, 'C'
    JMP PRINT_RANDOM_BLOCK
  RAND_D:
    cmp DL, '3'
    JNE RAND_E
    openfile BLOCK_D, RECORD_STR
    MOV NEXT_BLOCK, 'D'
    JMP PRINT_RANDOM_BLOCK
  RAND_E:
    cmp DL, '4'
    JNE RAND_F
    openfile BLOCK_E, RECORD_STR
    MOV NEXT_BLOCK, 'E'
    JMP PRINT_RANDOM_BLOCK
  RAND_F:
    cmp DL, '5'
    JNE RAND_G
    openfile BLOCK_F, RECORD_STR
    MOV NEXT_BLOCK, 'F'
    JMP PRINT_RANDOM_BLOCK
  RAND_G:
    cmp DL, '6'
    JNE RAND_H
    openfile BLOCK_G, RECORD_STR
    MOV NEXT_BLOCK, 'G'
    JMP PRINT_RANDOM_BLOCK
  RAND_H:
    cmp DL, '7'
    JNE RAND_I
    openfile BLOCK_H, RECORD_STR
    MOV NEXT_BLOCK, 'H'
    JMP PRINT_RANDOM_BLOCK
  RAND_I:
    cmp DL, '8'
    JNE RAND_J
    openfile BLOCK_I, RECORD_STR
    MOV NEXT_BLOCK, 'I'
    JMP PRINT_RANDOM_BLOCK
  RAND_J:
    cmp DL, '9'
    JNE RAND_K
    openfile BLOCK_J, RECORD_STR
    MOV NEXT_BLOCK, 'J'
    JMP PRINT_RANDOM_BLOCK
  RAND_K:
    cmp DL, ':'
    JNE RAND_L    
    openfile BLOCK_K, RECORD_STR
    MOV NEXT_BLOCK, 'K'
    jmp PRINT_RANDOM_BLOCK
  RAND_L:
    cmp DL, ';'
    JNE RAND_M
    openfile BLOCK_L, RECORD_STR
    MOV NEXT_BLOCK, 'L'
    jmp PRINT_RANDOM_BLOCK
  RAND_M:
    openfile BLOCK_M, RECORD_STR
    MOV NEXT_BLOCK, 'M'
  PRINT_RANDOM_BLOCK:
    ; display the random block
    CLEAR_SCREEN 0000H, 184FH
    SET_CURSOR 0,1
    LEA SI, RECORD_STR
    CALL CONVERT

    ;display the highscore after clear screen
    SET_CURSOR 60, 21
    mov ah, 9
    lea dx, CURRENT_HIGHSCORE
    int 21h
  RET
RANDOM_BLOCK ENDP
;----------------------------------------------------------
; The procedure responsible for placing the current block 
; inside the board.
;----------------------------------------------------------
WRITE PROC NEAR
  CALL CLEAR
  MOV AX, CURR_X
  MOV NEW_X, AX
  MOV TEMP_X, AX
  MOV AX, CURR_Y
  MOV NEW_Y, AX
  MOV TEMP_Y, AX
  W1:
    CMP CURR_BLOCK, 'A'
    JNE W2
    CALL WRITE_BLOCK_A
    RET
  W2:
    CMP CURR_BLOCK, 'B'
    JNE W3
    CALL WRITE_BLOCK_B
    RET
  W3:
    CMP CURR_BLOCK, 'C'
    JNE W4
    CALL WRITE_BLOCK_C
    RET
  W4:
    CMP CURR_BLOCK, 'D'
    JNE W5
    CALL WRITE_BLOCK_D
    RET
  W5:
    CMP CURR_BLOCK, 'E'
    JNE W6
    CALL WRITE_BLOCK_E
    RET
  W6:
    CMP CURR_BLOCK, 'F'
    JNE W7
    CALL WRITE_BLOCK_F
    RET
  W7:
    CMP CURR_BLOCK, 'G'
    JNE W8
    CALL WRITE_BLOCK_G
    RET
  W8:
    CMP CURR_BLOCK, 'H'
    JNE W9
    CALL WRITE_BLOCK_H
    RET
  W9:
    CMP CURR_BLOCK, 'I'
    JNE W10
    CALL WRITE_BLOCK_I
    RET
   W10:
    CMP CURR_BLOCK, 'J'
    JNE W11
    CALL WRITE_BLOCK_J
    RET
  W11:
    CMP CURR_BLOCK, 'K'
    JNE W12
    CALL WRITE_BLOCK_K
    RET
  W12:
    CMP CURR_BLOCK, 'L'
    JNE W13
    CALL WRITE_BLOCK_L
    RET
  W13:
    CMP CURR_BLOCK, 'M'
    JNE EXIT_WRITE_BLOCK
    CALL WRITE_BLOCK_M
    RET
  
  
  EXIT_WRITE_BLOCK:
    RET
WRITE ENDP
;--------------------------------------------------------
; Consists of different procedures for every block and
; determines whether it is possible for the block to be
; placed in a specific cell.
;--------------------------------------------------------

WRITE_BLOCK_L PROC NEAR
  CALL WRITE_TO_STRING
  INC TEMP_Y
  CALL WRITE_TO_STRING
  RET
WRITE_BLOCK_L ENDP


WRITE_BLOCK_M PROC NEAR
  CALL WRITE_TO_STRING
  RET
WRITE_BLOCK_M ENDP


WRITE_BLOCK_A PROC NEAR
  CALL WRITE_TO_STRING
  INC TEMP_X
  CALL WRITE_TO_STRING
  RET
WRITE_BLOCK_A ENDP


WRITE_BLOCK_B PROC NEAR
  CALL WRITE_TO_STRING
  INC TEMP_Y
  CALL WRITE_TO_STRING
  MOV AX, NEW_Y
  MOV TEMP_Y, AX
  INC TEMP_X
  CALL WRITE_TO_STRING
  INC TEMP_Y
  CALL WRITE_TO_STRING
  RET
WRITE_BLOCK_B ENDP

WRITE_BLOCK_C PROC NEAR
  CALL WRITE_TO_STRING
  INC TEMP_X
  CALL WRITE_TO_STRING
  INC TEMP_Y
  CALL WRITE_TO_STRING
  RET
WRITE_BLOCK_C ENDP

WRITE_BLOCK_D PROC NEAR
  CALL WRITE_TO_STRING
  INC TEMP_X
  CALL WRITE_TO_STRING
  DEC TEMP_Y
  CALL WRITE_TO_STRING
  RET
WRITE_BLOCK_D ENDP

WRITE_BLOCK_E PROC NEAR
  CALL WRITE_TO_STRING
  INC TEMP_X
  CALL WRITE_TO_STRING
  INC TEMP_X
  CALL WRITE_TO_STRING
  INC TEMP_Y
  CALL WRITE_TO_STRING
  INC TEMP_Y
  CALL WRITE_TO_STRING
  RET
WRITE_BLOCK_E ENDP

WRITE_BLOCK_F PROC NEAR
  CALL WRITE_TO_STRING
  INC TEMP_X
  CALL WRITE_TO_STRING
  INC TEMP_X
  CALL WRITE_TO_STRING
  DEC TEMP_Y
  CALL WRITE_TO_STRING
  DEC TEMP_Y
  CALL WRITE_TO_STRING
  RET
WRITE_BLOCK_F ENDP

WRITE_BLOCK_G PROC NEAR
  CALL WRITE_TO_STRING
  INC TEMP_Y
  CALL WRITE_TO_STRING
  DEC TEMP_Y
  INC TEMP_X
  CALL WRITE_TO_STRING
  RET
WRITE_BLOCK_G ENDP

WRITE_BLOCK_H PROC NEAR
  CALL WRITE_TO_STRING
  INC TEMP_Y
  CALL WRITE_TO_STRING
  INC TEMP_X
  CALL WRITE_TO_STRING
  RET
WRITE_BLOCK_H ENDP

WRITE_BLOCK_I PROC NEAR
  CALL WRITE_TO_STRING
  INC TEMP_Y
  CALL WRITE_TO_STRING
  INC TEMP_Y
  CALL WRITE_TO_STRING
  SUB TEMP_Y, 2
  INC TEMP_X
  CALL WRITE_TO_STRING
  INC TEMP_X
  CALL WRITE_TO_STRING
  RET
WRITE_BLOCK_I ENDP


WRITE_BLOCK_J PROC NEAR
  CALL WRITE_TO_STRING
  INC TEMP_Y
  CALL WRITE_TO_STRING
  INC TEMP_Y
  CALL WRITE_TO_STRING
  INC TEMP_X
  CALL WRITE_TO_STRING
  INC TEMP_X
  CALL WRITE_TO_STRING
  RET
WRITE_BLOCK_J ENDP

WRITE_BLOCK_K PROC NEAR
  MOV CX, 3
  LOOP_WRITE_K:
    CALL WRITE_TO_STRING
    INC TEMP_Y
    CALL WRITE_TO_STRING
    INC TEMP_Y
    CALL WRITE_TO_STRING
    SUB TEMP_Y, 2
    INC TEMP_X
    LOOP LOOP_WRITE_K
  RET
WRITE_BLOCK_K ENDP
;--------------------------------------------------------
; Responsible for checking for ?
;--------------------------------------------------------
WRITE_TO_STRING PROC NEAR
  CMP TEMP_X, 10
  JLE CHECK_RIGHT_Y
  RET
  CHECK_RIGHT_Y:
    CMP TEMP_Y, 10
    JL CHECK_LEFT_Y
  RET
  CHECK_LEFT_Y:
    CMP TEMP_Y, 0
    JGE ROW1
  RET
  ROW1:
    CMP TEMP_X, 1
    JNE ROW2
    LEA SI, ROW_1
    JMP W
  ROW2:
    CMP TEMP_X, 2
    JNE ROW3
    LEA SI, ROW_2
    JMP W
  ROW3:
    CMP TEMP_X, 3
    JNE ROW4
    LEA SI, ROW_3
    JMP W
  ROW4:
    CMP TEMP_X, 4
    JNE ROW5
    LEA SI, ROW_4
    JMP W
  ROW5:
    CMP TEMP_X, 5
    JNE ROW6
    LEA SI, ROW_5
    JMP W
  ROW6:
    CMP TEMP_X, 6
    JNE ROW7
    LEA SI, ROW_6
    JMP W
  ROW7:
    CMP TEMP_X, 7
    JNE ROW8
    LEA SI, ROW_7
    JMP W
  ROW8:
    CMP TEMP_X, 8
    JNE ROW9
    LEA SI, ROW_8
    JMP W
  ROW9:
    CMP TEMP_X, 9
    JNE ROW10
    LEA SI, ROW_9
    JMP W
  ROW10:
    LEA SI, ROW_10
  W:
    ADD SI, TEMP_Y
    CMP MODE, 0
    JE MOVING
    MOV AL, '1'
    MOV [SI], AL
    PUSH CX
    MOV POINTS[5], '0'
    MOV POINTS[6], '1'
    CALL ADD_SCORE
    MOV POINTS[0], '0'
    POP CX
    RET
    MOVING:
      MOV AL, [SI]
      SUB AL, 2
      MOV [SI], AL
  RET
WRITE_TO_STRING ENDP
;--------------------------------------------------------
; Resets the values of each rows  of the board
;--------------------------------------------------------
CLEAR PROC NEAR
  LEA SI, ROW_1
  CALL CLEAR_ROW
   LEA SI, ROW_2
  CALL CLEAR_ROW
  LEA SI, ROW_3
  CALL CLEAR_ROW
  LEA SI, ROW_4
  CALL CLEAR_ROW
  LEA SI, ROW_5
  CALL CLEAR_ROW
  LEA SI, ROW_6
  CALL CLEAR_ROW
  LEA SI, ROW_7
  CALL CLEAR_ROW
  LEA SI, ROW_8
  CALL CLEAR_ROW
  LEA SI, ROW_9
  CALL CLEAR_ROW
  LEA SI, ROW_10
  CALL CLEAR_ROW
  RET
CLEAR ENDP
;--------------------------------------------------------
; clears the values of a specific row
;--------------------------------------------------------
CLEAR_ROW PROC NEAR
  MOV CX, 10
  ITER_COLUMN:
    MOV AL, [SI]
    CMP AL, '0'
    JGE IGNORE
    ADD AL, 2
    MOV [SI], AL
    IGNORE:
      INC SI
    LOOP ITER_COLUMN
  EXIT_CLEAR_ROW:
    RET
CLEAR_ROW ENDP
;--------------------------------------------------------
; checks if the cells already contains blocks
;--------------------------------------------------------
GET_INDEX PROC NEAR
  MOV NEW_X, 1
  MOV NEW_Y, 0
  MOV TEMP_X, 1
  MOV TEMP_Y, 0
  MOV CX, 11
  LOOP_INDEX:
    CMP CX, 1
    JNE CONTINUE
    CMP TEMP_X, 10
    JE CONTINUE
    INC TEMP_X
    INC NEW_X
    MOV TEMP_Y, 0
    MOV CX, 11
    CONTINUE:
      CALL IS_FREE_CELL
      CMP FREE_CELL, '0'
      JG NOT_FREE
      MOV AX, TEMP_Y
      MOV NEW_Y, AX
      PUSH CX
      CALL CHECK_BLOCK
      POP CX
      CMP FREE_BLOCK, '0'
      JE EXIT_INDEX
    NOT_FREE:
      INC TEMP_Y
    LOOP LOOP_INDEX
  CALL GAME_OVER
  CALL MAIN_MENU_SCREEN
  EXIT_INDEX:
    MOV AX, NEW_X
    MOV CURR_X, AX
    MOV AX, NEW_Y
    MOV CURR_Y, AX
    RET
GET_INDEX ENDP
;--------------------------------------------------------
; Checks the value of the current block
;--------------------------------------------------------
CHECK_BLOCK PROC NEAR
  B1:
    CMP CURR_BLOCK, 'A'
    JNE B2
    CALL CHECK_BLOCK_A
    RET
  B2:
    CMP CURR_BLOCK, 'B'
    JNE B3
    CALL CHECK_BLOCK_B
    RET
  B3:
    CMP CURR_BLOCK, 'C'
    JNE B4
    CALL CHECK_BLOCK_C
    RET
  B4:
    CMP CURR_BLOCK, 'D'
    JNE B5
    CALL CHECK_BLOCK_D
    RET
  B5:
    CMP CURR_BLOCK, 'E'
    JNE B6
    CALL CHECK_BLOCK_E
    RET
  B6:
    CMP CURR_BLOCK, 'F'
    JNE B7
    CALL CHECK_BLOCK_F
    RET
  B7:
    CMP CURR_BLOCK, 'G'
    JNE B8
    CALL CHECK_BLOCK_G
    RET
  B8:
    CMP CURR_BLOCK, 'H'
    JNE B9
    CALL CHECK_BLOCK_H
    RET
  B9:
    CMP CURR_BLOCK, 'I'
    JNE B10
    CALL CHECK_BLOCK_I
    RET
  B10:
    CMP CURR_BLOCK, 'J'
    JNE B11
    CALL CHECK_BLOCK_J
    RET
  B11:
    CMP CURR_BLOCK, 'K'
    JNE B12
    CALL CHECK_BLOCK_K
    RET
  B12:
    CMP CURR_BLOCK, 'L'
    JNE B13
    CALL CHECK_BLOCK_L
    RET
  B13: 
    MOV FREE_BLOCK, '0'
  
  EXIT_CHECK_BLOCK:
    RET
CHECK_BLOCK ENDP
;--------------------------------------------------------
; CHECK ALL THE BLOCKS IF IT COLLIDES WITH ANOTHER BLOCK
;--------------------------------------------------------
CHECK_BLOCK_L PROC NEAR
  INC TEMP_Y
  CMP TEMP_Y, 10
  JE BLOCK_L_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_L_UNFIT
  MOV FREE_BLOCK, '0'
  RET
  BLOCK_L_UNFIT:
    CALL UNFIT
    RET
CHECK_BLOCK_L ENDP
CHECK_BLOCK_A PROC NEAR
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_A_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_A_UNFIT
  MOV FREE_BLOCK, '0'
  RET
  BLOCK_A_UNFIT:
    CALL UNFIT
    RET
CHECK_BLOCK_A ENDP
CHECK_BLOCK_B PROC NEAR
  INC TEMP_Y
  CMP TEMP_Y, 10
  JE BLOCK_B_UNFIT
  CALL  IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_B_UNFIT
  MOV AX, NEW_Y
  MOV TEMP_Y,AX
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_B_UNFIT
  CALL  IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_B_UNFIT
  INC TEMP_Y
  CMP TEMP_Y, 10
  JE BLOCK_B_UNFIT
  CALL  IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_B_UNFIT
  MOV FREE_BLOCK, '0'
  RET
  BLOCK_B_UNFIT:
    CALL UNFIT
    RET
CHECK_BLOCK_B ENDP
CHECK_BLOCK_C PROC NEAR
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_C_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_C_UNFIT
  INC TEMP_Y
  CMP TEMP_Y, 10
  JE BLOCK_C_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_C_UNFIT
  MOV FREE_BLOCK, '0'
  RET
  BLOCK_C_UNFIT:
    CALL UNFIT
    RET
CHECK_BLOCK_C ENDP
CHECK_BLOCK_D PROC NEAR
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_D_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_D_UNFIT
  DEC TEMP_Y
  CMP TEMP_Y, 0
  JL BLOCK_D_UNFIT
  CMP TEMP_Y, 0
  JL BLOCK_D_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_D_UNFIT
  MOV FREE_BLOCK, '0'
  RET
  BLOCK_D_UNFIT:
    CALL UNFIT
    RET
CHECK_BLOCK_D ENDP
CHECK_BLOCK_E PROC NEAR
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_E_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_E_UNFIT
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_E_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_E_UNFIT
  INC TEMP_Y
  CMP TEMP_Y, 10
  JE BLOCK_E_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_E_UNFIT
  INC TEMP_Y
  CMP TEMP_Y, 10
  JE BLOCK_E_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_E_UNFIT
  MOV FREE_BLOCK, '0'
  RET
  BLOCK_E_UNFIT:
    CALL UNFIT
    RET
CHECK_BLOCK_E ENDP
CHECK_BLOCK_F PROC NEAR
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_F_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_F_UNFIT
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_F_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_F_UNFIT
  DEC TEMP_Y
  CMP TEMP_Y, 0
  JL BLOCK_F_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_F_UNFIT
  DEC TEMP_Y
  CMP TEMP_Y, 0
  JL BLOCK_F_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_E_UNFIT
  MOV FREE_BLOCK, '0'
  RET
  BLOCK_F_UNFIT:
    CALL UNFIT
    RET
CHECK_BLOCK_F ENDP
CHECK_BLOCK_G PROC NEAR
  INC TEMP_Y
  CMP TEMP_Y, 10
  JE BLOCK_G_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_G_UNFIT
  MOV AX, NEW_Y
  MOV TEMP_Y, AX
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_G_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_G_UNFIT
  MOV FREE_BLOCK, '0'
  RET
  BLOCK_G_UNFIT:
    CALL UNFIT
    RET
CHECK_BLOCK_G ENDP
CHECK_BLOCK_H PROC NEAR
  INC TEMP_Y
  CMP TEMP_Y, 10
  JE BLOCK_G_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_H_UNFIT
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_H_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_H_UNFIT
  MOV FREE_BLOCK, '0'
  RET
  BLOCK_H_UNFIT:
    CALL UNFIT
    RET
CHECK_BLOCK_H ENDP
CHECK_BLOCK_I PROC NEAR
  INC TEMP_Y
  CMP TEMP_Y, 10
  JE BLOCK_I_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_I_UNFIT
  INC TEMP_Y
  CMP TEMP_Y, 10
  JE BLOCK_I_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_I_UNFIT
  MOV AX, NEW_Y
  MOV TEMP_Y, AX
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_I_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_I_UNFIT
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_I_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_I_UNFIT
  MOV FREE_BLOCK, '0'
  RET
  BLOCK_I_UNFIT:
    CALL UNFIT
    RET
CHECK_BLOCK_I ENDP
CHECK_BLOCK_J PROC NEAR
  INC TEMP_Y
  CMP TEMP_Y, 10
  JE BLOCK_J_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_J_UNFIT
  INC TEMP_Y
  CMP TEMP_Y, 10
  JE BLOCK_J_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_J_UNFIT
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_J_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_J_UNFIT
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_J_UNFIT
  CALL IS_FREE_CELL
  CMP FREE_CELL, '0'
  JNE BLOCK_J_UNFIT
  MOV FREE_BLOCK, '0'
  RET
  BLOCK_J_UNFIT:
    CALL UNFIT
    RET
CHECK_BLOCK_J ENDP

CHECK_BLOCK_K PROC NEAR
  MOV CX, 2
  LOOP_K1:
    INC TEMP_Y
    CMP TEMP_Y, 10
    JE BLOCK_K_UNFIT
    CALL IS_FREE_CELL
    CMP FREE_CELL, '0'
    JNE BLOCK_K_UNFIT
    LOOP LOOP_K1
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_K_UNFIT
  MOV AX, NEW_Y
  MOV TEMP_Y, AX
  MOV CX, 3
  LOOP_K2:
    CMP TEMP_Y, 10
    JE BLOCK_K_UNFIT
    CALL IS_FREE_CELL
    CMP FREE_CELL, '0'
    JNE BLOCK_K_UNFIT
    INC TEMP_Y
    LOOP LOOP_K2
  INC TEMP_X
  CMP TEMP_X, 10
  JG BLOCK_K_UNFIT
  MOV AX, NEW_Y
  MOV TEMP_Y, AX
  MOV CX, 3
  LOOP_K3:
    CMP TEMP_Y, 10
    JE BLOCK_K_UNFIT
    CALL IS_FREE_CELL
    CMP FREE_CELL, '0'
    JNE BLOCK_K_UNFIT
    INC TEMP_Y
    LOOP LOOP_K3
  MOV FREE_BLOCK, '0'
  RET
  BLOCK_K_UNFIT:
    CALL UNFIT
    RET
CHECK_BLOCK_K ENDP

;--------------------------------------------------------
; Assigns a value into memory whenever there is an available
; space in a cell
;--------------------------------------------------------
UNFIT PROC NEAR
  MOV AX, NEW_Y
  MOV TEMP_Y,AX
  MOV AX, NEW_X
  MOV TEMP_X, AX
  MOV FREE_BLOCK, '1'
  RET
UNFIT ENDP

;;-------------------------------------------------------
; checks whether cells are free
;--------------------------------------------------------
IS_FREE_CELL PROC NEAR
  MOV BX, TEMP_Y
  C1:
    CMP TEMP_X, 1
    JNE C2
    MOV BX, TEMP_Y
    MOV DL, ROW_1[BX]
    MOV FREE_CELL, DL
    RET
  C2:
    CMP TEMP_X, 2
    JNE C3
    MOV DL, ROW_2[BX]
    MOV FREE_CELL, DL
    RET
  C3:
    CMP TEMP_X, 3
    JNE C4
    MOV DL, ROW_3[BX]
    MOV FREE_CELL, DL
    RET
  C4:
    CMP TEMP_X, 4
    JNE C5
    MOV DL, ROW_4[BX]
    MOV FREE_CELL, DL
    RET
  C5:
    CMP TEMP_X, 5
    JNE C6
    MOV DL, ROW_5[BX]
    MOV FREE_CELL, DL
    RET
  C6:
    CMP TEMP_X, 6
    JNE C7
    MOV DL, ROW_6[BX]
    MOV FREE_CELL, DL
    RET
  C7:
    CMP TEMP_X, 7
    JNE C8
    MOV DL, ROW_7[BX]
    MOV FREE_CELL, DL
    RET
  C8:
    CMP TEMP_X, 8
    JNE C9
    MOV DL, ROW_8[BX]
    MOV FREE_CELL, DL
    RET
  C9:
    CMP TEMP_X, 9
    JNE C10
    MOV DL, ROW_9[BX]
    MOV FREE_CELL, DL
    RET
  C10:
    MOV DL, ROW_10[BX]
    MOV FREE_CELL, DL
    RET
IS_FREE_CELL ENDP
;--------------------------------------------------------
; Displays the Game Over screen of the game
;--------------------------------------------------------
GAME_OVER PROC NEAR
  CALL DELAY
  CLEAR_SCREEN 0000H, 184FH
  CALL COMPARE_SCORE
  openfile GAME_OVER_SCRN, RECORD_STR
  LEA SI, RECORD_STR
  SET_CURSOR 0, 1
  CALL CONVERT
  DELAY_SEC 30
  RET
GAME_OVER ENDP
;--------------------------------------------------------
; Checks whether the current score is the new highscore
;--------------------------------------------------------
COMPARE_SCORE PROC NEAR
  MOV CX, 6
  LEA SI, CURRENT_HIGHSCORE
  LEA DI, SCORE
  INC SI
  INC DI
  LOOP_COMPARE:
    MOV AL, [SI]
    MOV AH, [DI]
    CMP AL, AH
    JL NEW_HIGHSCORE; NEW HIGHSCORE
    JG EXIT_COMPARE ; CURRENT HIGHSCORE IS GREATER THAN SCORE
    INC SI
    INC DI
    LOOP LOOP_COMPARE
  ; CURRENT HIGHSCORE IS EQUAL SCORE. DO NOTHING
  EXIT_COMPARE:
    RET  
  NEW_HIGHSCORE:
    WRITE_TO_FILE HIGHSCORE_FILE, SCORE
    openfile NEW_HIGHSCORE_SCRN, RECORD_STR
    SET_CURSOR 0, 1
    LEA SI, RECORD_STR
    CALL CONVERT
    SET_CURSOR 40, 15
    LEA DX, INPUT_NAME
    CALL GET_NAME
    RESET INPUT_NAME, NAME_HIGHSCORE, AX
    MOV BX, AX
    MOV INPUT_NAME[BX], '$'
    WRITE_TO_FILE NAME_FILE, INPUT_NAME
    DELAY_SEC 20  
    CLEAR_SCREEN 0000H, 184FH
  RET
COMPARE_SCORE ENDP

;--------------------------------------------------------
; gets the input for the highscore screen as well as additional
; key controls of the game
;--------------------------------------------------------
GET_NAME PROC NEAR
  MOV AH, 3FH
  MOV BX, 00
  MOV CX, 18
  INT 21H
  RET
GET_NAME ENDP

;--------------------------------------------------------
; Used for controlling the main menu screen
;--------------------------------------------------------
MENU_SCRN_WAITKEY PROC NEAR
  MOV     AH, 01H
  INT     16H
  JNZ     ENTERED_INPUT1
  RET
  ENTERED_INPUT1:
    MOV AH, 0H
    INT 16H
    CMP AH, 01H
    JE EXIT_2
    CMP AH, 48H
    JE MOVE_UP
    CMP AH, 50H
    JE MOVE_DOWN
    CMP AL, 13
    JE GO_TO_MENU
    JMP RETURN
    GO_TO_MENU:
      CMP MENU_COUNTER, 0
      JE GAME
      CMP MENU_COUNTER, 1
      JE HIGHSCR
      CMP MENU_COUNTER, 2
      JE HELP
      CALL EXIT
    GAME:
      CALL IN_GAME_SCREEN
    HIGHSCR:
      CALL HIGHSCORE_SCREEN
    HELP:
      CALL HELP_SCREEN
    MOVE_UP:
      CMP MENU_COUNTER, 0
      JE RETURN
      SUB MENU_COUNTER, 1
      JMP REFRESH
    MOVE_DOWN:
      CMP MENU_COUNTER, 3
      JE RETURN
      ADD MENU_COUNTER, 1
      JMP REFRESH
    EXIT_2:
      CALL EXIT
    RETURN:
      RET
    REFRESH:
      CMP MENU_COUNTER, 0
      JE NEW_GAME
      CMP MENU_COUNTER, 1
      JE HIGHSCORE
      CMP MENU_COUNTER, 2
      JE HOW_TO_PLAY
      CMP MENU_COUNTER, 3
      JE QUIT
    NEW_GAME:
      openfile MAIN_MENU1, RECORD_STR
      JMP DISPLAY
    HIGHSCORE:
      openfile MAIN_MENU2, RECORD_STR
      JMP DISPLAY
    HOW_TO_PLAY:
      openfile MAIN_MENU3, RECORD_STR
      JMP DISPLAY
    QUIT:
      openfile MAIN_MENU4, RECORD_STR
      JMP DISPLAY
    DISPLAY:
      SET_CURSOR 0,1
      LEA SI, RECORD_STR
      CALL CONVERT
    RET
MENU_SCRN_WAITKEY ENDP

;--------------------------------------------------------
; Used for getting the player input inside the title screen
; of the game
;--------------------------------------------------------
TITLE_SCRN_WAITKEY PROC NEAR
  MOV     AH, 01H
  INT     16H
  JNZ     ENTERED_INPUT
  RET
  ENTERED_INPUT:
    MOV AH, 0H
    INT 16H
    CMP AH, 01H
    JE EXIT_1
    CMP AL, 13
    JE GO_MENU
    RET
    GO_MENU:
      CALL MAIN_MENU_SCREEN
    EXIT_1:
      CALL EXIT
TITLE_SCRN_WAITKEY ENDP

EXIT PROC NEAR
  MOV     AX, 4C00H
  INT     21H
EXIT ENDP
;-------------------------------------------------------
; used for displaying extended ascii values for every 
; screen by reading a set of values inside a .txt file.
;--------------------------------------------------------
CONVERT PROC NEAR
  ITERATE:
    MOV AL, [SI]

    CMP AL, '$'
    JE EXIT_CONVERT

    MOV AH, 2
    CMP AL, '1'
    JE PRINT_1
    CMP AL, '2'
    JE PRINT_2
    CMP AL, '3'
    JE PRINT_3
    CMP AL, '4'
    JE PRINT_4
    CMP AL, '5'
    JE PRINT_5
    CMP AL, '6'
    JE PRINT_6
    CMP AL, '7'
    JE PRINT_7
    CMP AL, '8'
    JE PRINT_8
    CMP AL, '9'
    JE PRINT_9
    CMP AL, '#'
    JE PRINT_10
    CMP AL, '&'
    JE PRINT_11
    CMP AL, '%'
    JE PRINT_12
    CMP AL, '0'
    JE PRINT_BLANK
    CMP AL, '.'
    JE PRINT_CURRENT
    CMP AL, '/'
    JE PRINT_OVERLAP
    ITER:
      MOV DL, AL
      INT 21H
      INC SI
      JMP ITERATE
    EXIT_CONVERT:
      RET
    PRINT_1:
      MOV AL, 219
      JMP ITER
    PRINT_2:
      MOV AL, 220
      JMP ITER
    PRINT_3:
      MOV AL, 223
      JMP ITER
    PRINT_4:
      MOV AL, 179
      JMP ITER
    PRINT_5:
      MOV AL, 218
      JMP ITER
    PRINT_6:
      MOV AL, 191
      JMP ITER
    PRINT_7:
      MOV AL, 217
      JMP ITER
    PRINT_8:
      MOV AL, 192
      JMP ITER
    PRINT_9:
      MOV AL, 193
      JMP ITER
    PRINT_10:
      MOV AL, 194
      JMP ITER
    PRINT_11:
      MOV AL, 197
      JMP ITER
    PRINT_12:
      MOV AL, 196
      JMP ITER
    PRINT_BLANK:
      MOV AL, ' '
      JMP ITER
    PRINT_CURRENT:
      MOV AL, 178
      JMP ITER
    PRINT_OVERLAP:
      MOV AL, 176
      JMP ITER

CONVERT ENDP
;;--------------------------------------------------------
; A different procedure of Delaying
;--------------------------------------------------------
DELAY PROC NEAR
      mov bp, 10  ;lower value faster
      mov si, 10  ;lower value faster
    delay2:
      dec bp
      nop
      jnz delay2
      dec si
      cmp si,0
      jnz delay2
      RET
DELAY ENDP
END MAIN
