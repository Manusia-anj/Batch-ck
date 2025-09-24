@echo off
REM make_1TB_random.bat
REM Membuat 1 file berukuran 1 TB berisi random bytes (PowerShell)
REM WARNING: Sangat lambat & membutuhkan ruang kosong >= 1 TB

setlocal

REM Nama file output (diletakkan di folder script)
set "OUTDIR=%~dp0"
set "FNAME=file_1TB_random_%DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%.bin"
set "FNAME=%FNAME: =0%"
set "OUTPATH=%OUTDIR%%FNAME%"

echo Output file: "%OUTPATH%"
echo Pastikan ada >= 1 TB ruang kosong. Proses ini akan sangat lambat.
echo Tekan Ctrl+C untuk membatalkan.
echo.

REM Buat PowerShell script sementara
set "PSFILE=%~dp0_make1tb_random_tmp.ps1"
> "%PSFILE%" echo # Temporary PowerShell script created by batch
>> "%PSFILE%" echo $outPath = "%OUTPATH%"
>> "%PSFILE%" echo # 1 TB = 1024^4 bytes
>> "%PSFILE%" echo $targetBytes = 1099511627776
>> "%PSFILE%" echo $chunkSize = 8MB                      # ukuran buffer per tulis (ubah jika perlu)
>> "%PSFILE%" echo Write-Host "Target bytes:" $targetBytes "chunk:" $chunkSize
>> "%PSFILE%" echo if (Test-Path $outPath) {
>> "%PSFILE%" echo     Write-Host "File exists. Removing existing file..." -ForegroundColor Yellow
>> "%PSFILE%" echo     Remove-Item $outPath -Force
>> "%PSFILE%" echo }
>> "%PSFILE%" echo $fs = [System.IO.File]::Open($outPath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
>> "%PSFILE%" echo $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
>> "%PSFILE%" echo $buffer = New-Object byte[] $chunkSize
>> "%PSFILE%" echo $written = 0
>> "%PSFILE%" echo try {
>> "%PSFILE%" echo     while ($written -lt $targetBytes) {
>> "%PSFILE%" echo         $remain = $targetBytes - $written
>> "%PSFILE%" echo         if ($remain -lt $chunkSize) {
>> "%PSFILE%" echo             $toWrite = [int]$remain
>> "%PSFILE%" echo             $buffer = New-Object byte[] $toWrite
>> "%PSFILE%" echo         } else {
>> "%PSFILE%" echo             $toWrite = $chunkSize
>> "%PSFILE%" echo         }
>> "%PSFILE%" echo         $rng.GetBytes($buffer)
>> "%PSFILE%" echo         $fs.Write($buffer, 0, $toWrite)
>> "%PSFILE%" echo         $written += $toWrite
>> "%PSFILE%" echo         $pct = [math]::Round(($written / $targetBytes) * 100, 2)
>> "%PSFILE%" echo         $writtenMB = [math]::Round($written / 1MB, 2)
>> "%PSFILE%" echo         $totalMB = [math]::Round($targetBytes / 1MB, 2)
>> "%PSFILE%" echo         Write-Progress -Activity "Writing 1TB random file" -Status ("{0} MB / {1} MB" -f $writtenMB, $totalMB) -PercentComplete $pct
>> "%PSFILE%" echo     }
>> "%PSFILE%" echo     Write-Host "Done. Wrote" $written "bytes to" $outPath -ForegroundColor Green
>> "%PSFILE%" echo } catch {
>> "%PSFILE%" echo     Write-Host "Error occurred:" $_.Exception.Message -ForegroundColor Red
>> "%PSFILE%" echo } finally {
>> "%PSFILE%" echo     if ($fs) { $fs.Close() }
>> "%PSFILE%" echo     if ($rng) { $rng.Dispose() }
>> "%PSFILE%" echo }

REM Jalankan PowerShell script dengan ExecutionPolicy bypass
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%"

REM Hapus script sementara (opsional - komentar jika mau disimpan)
if exist "%PSFILE%" del /f /q "%PSFILE%"

endlocal
pause
