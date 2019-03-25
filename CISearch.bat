@ECHO OFF

REM Deleting temp files from previous launches

IF EXIST %CD%\_TEMP1 (del _TEMP1)
IF EXIST %CD%\_TEMP (del _TEMP)
IF EXIST %CD%\_NUM (del _NUM)

REM Description
Echo Skrypt do automatycznego pobierania duzej ilosci numerow inwentarzowych wpisanych do rejestru.
REM User defines what computers will be scanned (Starting and ending value)
SET /p pocz="Wpisz numer poczatkowego komputera(sama cyfra, bez reszty nazwy) (PC*cyfra*TST):  "
SET /p kon="Wpisz numer koncowego komputera:   "

SET /A name = %pocz%
:START
REM Reseting variables
SET _TEMP1=""
SET _TEMP=""
SET _NUM=""
SET _CIID=""
SET var1=""
SET var2=""
REM Echoing scanned computer name			Enter your computer name schema HERE VV
Echo MD%name%CIR		

REM Loop which packs results of commands into variables
SETLOCAL ENABLEDELAYEDEXPANSION
SET count=1
  FOR /F "tokens=* USEBACKQ" %%F IN (`ping -n 1 MD%name%cir`) DO (
    SET var!count!=%%F
    SET /a count=!count!+1
    )
REM Variable to file to prevent losing/editing when exiting loop
echo %var1%>_TEMP1
echo "%var2%">_TEMP
ENDLOCAL

REM Back to memory

SET /p line2=<_TEMP
SET /p line1=<_TEMP1


REM Line below cuts "greather than or less than" chars from variable preventing bugs
SET line2=%line2:~1,-13%
REM Check if variable is empty, if it is then jumps to only one one line possible result
IF ("%line2%")==("") (
  GOTO NoLine2
)
REM Checking for succesful pings
IF "%line2:~-4%" == "time" ( GOTO REG
)
REM Checking if timed out
IF "%line2%" == "Reques" (
  echo Uplynal limit
  echo MD%name%CIR Timedout>>Serials.txt
  GOTO BACK
)
REM Checking if host is reachable
IF "%line2:~-18%" == " Destination host " (
  echo Nieosiagalny
  echo MD%name%CIR Unreachable>>Serials.txt
  GOTO BACK
)
REM Actual data mining code, loop same as above / Thank you stackoverflow
:REG

SETLOCAL ENABLEDELAYEDEXPANSION
SET var1=0
SET count=1
FOR /F "tokens=* USEBACKQ" %%F IN (`REG QUERY \\MD%name%CIR\HKLM\SYSTEM\Advicom\ /v InvSerial`) DO (
  SET var!count!=%%F
  SET /a count=!count!+1
  )
REM Checking if REG was succesfull, if not then either it is privilieges fault or no entry
REM Reseting values just to be sure
IF "%var1%" == "0" (
echo MD%name%CIR Brak dostepu lub brak wpisu>>Serials.txt
GOTO BACK
  )
REM Checking if REG is there but if its empty
IF "%var2:~23,30%" == "" (
echo MD%name%CIR Pusty wpis>>Serials.txt
GOTO BACK
  )
  )

echo %var2% >_NUM
ENDLOCAL
SET /p CIID=<_NUM
REM Echoing data to file, because command above also returns registry name and type, we cut it
echo MD%name%CIR %CIID:~23,30%>>Serials.txt
echo %CIID:~23,30%
REM GOTO which forces script to loop
GOTO BACK
REM If second line is empty then there are only two possible cases
:NoLine2
SET line1=%line1:~-6%
IF %line1% == again. (
REM No response
echo Brak odpowiedzi
echo MD%name%CIR Taki hostname nie istnieje>>Serials.txt
  ) ELSE (
REM Hardware error
echo BLAD SPRZETU
echo MD%name%CIR BLAD SPRZETU>>Serials.txt
    )
REM Script checks which loop is it and if its same as desired, then ends script
:BACK
IF %name% == %kon% (
GOTO END )
set /A name=name+1
GOTO START
:END
IF EXIST %CD%\_TEMP1 (del _TEMP1)
IF EXIST %CD%\_TEMP (del _TEMP)
IF EXIST %CD%\_NUM (del _NUM)
Echo Zakonczono.
pause
