@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
set "LAST_UPDATE_TIME="
:loop
echo [%date% %time%] Checking repository status...
set REPO_URL=https://gitee.com/TianLSama/WEB.git
if not exist WEB (
    echo [%date% %time%] Local repository does not exist. Cloning...
    rd /s /q WEB_NEXT 2>nul
    git clone %REPO_URL% WEB_NEXT
    if errorlevel 1 (
        echo [%date% %time%] [WARNING!!!!!!] Clone failed!
    ) else (
        echo [%date% %time%] Clone succeeded!
        ren WEB_NEXT WEB
        cd WEB
        for /f "tokens=*" %%i in ('git log -1 --format^=%%ai') do set LATEST_COMMIT_DATE=%%i
        cd ..
        set LAST_UPDATE_TIME=%date% %time%
        call :generate_html_file "!LATEST_COMMIT_DATE!" "!LAST_UPDATE_TIME!"
    )
    goto wait_loop
)
for /f "tokens=1" %%i in ('git ls-remote %REPO_URL% HEAD ^| findstr -i HEAD') do set REMOTE_HASH=%%i
cd WEB
for /f "tokens=*" %%i in ('git rev-parse HEAD') do set LOCAL_HASH=%%i
cd ..
echo [%date% %time%] Remote hash: %REMOTE_HASH%
echo [%date% %time%] Local hash:  %LOCAL_HASH%
if "%REMOTE_HASH%"=="%LOCAL_HASH%" (
    echo [%date% %time%] No changes in remote repository. Skipping pull.
    cd WEB
    for /f "tokens=*" %%i in ('git log -1 --format^=%%ai') do set LATEST_COMMIT_DATE=%%i
    cd ..
    if defined LAST_UPDATE_TIME (
        call :generate_html_file "!LATEST_COMMIT_DATE!" "!LAST_UPDATE_TIME!"
    ) else (
        call :generate_html_file "!LATEST_COMMIT_DATE!" "%date% %time%"
    )
) else (
    echo [%date% %time%] Remote repository has changed. Cloning updates...
    if exist WEB_TMP (
        rd /s /q WEB_TMP
    )
    git clone %REPO_URL% WEB_TMP
    if errorlevel 1 (
        echo [%date% %time%] [WARNING!!!!!!] Clone for time check failed!
        call :generate_html_file "Unknown" "%date% %time%"
    ) else (
        cd WEB_TMP
        for /f "tokens=*" %%i in ('git log -1 --format^=%%ai') do set REMOTE_COMMIT_TIME=%%i
        cd ..
        git clone %REPO_URL% WEB_NEXT
        if errorlevel 1 (
            echo [%date% %time%] [WARNING!!!!!!] Clone failed!
        ) else (
            echo [%date% %time%] Clone succeeded!
            if exist WEB (
                ren WEB WEB_OLD
            )
            ren WEB_NEXT WEB
            start /min cmd /c "timeout /t 3 >nul && rd /s /q WEB_OLD 2>nul && rd /s /q WEB_TMP 2>nul"
            set LAST_UPDATE_TIME=%date% %time%
            call :generate_html_file "!REMOTE_COMMIT_TIME!" "!LAST_UPDATE_TIME!"
        )
    )
)
:wait_loop
echo.
echo Waiting 30 seconds before next check...
ping -n 31 127.0.0.1 >nul
echo.
goto loop
:generate_html_file
set "REMOTE_COMMIT_TIME=%~1"
set "LOCAL_UPDATE_TIME=%~2"
set "HTML_TARGET_DIR=..\WEB\pages\web\others"
if not exist "!HTML_TARGET_DIR!" (
    mkdir "!HTML_TARGET_DIR!"
)
echo ^<!DOCTYPE html^> > "!HTML_TARGET_DIR!\version.html"
echo ^<html^> >> "!HTML_TARGET_DIR!\version.html"
echo ^<head^> >> "!HTML_TARGET_DIR!\version.html"
echo     ^<meta charset="UTF-8"^> >> "!HTML_TARGET_DIR!\version.html"
echo     ^<title^>Version Info^</title^> >> "!HTML_TARGET_DIR!\version.html"
echo ^</head^> >> "!HTML_TARGET_DIR!\version.html"
echo ^<body^> >> "!HTML_TARGET_DIR!\version.html"
echo     Latest Remote Commit Time: !REMOTE_COMMIT_TIME!^<br/^> >> "!HTML_TARGET_DIR!\version.html"
echo     Local Update Time: !LOCAL_UPDATE_TIME!^<br/^> >> "!HTML_TARGET_DIR!\version.html"
echo     Last Check Time: %date% %time%^<br/^> >> "!HTML_TARGET_DIR!\version.html"
echo ^</body^> >> "!HTML_TARGET_DIR!\version.html"
echo ^</html^> >> "!HTML_TARGET_DIR!\version.html"
echo [%date% %time%] HTML status file generated: !HTML_TARGET_DIR!\version.html
goto :eof