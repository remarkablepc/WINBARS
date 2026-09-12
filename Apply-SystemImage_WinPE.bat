@echo off
setlocal EnableDelayedExpansion
title WINBARS - Bare-Metal System Image Disaster Recovery (WinPE/WinRE)
color 1F

echo ==============================================================================
echo   WINBARS BARE-METAL DISASTER RECOVERY ASSISTANT (DISM / WinPE / WinRE)
echo ==============================================================================
echo   This native Windows utility restores a bare-metal .wim system image
echo   onto your target Windows drive using standard Microsoft DISM and BCDBoot.
echo ==============================================================================
echo.

:: 1. WinRE / WinPE Environment Detection
set "IN_WINPE=0"
if exist "X:\windows\system32" set "IN_WINPE=1"

if "%IN_WINPE%"=="0" (
    echo [!] WARNING: You are running this script inside live Windows!
    echo     You cannot overwrite an active, running Windows installation.
    echo     To restore your system:
    echo       1. Hold Shift and click Restart (or boot from Windows Setup USB).
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
    if /i "%%~nxF"=="_baseline.wim" set "DEFAULT_WIM=!IMG_COUNT!"
)

if "%IMG_COUNT%"=="0" (
    echo [X] ERROR: No .wim system images found in %IMAGE_DIR%
    pause
    exit /b 1
)

echo.
if not "!DEFAULT_WIM!"=="" (
    set /p "PICK=Select image number [1-%IMG_COUNT%] (Default: !DEFAULT_WIM! - _baseline.wim): "
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

echo.
echo ==============================================================================
echo   [!] DANGER: FINAL RESTORATION CONFIRMATION
echo ==============================================================================
echo   Image Source:  !SELECTED_WIM!
echo   Target Volume: !TARGET_DRV!\
echo.
echo   Applying this image will OVERWRITE existing Windows files on !TARGET_DRV!\.
echo   All personal documents, apps, and registry settings on !TARGET_DRV!\ will be
echo   reverted to the exact state captured in this image.
echo ==============================================================================
set /p "CONFIRM=Type YES to begin bare-metal restoration: "
if not "!CONFIRM!"=="YES" (
    echo Restoration cancelled by user.
    pause
    exit /b 0
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