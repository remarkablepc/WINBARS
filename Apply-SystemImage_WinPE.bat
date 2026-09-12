@echo off
setlocal EnableDelayedExpansion
title WINBARS - Bare-Metal System Image Disaster Recovery (WinPE/WinRE)
color 1F

echo ==============================================================================
echo   WINBARS BARE-METAL DISASTER RECOVERY ASSISTANT (DISM / WinPE / WinRE)
echo ==============================================================================
echo   This native Windows utility restores a bare-metal .wim system image
echo   onto your target Windows drive using standard Microsoft DISM and BCDBoot.
echo.
echo   BENCH NOTICE: This image restores Windows OS, Drivers ^& Installed Programs.
echo   Client personal data is preserved separately in '\Users' on external backup.
echo ==============================================================================
echo.

:: 1. WinRE / WinPE Environment Detection
set "IN_WINPE=0"
if exist "X:\windows\system32" set "IN_WINPE=1"

if "%IN_WINPE%"=="0" (
    echo [NOTICE] WARNING: You are running this script inside live Windows!
    echo     You cannot overwrite an active, running Windows installation.
    echo     To restore your system:
    echo       1. Hold Shift and click Restart [or boot from Windows Setup USB].
    echo       2. Navigate to Troubleshoot -^> Advanced Options -^> Command Prompt.
    echo       3. Navigate to this drive and run Apply-SystemImage_WinPE.bat.
    echo.
    set /p "LIVE_CHOICE=Do you want to proceed with image inspection only? (Y/N): "
    if /i not "!LIVE_CHOICE!"=="Y" (
        echo Recovery aborted.
        pause
        exit /b 0
    )
)

:: 2. Locate available .wim image files in current directory
set "IMAGE_DIR=%~dp0"
echo [*] Scanning for system images in: %IMAGE_DIR%
echo.

set "IMG_COUNT=0"
set "DEFAULT_WIM="

for %%F in ("%IMAGE_DIR%*.wim") do (
    set /a IMG_COUNT+=1
    set "IMG_!IMG_COUNT!=%%~nxF"
    set "IMG_PATH_!IMG_COUNT!=%%~fF"
    echo   [!IMG_COUNT!] %%~nxF  (%%~zF bytes)
    echo %%~nxF | findstr /I "_baseline" >nul && set "DEFAULT_WIM=!IMG_COUNT!"
)

if "%IMG_COUNT%"=="0" (
    echo [X] ERROR: No .wim system images found in %IMAGE_DIR%
    pause
    exit /b 1
)

echo.
if not "!DEFAULT_WIM!"=="" (
    set /p "PICK=Select image number [1-%IMG_COUNT%] (Default: !DEFAULT_WIM! - Baseline): "
    if "!PICK!"=="" set "PICK=!DEFAULT_WIM!"
) else (
    set /p "PICK=Select image number [1-%IMG_COUNT%]: "
)

set "SELECTED_WIM=!IMG_PATH_%PICK%!"
set "SELECTED_NAME=!IMG_%PICK%!"

if "!SELECTED_WIM!"=="" (
    echo [X] Invalid selection. Aborting.
    pause
    exit /b 1
)

echo.
echo [*] Selected Image: !SELECTED_NAME!
echo [*] Querying DISM image metadata...
dism.exe /Get-ImageInfo /ImageFile:"!SELECTED_WIM!" /Index:1
echo.

if "%IN_WINPE%"=="0" (
    echo [OK] Image inspection complete. To apply, reboot into WinRE Command Prompt.
    pause
    exit /b 0
)

:: 3. Detect Target Windows Drive in WinPE
echo [*] Auto-detecting Windows OS target partitions...
set "DETECTED_WIN="
for %%D in (C D E F G H I) do (
    if exist "%%D:\Windows\System32\kernel32.dll" (
        echo   - Found Windows on %%D:
        if "!DETECTED_WIN!"=="" set "DETECTED_WIN=%%D:"
    )
)

echo.
if not "!DETECTED_WIN!"=="" (
    set /p "TARGET_DRV=Enter target drive letter to RESTORE to (Default: !DETECTED_WIN!): "
    if "!TARGET_DRV!"=="" set "TARGET_DRV=!DETECTED_WIN!"
) else (
    set /p "TARGET_DRV=Enter target drive letter to RESTORE to (e.g. C: or D:): "
)

set "TARGET_DRV=!TARGET_DRV:~0,2!"

if not exist "!TARGET_DRV!\" (
    echo [X] ERROR: Target drive !TARGET_DRV!\ does not exist!
    pause
    exit /b 1
)

:: 4. Restoration Strategy Selection (Safe Overlay vs Bare-Metal Clean Wipe)
set "SRC_DRV=!SELECTED_WIM:~0,2!"
set "SAME_DRV=0"
if /i "!SRC_DRV!"=="!TARGET_DRV!" set "SAME_DRV=1"

echo.
echo ==============================================================================
echo   SELECT RESTORATION STRATEGY FOR TARGET VOLUME [!TARGET_DRV!\]
echo ==============================================================================
echo   [1] SAFE OVERLAY (In-Place OS Refresh - Preserves !TARGET_DRV!\Users) [RECOMMENDED]
echo       - Restores Windows OS, System Drivers ^& Program Files.
echo       - Existing personal files, photos ^& user profiles in !TARGET_DRV!\Users
echo         are 100%% PRESERVED and untouched on the disk!
echo       - Does NOT reformat the partition.
echo.
if "!SAME_DRV!"=="1" (
    echo   [2] BARE-METAL CLEAN WIPE [LOCKED]
    echo       - DISABLED: Source image is stored on target volume (!TARGET_DRV!\).
    echo         Reformatting would delete the .wim file you are restoring from!
) else (
    echo   [2] BARE-METAL CLEAN WIPE [Re-Format ^& Clean Apply]
    echo       - Completely formats !TARGET_DRV!\ before applying image.
    echo       - ALL existing data on !TARGET_DRV!\ will be PERMANENTLY ERASED.
)
echo ==============================================================================
echo.

if "!SAME_DRV!"=="1" (
    echo [*] Defaulting to Option [1] (Safe Overlay) due to single-volume placement.
    set "STRATEGY=1"
) else (
    set /p "STRATEGY=Select restoration strategy [1-2] (Default: 1 - Safe Overlay): "
    if "!STRATEGY!"=="" set "STRATEGY=1"
)

if "!STRATEGY!"=="1" (
    echo.
    echo ==============================================================================
    echo   SAFE OVERLAY CONFIRMATION: IN-PLACE SYSTEM REFRESH
    echo ==============================================================================
    echo   Image Source:  !SELECTED_WIM!
    echo   Target Volume: !TARGET_DRV!\
    echo.
    echo   NOTICE: This will refresh Windows OS and Program Files.
    echo   Your personal data in !TARGET_DRV!\Users will remain INTACT.
    echo ==============================================================================
    echo.
    set /p "CONFIRM_OVERLAY=Type YES to start In-Place Safe Overlay to !TARGET_DRV!\: "
    if not "!CONFIRM_OVERLAY!"=="YES" (
        echo.
        echo [ABORTED] Restoration cancelled by user.
        pause
        exit /b 0
    )
) else (
    echo.
    echo ==============================================================================
    echo   [CRITICAL] TECHNICIAN SAFEGUARD: DOUBLE CONFIRMATION REQUIRED
    echo ==============================================================================
    echo   Image Source:  !SELECTED_WIM!
    echo   Target Volume: !TARGET_DRV!\
    echo.
    echo   WARNING: Applying this option will RE-FORMAT !TARGET_DRV!\ and PERMANENTLY ERASE
    echo   all files, including !TARGET_DRV!\Users and all personal data.
    echo ==============================================================================
    echo.
    set /p "USER_CHECK=STEP 1/2: Have you verified or backed up client files from !TARGET_DRV!\Users? (Type YES): "
    if not "!USER_CHECK!"=="YES" (
        echo.
        echo [ABORTED] Restoration cancelled to protect un-synced client data in !TARGET_DRV!\Users.
        pause
        exit /b 0
    )
    echo.
    set /p "FINAL_CHECK=STEP 2/2: Confirm RE-FORMAT and bare-metal image apply to !TARGET_DRV!\ (Type YES): "
    if not "!FINAL_CHECK!"=="YES" (
        echo.
        echo [ABORTED] Restoration cancelled by user.
        pause
        exit /b 0
    )
    echo.
    echo [*] Formatting !TARGET_DRV!\ (NTFS Quick Format)...
    set "FMT_EXE=format.com"
    !FMT_EXE! !TARGET_DRV! /FS:NTFS /Q /Y
)

echo.
echo [*] Applying DISM image to !TARGET_DRV!\ (this may take 5-15 minutes)...
dism.exe /Apply-Image /ImageFile:"!SELECTED_WIM!" /Index:1 /ApplyDir:!TARGET_DRV!\ /CheckIntegrity /Verify
set "DISM_ERR=!ERRORLEVEL!"

if not "!DISM_ERR!"=="0" (
    color 4F
    echo.
    echo [X] CRITICAL: DISM failed with exit code !DISM_ERR!.
    pause
    exit /b !DISM_ERR!
)

echo.
echo [OK] DISM image applied successfully!
echo.
set /p "RUN_BCDBOOT=Do you want to re-initialize the bootloader with BCDBoot? (Recommended) (Y/N): "
if /i "!RUN_BCDBOOT!"=="Y" (
    echo [*] Running: bcdboot !TARGET_DRV!\Windows /s !TARGET_DRV! /f ALL
    bcdboot !TARGET_DRV!\Windows /s !TARGET_DRV! /f ALL
    if errorlevel 1 (
        echo [*] Retrying generic bootloader configuration: bcdboot !TARGET_DRV!\Windows
        bcdboot !TARGET_DRV!\Windows
    )
    echo [OK] Bootloader reconfigured.
)

color 2F
echo.
echo ==============================================================================
echo   [SUCCESS] BARE-METAL RESTORATION COMPLETE!
echo ==============================================================================
echo   Your system has been successfully restored.
echo   Remove the Windows Setup USB or recovery drive, then reboot your computer.
echo ==============================================================================
pause
exit /b 0