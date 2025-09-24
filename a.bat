@echo off
REM make_500mb_until_1tb.bat
REM Buat file 500MB tiap loop sampai total mencapai 1TB (1,048,576 MB)

setlocal enabledelayedexpansion

REM Output folder (ubah sesuai kebutuhan). %~dp0 = folder script berada
set "OUTDIR=%~dp0random_output"
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

REM Konfigurasi (jangan ubah kecuali tahu apa yg dilakukan)
set /a PER_MB=1024*1024
set /a PER_FILE_MB=500
set /a PER_FILE_BYTES=PER_FILE_MB*PER_MB
set /a TARGET_MB=1024*1024   REM 1 TB = 1024 * 1024 MB = 1,048,576 MB

set /a current_mb=0
set /a index=0

echo Output folder: "%OUTDIR%"
echo Ukuran per file: %PER_FILE_MB% MB
echo Target total   : %TARGET_MB% MB (1 TB)
echo ---------------------------------------------------
echo Tekan Ctrl+C untuk menghentikan manual.

:loop
if %current_mb% GEQ %TARGET_MB% goto done

set /a index+=1
REM nama file unik
set "fname=%OUTDIR%\file_%index%_%RANDOM%.bin"

echo Creating [%index%] %fname%  (%PER_FILE_MB% MB) ...
fsutil file createnew "%fname%" %PER_FILE_BYTES% >nul 2>&1

REM cek keberhasilan pembuatan
if exist "%fname%" (
    set /a current_mb+=PER_FILE_MB
    echo Created: %fname%
    echo Total created: %current_mb% MB / %TARGET_MB% MB
    echo.
) else (
    echo ERROR: Gagal membuat %fname%. Hentikan script.
    goto done
)

REM opsional: jeda singkat (uncomment jika mau)
REM timeout /t 0 /nobreak >nul

goto loop

:done
echo ---------------------------------------------------
echo Selesai. Total dibuat: %current_mb% MB (files: %index%)
echo Lokasi: "%OUTDIR%"
pause
endlocal
