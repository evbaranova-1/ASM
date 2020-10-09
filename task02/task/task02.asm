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

                ;считываем размер массива
                push sizeOfArrA
                push strScanInt
                call [scanf]

                ;проверяем корректность размера массива
                mov  eax, [sizeOfArrA]
                cmp  eax, 0
                jle   incorrectSize

                cmp  eax, 100
                jg  incorrectSize

                ;считываем массив А
                push [sizeOfArrA]
                push arrA
                call readArr

                ;создаем массив B без элементов равных
                ;первому и последнему элементам массива А
                push [sizeOfArrA]
                push arrA
                push arrB
                call createArrWithoutFirstLast

                ;выводим массив А
                push strArrA
                call [printf]

                push [sizeOfArrA]
                push arrA
                call printArr

                ;Выводим массив В
                push strArrB
                call [printf]

                push [sizeOfArrB]
                push arrB
                call printArr

                jmp finish

        incorrectSize:
                ;Неверный ввод размера массива
                push [sizeOfArrA]
                push strIncorSize
                call [printf]

        finish:
                ;завершаем программу
                call [getch]

                push NULL
                call ExitProcess
;======================MAIN=================


;====================READ_ARR===============
        readArr:
                ;процедура не должна портить регистры,
                ;поэтому сохраняем их значения в стеке
                push eax
                mov  eax, esp ;сохраняем значение указателя стека в eax
                push ecx
                push edx

                xor  ecx, ecx ;ecx = 0
                mov  edx, [ss:eax+8+0] ; копируем ссылку на массив в edx

        inputArrLoop:
                ;сохраняем значения регистров в переменные на будущее
                mov  [stackPointer], eax
                mov  [tmp], edx
                mov  [i], ecx

                ;проверяем значение индекса
                cmp  ecx, [ss:eax+8+4]
                jge  endInputArrLoop

                ;считываем элемент
                push ecx
                push strArrElemIn
                call [printf]
                ;printf портит наши регистры

                push [tmp]
                push strScanInt
                call [scanf]
                ;scanf тоже портит регистры

                ;восстанавливаем регистры после printf и scanf,
                ;увеличиваем счетчик и переходим к следующему
                ;элементу массива
                mov  ecx, [i]
                inc  ecx
                mov  edx, [tmp]
                add  edx, 4
                mov  eax, [stackPointer]
                jmp  inputArrLoop

        endInputArrLoop:
                ;сдвигаем указатель стека на 2 позиции вверх
                sub  eax, 8
                mov  esp, eax
                ;возвращаем регистрам их значения
                pop  edx
                pop  ecx
                pop  eax

        ret
;======================READ_ARR============


;==============ARR_WITHOUT_FIRST_LAST=======

        createArrWithoutFirstLast:
                ;процедура не должна портить регистры,
                ;поэтому сохраняем их значения в стеке
                push eax
                mov  eax, esp ;сохраняем значение указателя стека в eax
                push ecx
                push edx
                push ebx

                mov  edx, [ss:eax+8+4] ;записываем в edx ссылку на первый массив
                mov  ebx, [ss:eax+8+0] ;записываем в edx ссылку на второй массив

                ;получаем значение первого элемента первого массива
                mov  ecx, [edx]
                mov  [firstElemA], ecx

                ;получаем последний элемент массива первого массива
                mov  ecx, [ss:eax+8+8] ;копируем размер первого массива в ecx
                mov  ecx, [edx+(ecx-1)*4] ;копируем в ecx значение последнего элемента
                mov  [lastElemA], ecx

                xor  ecx, ecx ;ecx = 0

        arrWithoutFirstLastLoop:
                ;сохраняем значения регистров в переменные на будущее
                mov  [tmp], edx
                mov  [tmpB], ebx
                mov  [i], ecx

                ;проверяем не привышает ли наш счетчик (в данном случае регистр ecx)
                ;размер массива
                cmp  ecx, [ss:eax+8+8]
                jge  endArrWithoutFirstLastLoop

                ;проверка на равенство последнему или первому элементу
                mov  ecx, [firstElemA]
                cmp  [edx], ecx
                je  nextElemArrA

                mov  ecx, [lastElemA]
                cmp  [edx], ecx
                je  nextElemArrA

                ;записываем элемент массива A в массив B
                mov  ecx, [edx]
                mov  [ebx], ecx

                ;сдвигаем указатель массива B на 1 элемент вправо
                add  ebx, 4
                inc  [sizeOfArrB]

        nextElemArrA:
                ;переходим к следующему элементу массива A
                mov  ecx, [i]
                inc  ecx
                add  edx, 4
                jmp  arrWithoutFirstLastLoop


        endArrWithoutFirstLastLoop:
                ;сдвигаем указатель стека на 3 позиции вверх
                sub  eax, 12
                mov  esp, eax

                ;возвращаем регистрам их значения до использования
                ;процедуры
                pop  ebx
                pop  edx
                pop  ecx
                pop  eax

        ret

;================ARR_WITHOUT_FIRST_LAST======


;=====================PRINT_ARR==============

        printArr:

                ;процедура не должна портить регистры,
                ;поэтому сохраняем их значения в стеке
                push eax
                mov  eax, esp ;сохраняем значение указателя стека в eax
                push ecx
                push edx

                ;сохраняем регистр eax
                mov  [stackPointer], eax

                push strArrBracketS
                call [printf]

                ;printf испортил регистры, поэтому восстанавливаем их
                mov  eax, [stackPointer]

                xor  ecx, ecx ;ecx = 0
                mov  edx, [ss:eax+8+0] ;записываем ссылку на массив в edx

        printArrLoop:
                ;сохраняем значения регистров в переменные
                mov  [tmp], edx
                mov  [i], ecx

                cmp  ecx, [ss:eax+8+4];сравниваем длину массива с ecx, регист хранящий наш счетчик
                jge  endPrintArrLoop

                mov  ecx, [edx]
                push ecx
                push strDigit
                call [printf]

                ;опять же восстанавливаем значения регистров так как
                ;после printf они попортились
                mov  edx, [tmp]
                add  edx, 4
                mov  ecx, [i]
                inc  ecx
                mov  eax, [stackPointer]
                jmp  printArrLoop

        endPrintArrLoop:
                ;выводим правую скобку
                push strArrBracketE
                call [printf]

                ;восстанавливаем значения регистра eax после printf
                mov  eax, [stackPointer]

                ;сдвигаем указатель кучи на две позиции вверх
                sub  eax, 8
                mov  esp, eax
                ;возвращаем регистрам их значения до использования
                ;процедуры
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