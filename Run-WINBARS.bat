@echo off
setlocal EnableDelayedExpansion
title WINBARS - Windows Backup, Assistance, Recovery ^& Security
:: ============================================================
:: TECHNICIAN SHOP PRESETS & RUNNER DEFAULTS
:: (Customize these once on your USB drive for 1-click deployment)
:: ============================================================
:: Default Menu Choice when pressing ENTER (1-6, Default: 1)
set "DEFAULT_MENU_CHOICE=1"
:: Default Deployment Profile (ZeroFootprint, Minimal, LocalDisasterGuard, HeadlessFull, TotalProtection)
set "DEFAULT_PROFILE=ZeroFootprint"
:: Preferred Shop Brand (file name in brands\ without .json, e.g. CorporateNetworkSolutions, or blank for auto)
set "DEFAULT_BRAND="
:: Resolve configuration path (config\config.json -> config.json -> C:\ProgramData\WINBARS\config.json)
set "ACTIVE_CONFIG_PATH="
if exist "%~dp0config\config.json" (
    set "ACTIVE_CONFIG_PATH=%~dp0config\config.json"
) else if exist "%~dp0config.json" (
    set "ACTIVE_CONFIG_PATH=%~dp0config.json"
) else if exist "C:\ProgramData\WINBARS\config.json" (
    set "ACTIVE_CONFIG_PATH=C:\ProgramData\WINBARS\config.json"
)
:: Check config for DefaultBrand override (e.g. Vanilla, or specific brand file)
if not "!ACTIVE_CONFIG_PATH!"=="" (
    for /f "tokens=2 delims=:, " %%a in ('findstr /i "\"DefaultBrand\"" "!ACTIVE_CONFIG_PATH!" 2^>nul') do (
        set "CFG_DEF_BRAND=%%~a"
        set "CFG_DEF_BRAND=!CFG_DEF_BRAND:\"=!"
        set "CFG_DEF_BRAND=!CFG_DEF_BRAND: =!"
        if /i not "!CFG_DEF_BRAND!"=="Auto" set "DEFAULT_BRAND=!CFG_DEF_BRAND!"
    )
)
:: Default Log Retention in Days (90, 180, 365, 730, 1095, or 0 for Forever)
set "DEFAULT_LOG_RETENTION=730"
:: ============================================================
:: Check for Administrative Privileges
NET SESSION >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Requesting Administrator Privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath cmd.exe -ArgumentList '/c \"\"%~f0\"\" %*' -Verb RunAs"
    exit /b
)
cd /d "%~dp0"
:: Auto-Unblock files to prevent SmartScreen / Zone.Identifier execution blocking
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%~dp0*' -Recurse | Unblock-File -ErrorAction SilentlyContinue" >nul 2>&1
:: Detect Execution Engine (WINBARS.exe or WINBARS.ps1 fallback)
set "RUN_CMD="
if exist "%~dp0WINBARS.exe" (
    set RUN_CMD="%~dp0WINBARS.exe"
) else if exist "%~dp0WINBARS.ps1" (
    set RUN_CMD=powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0WINBARS.ps1"
)
:: If command-line arguments were provided, pass them directly to engine
if not "%~1"=="" (
    if defined RUN_CMD (
        !RUN_CMD! %*
    ) else (
        echo [ERROR] Neither WINBARS.exe nor WINBARS.ps1 was found in %~dp0
        pause
    )
    exit /b
)
:: Auto-Discover Available Branding Profiles (branding.json, default.json, brands\*.json)
set "BRAND_COUNT=0"
set "CHOSEN_BRAND_FILE="
set "CHOSEN_BRAND_NAME="
set "ACTIVE_BRAND_INDEX=1"
set "BRAND_ARG=-Vanilla"
set "LAST_BRAND_SAVED="
if exist "C:\ProgramData\WINBARS\last_brand.txt" (
    set /p LAST_BRAND_SAVED=<"C:\ProgramData\WINBARS\last_brand.txt"
    if defined LAST_BRAND_SAVED set "LAST_BRAND_SAVED=!LAST_BRAND_SAVED: =!"
)
:: 1. Check for explicit brands\default.json first
if exist "%~dp0brands\default.json" (
    set /a BRAND_COUNT+=1
    set "BRAND_!BRAND_COUNT!_FILE=%~dp0brands\default.json"
    set "BRAND_!BRAND_COUNT!_NAME=default.json (Default)"
)
:: 2. Check for root branding.json
if exist "%~dp0branding.json" (
    set /a BRAND_COUNT+=1
    set "BRAND_!BRAND_COUNT!_FILE=%~dp0branding.json"
    set "BRAND_!BRAND_COUNT!_NAME=branding.json (Default)"
)
:: 3. Check for specified DEFAULT_BRAND from config header
if not "!DEFAULT_BRAND!"=="" (
    if exist "%~dp0brands\!DEFAULT_BRAND!.json" (
        set "IS_DUP=0"
        for /l %%i in (1,1,!BRAND_COUNT!) do (
            if "!BRAND_%%i_FILE!"=="%~dp0brands\!DEFAULT_BRAND!.json" set "IS_DUP=1"
        )
        if "!IS_DUP!"=="0" (
            set /a BRAND_COUNT+=1
            set "BRAND_!BRAND_COUNT!_FILE=%~dp0brands\!DEFAULT_BRAND!.json"
            set "BRAND_!BRAND_COUNT!_NAME=!DEFAULT_BRAND!.json"
        )
    )
)
:: 4. Discover all remaining brands\*.json
if exist "%~dp0brands\*.json" (
    for %%f in ("%~dp0brands\*.json") do (
        set "IS_DUP=0"
        for /l %%i in (1,1,!BRAND_COUNT!) do (
            if "!BRAND_%%i_FILE!"=="%%~ff" set "IS_DUP=1"
        )
        if "!IS_DUP!"=="0" (
            set /a BRAND_COUNT+=1
            set "BRAND_!BRAND_COUNT!_FILE=%%~ff"
            set "BRAND_!BRAND_COUNT!_NAME=%%~nxf"
        )
    )
)
:: 5. Determine active brand: Match default.json or branding.json first, then last used brand. Otherwise Generic/Vanilla.
set "BRAND_ARG=-Vanilla"
set "CHOSEN_BRAND_FILE="
set "CHOSEN_BRAND_NAME=Generic / Unbranded"
set "ACTIVE_BRAND_INDEX=0"

if exist "%~dp0brands\default.json" (
    set "BRAND_ARG=-Branded"
    set "CHOSEN_BRAND_FILE=%~dp0brands\default.json"
    set "CHOSEN_BRAND_NAME=default.json"
    set "ACTIVE_BRAND_INDEX=1"
) else if exist "%~dp0branding.json" (
    set "BRAND_ARG=-Branded"
    set "CHOSEN_BRAND_FILE=%~dp0branding.json"
    set "CHOSEN_BRAND_NAME=branding.json"
    set "ACTIVE_BRAND_INDEX=1"
) else if defined LAST_BRAND_SAVED (
    for /l %%i in (1,1,!BRAND_COUNT!) do (
        set "CURR_BNAME=!BRAND_%%i_NAME: =!"
        if /i "!CURR_BNAME!"=="!LAST_BRAND_SAVED!" (
            set "BRAND_ARG=-Branded"
            set "CHOSEN_BRAND_FILE=!BRAND_%%i_FILE!"
            set "CHOSEN_BRAND_NAME=!BRAND_%%i_NAME!"
            set "ACTIVE_BRAND_INDEX=%%i"
        )
    )
)

if defined CHOSEN_BRAND_FILE (
    if not exist "C:\ProgramData\WINBARS" mkdir "C:\ProgramData\WINBARS" >nul 2>&1
    if not exist "C:\ProgramData\WINBARS\branding.json" (
        copy /y "!CHOSEN_BRAND_FILE!" "C:\ProgramData\WINBARS\branding.json" >nul 2>&1
    )
    if not exist "C:\ProgramData\WINBARS\last_brand.txt" (
        echo !CHOSEN_BRAND_NAME!> "C:\ProgramData\WINBARS\last_brand.txt"
    )
)
:MENU_LOOP
:: Dynamically refresh active deployment profile from config
if "!ACTIVE_CONFIG_PATH!"=="" (
    if exist "%~dp0config\config.json" set "ACTIVE_CONFIG_PATH=%~dp0config\config.json"
    if "!ACTIVE_CONFIG_PATH!"=="" if exist "%~dp0config.json" set "ACTIVE_CONFIG_PATH=%~dp0config.json"
    if "!ACTIVE_CONFIG_PATH!"=="" if exist "C:\ProgramData\WINBARS\config.json" set "ACTIVE_CONFIG_PATH=C:\ProgramData\WINBARS\config.json"
)
set "DETECTED_PROFILE="
if not "!ACTIVE_CONFIG_PATH!"=="" (
    for /f "tokens=2 delims=:, " %%p in ('type "!ACTIVE_CONFIG_PATH!" 2^>nul ^| findstr /i "\"DeploymentProfile\""') do set "DETECTED_PROFILE=%%~p"
)
if not "!DETECTED_PROFILE!"=="" set "DEFAULT_PROFILE=!DETECTED_PROFILE!"
cls
echo ============================================================
echo   WINBARS - WINDOWS BACKUP, ASSISTANCE, RECOVERY ^& SECURITY
echo ============================================================
echo  Location:       %~dp0
echo  Active Brand:   !CHOSEN_BRAND_NAME! [!BRAND_ARG!]
echo  Default Mode:   !DEFAULT_PROFILE! Profile
echo  Log Retention:  !DEFAULT_LOG_RETENTION! Days (Forensic Trail)
if !BRAND_COUNT! GTR 1 echo  Brand Profiles: !BRAND_COUNT! found - Press [B] to switch shop brand
echo ============================================================
echo  SELECT ACTION:
echo ============================================================
echo  [1] Deploy !DEFAULT_PROFILE! Profile [Default Preset]
echo  [N] Deploy Near-Zero Footprint Profile [Stealth Native Automation]
echo  [2] Launch Technician Interactive Console ^& Setup Wizard
echo  [3] Backup My Files (1-Click File Mirror ^& Safety Checkpoint)
echo  [4] Disaster Recovery Center (WinPE / Blue Screen / File Restore)
echo  [5] Toggle Backup Drive Visibility (Explorer Cloak)
echo  [6] Open WINBARS Protection Center (GUI Dashboard)
echo  [I] Install / Provision Suite to C:\Tools\WINBARS
echo  [U] In-Place Upgrade / Refresh Installed Suite
if !BRAND_COUNT! GTR 1 echo  [B] Switch Shop Branding Profile
echo  [0] Exit
echo ============================================================
set "ACT_CHOICE=!DEFAULT_MENU_CHOICE!"
if not "!ACTIVE_CONFIG_PATH!"=="" (
    for /f "tokens=2 delims=:," %%a in ('type "!ACTIVE_CONFIG_PATH!" 2^>nul ^| findstr /i "DefaultMenuChoice"') do (
        set "DEF_VAL=%%~a"
        set "DEF_VAL=!DEF_VAL: =!"
        set "DEF_VAL=!DEF_VAL:"=!"
        if not "!DEF_VAL!"=="" set "ACT_CHOICE=!DEF_VAL!"
    )
)
if defined DEFAULT_MENU_CHOICE set "ACT_CHOICE=!DEFAULT_MENU_CHOICE!"
set /p "ACT_CHOICE=Select an option [Default: !ACT_CHOICE!]: "
if "!ACT_CHOICE!"=="0" exit /b
if /i "!ACT_CHOICE!"=="B" goto DO_BRAND
if /i "!ACT_CHOICE!"=="I" goto DO_INSTALL_LOCAL
if /i "!ACT_CHOICE!"=="U" goto DO_UPGRADE
if /i "!ACT_CHOICE!"=="N" goto DO_CHOICE_N
if "!ACT_CHOICE!"=="1" goto DO_CHOICE_1
if "!ACT_CHOICE!"=="2" goto DO_CHOICE_2
if "!ACT_CHOICE!"=="3" goto DO_CHOICE_3
if "!ACT_CHOICE!"=="4" goto DO_CHOICE_4
if "!ACT_CHOICE!"=="5" goto DO_CHOICE_5
if "!ACT_CHOICE!"=="6" goto DO_CHOICE_6
echo.
echo [ERROR] Invalid selection: !ACT_CHOICE!
timeout /t 1 >nul
goto MENU_LOOP
:DO_BRAND
if !BRAND_COUNT! LEQ 0 goto MENU_LOOP
cls
echo ============================================================
echo   SELECT SHOP BRANDING PROFILE:
echo ============================================================
echo  [0] Generic / Vanilla (No Branding)
for /l %%i in (1,1,!BRAND_COUNT!) do (
    if "!BRAND_%%i_FILE!"=="!CHOSEN_BRAND_FILE!" (
        echo  [%%i] !BRAND_%%i_NAME! [ACTIVE]
    ) else (
        echo  [%%i] !BRAND_%%i_NAME!
    )
)
echo ============================================================
set "B_SEL=!ACTIVE_BRAND_INDEX!"
if "!B_SEL!"=="" set "B_SEL=1"
set /p "B_SEL=Select brand [0-!BRAND_COUNT!, Default: !B_SEL!]: "
if "!B_SEL!"=="0" (
    set "BRAND_ARG=-Vanilla"
    set "CHOSEN_BRAND_FILE="
    set "CHOSEN_BRAND_NAME=Generic / Unbranded"
    set "ACTIVE_BRAND_INDEX=0"
    if exist "C:\ProgramData\WINBARS\branding.json" del /f /q "C:\ProgramData\WINBARS\branding.json" >nul 2>&1
    if exist "C:\ProgramData\WINBARS\last_brand.txt" del /f /q "C:\ProgramData\WINBARS\last_brand.txt" >nul 2>&1
    goto MENU_LOOP
)
for /l %%i in (1,1,!BRAND_COUNT!) do (
    if "!B_SEL!"=="%%i" (
        set "BRAND_ARG=-Branded"
        set "CHOSEN_BRAND_FILE=!BRAND_%%i_FILE!"
        set "CHOSEN_BRAND_NAME=!BRAND_%%i_NAME!"
        set "ACTIVE_BRAND_INDEX=%%i"
        if not exist "C:\ProgramData\WINBARS" mkdir "C:\ProgramData\WINBARS" >nul 2>&1
        copy /y "!CHOSEN_BRAND_FILE!" "C:\ProgramData\WINBARS\branding.json" >nul 2>&1
        echo !BRAND_%%i_NAME!> "C:\ProgramData\WINBARS\last_brand.txt"
    )
)
goto MENU_LOOP
:DO_CHOICE_N
echo.
echo  --^> Deploying Near-Zero Footprint Profile (Stealth Native Automation)...
if not defined RUN_CMD (
    echo [ERROR] Execution engine not found in %~dp0
    pause
    goto MENU_LOOP
)
!RUN_CMD! -SetProfile NearZeroFootprint -Vanilla -Unattended
echo.
pause
goto MENU_LOOP
:DO_CHOICE_1
echo.
echo  --^> Deploying !DEFAULT_PROFILE! Profile...
if not defined RUN_CMD (
    echo [ERROR] Execution engine not found in %~dp0
    pause
    goto MENU_LOOP
)
!RUN_CMD! -SetProfile !DEFAULT_PROFILE! !BRAND_ARG! -Unattended
echo.
pause
goto MENU_LOOP
:DO_CHOICE_2
echo.
echo  --^> Launching Technician Console ^& Setup Wizard...
if not defined RUN_CMD (
    echo [ERROR] Execution engine not found in %~dp0
    pause
    goto MENU_LOOP
)
!RUN_CMD! -Console !BRAND_ARG!
echo.
pause
goto MENU_LOOP
:DO_CHOICE_3
echo.
echo  --^> Initiating Backup My Files...
if not defined RUN_CMD (
    echo [ERROR] Execution engine not found in %~dp0
    pause
    goto MENU_LOOP
)
!RUN_CMD! -Action FastBackup -ShowProgress !BRAND_ARG!
echo.
pause
goto MENU_LOOP
:DO_CHOICE_4
echo.
echo  --^> Launching Disaster Recovery Center...
if not defined RUN_CMD (
    echo [ERROR] Execution engine not found in %~dp0
    pause
    goto MENU_LOOP
)
!RUN_CMD! -Restore !BRAND_ARG!
echo.
pause
goto MENU_LOOP
:DO_CHOICE_5
if exist "%~dp0Toggle_Backup_Drive_Visibility.bat" (
    call "%~dp0Toggle_Backup_Drive_Visibility.bat"
) else if defined RUN_CMD (
    !RUN_CMD! -ToggleDriveCloaking !BRAND_ARG!
) else (
    echo [ERROR] Utility not found.
    pause
)
goto MENU_LOOP
:DO_UPGRADE
echo.
echo  --> Upgrading Installed WINBARS Suite & Refreshing Tasks...
if not defined RUN_CMD (
    echo [ERROR] Execution engine not found in %~dp0
    pause
    goto MENU_LOOP
)
:: Pre-flight: confirm WINBARS is actually installed before trying to upgrade
if not exist "C:\Tools\WINBARS\WINBARS.exe" (
    if not exist "C:\Tools\WINBARS\WINBARS.ps1" (
        echo.
        echo  [ERROR] No installed WINBARS suite found at C:\Tools\WINBARS.
        echo         Use [I] Install / Provision Suite first, then upgrade.
        echo.
        pause
        goto MENU_LOOP
    )
)
!RUN_CMD! -Update !BRAND_ARG!
echo.
pause
goto MENU_LOOP
:DO_INSTALL_LOCAL
echo.
echo  --^> Provisioning WINBARS Suite Locally to C:\Tools\WINBARS...
if not defined RUN_CMD (
    echo [ERROR] Execution engine not found in %~dp0
    pause
    goto MENU_LOOP
)
!RUN_CMD! -InstallLocal !BRAND_ARG!
if %errorlevel% EQU 0 (
    echo.
    echo  [OK] Installation completed successfully.
    echo  --> Transferring execution to newly launched WINBARS suite...
    timeout /t 2 /nobreak >nul 2>&1
    exit /b 0
)
echo.
pause
goto MENU_LOOP
:DO_CHOICE_6
echo.
echo  --^> Launching WINBARS Protection Center GUI...
if defined RUN_CMD (
    start "" !RUN_CMD! -GUI !BRAND_ARG!
    echo  [OK] Launched WINBARS Protection Center Dashboard.
) else (
    echo [ERROR] Execution engine not found.
    pause
)
timeout /t 2 >nul
goto MENU_LOOP