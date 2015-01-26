@echo off

for /d %%i in ("\Program Files\Java\jdk*") do set JAVA_HOME=%%i

echo JAVA_HOME is %JAVA_HOME%

echo.
echo Select the number of the document you want to build
echo ===================================================

set DOCUMENT_BASE_DIR=%~dp0

REM Get the absolute path of DITAOT's home directory
set DITA_DIR=..\DITA-OT1.8.5

REM Set environment variables
set ANT_OPTS=-Xmx512m %ANT_OPTS%
set ANT_OPTS=%ANT_OPTS% -Djavax.xml.transform.TransformerFactory=net.sf.saxon.TransformerFactoryImpl
set ANT_HOME=%DITA_DIR%\tools\ant
set PATH=%DITA_DIR%\tools\ant\bin;%PATH%
set CLASSPATH=%DITA_DIR%\lib;%DITA_DIR%\lib\dost.jar;%DITA_DIR%\lib\commons-codec-1.4.jar;%DITA_DIR%\lib\resolver.jar;%DITA_DIR%\lib\icu4j.jar;%CLASSPATH%
set CLASSPATH=%DITA_DIR%\lib\xercesImpl.jar;%DITA_DIR%\lib\xml-apis.jar;%CLASSPATH%
set CLASSPATH=%DITA_DIR%\lib\saxon\saxon9.jar;%DITA_DIR%\lib\saxon\saxon9-dom.jar;%CLASSPATH%

set index=1
SETLOCAL ENABLEDELAYEDEXPANSION
FOR /R %%f IN (*.ditamap) DO (
   SET file!index!=%%f
   ECHO !index! - %%~nxf
   SET /A index=!index!+1
)

SETLOCAL DISABLEDELAYEDEXPANSION

SET /P selection="Choose document to build (or ENTER for all): "

IF [%selection%] == [] GOTO :BUILDALL

SET file%selection% >nul 2>&1

IF ERRORLEVEL 1 (
   ECHO Invalid file selected
   EXIT /B 1
)

CALL :RESOLVE %%file%selection%%%

ECHO selected file name: %file_name%
ECHO Document base directory - %DOCUMENT_BASE_DIR%

%DITA_DIR%\tools\ant\bin\ant -f "%DITA_DIR%\build.xml" -Dtranstype=pdf2 -Dargs.input="%file_name%"  -Douter.control=quiet -Dtempdir="%DOCUMENT_BASE_DIR%/temp" -Doutput.dir="%DOCUMENT_BASE_DIR%\out" -Dcustomization.dir="%DOCUMENT_BASE_DIR%/../dell_customization"
GOTO :EOF

:BUILDALL
SETLOCAL ENABLEDELAYEDEXPANSION
FOR /R %%f IN (*.ditamap) DO (
   ECHO ************************
   ECHO Building %%f...
   ECHO ************************
   %DITA_DIR%\tools\ant\bin\ant -f "%DITA_DIR%\build.xml" -Dtranstype=pdf2 -Dargs.input="%%f"  -Douter.control=quiet -Dtempdir="%DOCUMENT_BASE_DIR%/temp" -Doutput.dir="%DOCUMENT_BASE_DIR%\out" -Dcustomization.dir="%DOCUMENT_BASE_DIR%/../dell_customization"
)
GOTO :EOF

:RESOLVE
SET file_name=%1
GOTO :EOF