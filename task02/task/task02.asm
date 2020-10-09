format PE console

include 'win32a.inc'

entry start

section '.data' data readable writable

        strEnterArrSize db 'Enter size of the array: ', 0
        strIncorSize    db '%d - incorrect size of vector!', 10, 0
        strArrElemIn    db '[%d] = ', 0
        strScanInt      db '%d', 0
        strArrBracketS  db '[', 0
        strArrBracketE  db ']', 10, 0
        strDigit        db '%d, ', 0
        strArrA         db 'Array A: ', 0
        strArrB         db 'Array B: ', 0

        sizeOfArrA      dd 0
        sizeOfArrB      dd 0
        arrA            rd 100
        arrB            rd 100
        firstElemA      dd ?
        lastElemA       dd ?
        i               dd ?
        tmp             dd ?
        tmpB            dd ?
        stackPointer    dd ?

        NULL = 0


section '.code' code readable executable

;======================MAIN=================
        start:
                push strEnterArrSize
                call [printf]

                ;��������� ������ �������
                push sizeOfArrA
                push strScanInt
                call [scanf]

                ;��������� ������������ ������� �������
                mov  eax, [sizeOfArrA]
                cmp  eax, 0
                jle   incorrectSize

                cmp  eax, 100
                jg  incorrectSize

                ;��������� ������ �
                push [sizeOfArrA]
                push arrA
                call readArr

                ;������� ������ B ��� ��������� ������
                ;������� � ���������� ��������� ������� �
                push [sizeOfArrA]
                push arrA
                push arrB
                call createArrWithoutFirstLast

                ;������� ������ �
                push strArrA
                call [printf]

                push [sizeOfArrA]
                push arrA
                call printArr

                ;������� ������ �
                push strArrB
                call [printf]

                push [sizeOfArrB]
                push arrB
                call printArr

                jmp finish

        incorrectSize:
                ;�������� ���� ������� �������
                push [sizeOfArrA]
                push strIncorSize
                call [printf]

        finish:
                ;��������� ���������
                call [getch]

                push NULL
                call ExitProcess
;======================MAIN=================


;====================READ_ARR===============
        readArr:
                ;��������� �� ������ ������� ��������,
                ;������� ��������� �� �������� � �����
                push eax
                mov  eax, esp ;��������� �������� ��������� ����� � eax
                push ecx
                push edx

                xor  ecx, ecx ;ecx = 0
                mov  edx, [ss:eax+8+0] ; �������� ������ �� ������ � edx

        inputArrLoop:
                ;��������� �������� ��������� � ���������� �� �������
                mov  [stackPointer], eax
                mov  [tmp], edx
                mov  [i], ecx

                ;��������� �������� �������
                cmp  ecx, [ss:eax+8+4]
                jge  endInputArrLoop

                ;��������� �������
                push ecx
                push strArrElemIn
                call [printf]
                ;printf ������ ���� ��������

                push [tmp]
                push strScanInt
                call [scanf]
                ;scanf ���� ������ ��������

                ;��������������� �������� ����� printf � scanf,
                ;����������� ������� � ��������� � ����������
                ;�������� �������
                mov  ecx, [i]
                inc  ecx
                mov  edx, [tmp]
                add  edx, 4
                mov  eax, [stackPointer]
                jmp  inputArrLoop

        endInputArrLoop:
                ;�������� ��������� ����� �� 2 ������� �����
                sub  eax, 8
                mov  esp, eax
                ;���������� ��������� �� ��������
                pop  edx
                pop  ecx
                pop  eax

        ret
;======================READ_ARR============


;==============ARR_WITHOUT_FIRST_LAST=======

        createArrWithoutFirstLast:
                ;��������� �� ������ ������� ��������,
                ;������� ��������� �� �������� � �����
                push eax
                mov  eax, esp ;��������� �������� ��������� ����� � eax
                push ecx
                push edx
                push ebx

                mov  edx, [ss:eax+8+4] ;���������� � edx ������ �� ������ ������
                mov  ebx, [ss:eax+8+0] ;���������� � edx ������ �� ������ ������

                ;�������� �������� ������� �������� ������� �������
                mov  ecx, [edx]
                mov  [firstElemA], ecx

                ;�������� ��������� ������� ������� ������� �������
                mov  ecx, [ss:eax+8+8] ;�������� ������ ������� ������� � ecx
                mov  ecx, [edx+(ecx-1)*4] ;�������� � ecx �������� ���������� ��������
                mov  [lastElemA], ecx

                xor  ecx, ecx ;ecx = 0

        arrWithoutFirstLastLoop:
                ;��������� �������� ��������� � ���������� �� �������
                mov  [tmp], edx
                mov  [tmpB], ebx
                mov  [i], ecx

                ;��������� �� ��������� �� ��� ������� (� ������ ������ ������� ecx)
                ;������ �������
                cmp  ecx, [ss:eax+8+8]
                jge  endArrWithoutFirstLastLoop

                ;�������� �� ��������� ���������� ��� ������� ��������
                mov  ecx, [firstElemA]
                cmp  [edx], ecx
                je  nextElemArrA

                mov  ecx, [lastElemA]
                cmp  [edx], ecx
                je  nextElemArrA

                ;���������� ������� ������� A � ������ B
                mov  ecx, [edx]
                mov  [ebx], ecx

                ;�������� ��������� ������� B �� 1 ������� ������
                add  ebx, 4
                inc  [sizeOfArrB]

        nextElemArrA:
                ;��������� � ���������� �������� ������� A
                mov  ecx, [i]
                inc  ecx
                add  edx, 4
                jmp  arrWithoutFirstLastLoop


        endArrWithoutFirstLastLoop:
                ;�������� ��������� ����� �� 3 ������� �����
                sub  eax, 12
                mov  esp, eax

                ;���������� ��������� �� �������� �� �������������
                ;���������
                pop  ebx
                pop  edx
                pop  ecx
                pop  eax

        ret

;================ARR_WITHOUT_FIRST_LAST======


;=====================PRINT_ARR==============

        printArr:

                ;��������� �� ������ ������� ��������,
                ;������� ��������� �� �������� � �����
                push eax
                mov  eax, esp ;��������� �������� ��������� ����� � eax
                push ecx
                push edx

                ;��������� ������� eax
                mov  [stackPointer], eax

                push strArrBracketS
                call [printf]

                ;printf �������� ��������, ������� ��������������� ��
                mov  eax, [stackPointer]

                xor  ecx, ecx ;ecx = 0
                mov  edx, [ss:eax+8+0] ;���������� ������ �� ������ � edx

        printArrLoop:
                ;��������� �������� ��������� � ����������
                mov  [tmp], edx
                mov  [i], ecx

                cmp  ecx, [ss:eax+8+4];���������� ����� ������� � ecx, ������ �������� ��� �������
                jge  endPrintArrLoop

                mov  ecx, [edx]
                push ecx
                push strDigit
                call [printf]

                ;����� �� ��������������� �������� ��������� ��� ���
                ;����� printf ��� �����������
                mov  edx, [tmp]
                add  edx, 4
                mov  ecx, [i]
                inc  ecx
                mov  eax, [stackPointer]
                jmp  printArrLoop

        endPrintArrLoop:
                ;������� ������ ������
                push strArrBracketE
                call [printf]

                ;��������������� �������� �������� eax ����� printf
                mov  eax, [stackPointer]

                ;�������� ��������� ���� �� ��� ������� �����
                sub  eax, 8
                mov  esp, eax
                ;���������� ��������� �� �������� �� �������������
                ;���������
                pop  edx
                pop  ecx
                pop  eax

        ret

;======================PRINT================


section '.idata' data readable import

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess'

        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'