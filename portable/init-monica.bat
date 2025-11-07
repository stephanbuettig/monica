@echo off
REM ============================================
REM Monica Portable - Initialisierung
REM Wird beim ersten Start automatisch aufgerufen
REM ============================================
SETLOCAL ENABLEDELAYEDEXPANSION

set SCRIPT_DIR=%~dp0
set APP_ROOT=%SCRIPT_DIR%..
set PHP_DIR=%SCRIPT_DIR%php
set PHP_EXE=%PHP_DIR%\php.exe

cd /d "%APP_ROOT%"

echo ========================================
echo  Monica Initialisierung
echo ========================================
echo.

REM Erstelle notwendige Verzeichnisse
echo [1/6] Erstelle Verzeichnisse...
if not exist "database" mkdir database
if not exist "storage\logs" mkdir storage\logs
if not exist "storage\framework\cache" mkdir storage\framework\cache
if not exist "storage\framework\sessions" mkdir storage\framework\sessions
if not exist "storage\framework\views" mkdir storage\framework\views
if not exist "storage\app\public" mkdir storage\app\public

REM Generiere App Key falls nötig
echo [2/6] Generiere Application Key...
findstr "APP_KEY=base64:" .env > nul
if %errorlevel% neq 0 (
    "%PHP_EXE%" artisan key:generate --force
) else (
    echo    Key bereits vorhanden, ueberspringe...
)

REM Erstelle SQLite Datenbank
echo [3/6] Erstelle SQLite Datenbank...
if not exist "database\database.sqlite" (
    type nul > "database\database.sqlite"
    echo    Datenbank erstellt: database\database.sqlite
) else (
    echo    Datenbank existiert bereits.
)

REM Setze Berechtigungen (wichtig für Laravel)
echo [4/6] Konfiguriere Berechtigungen...
attrib -R "%APP_ROOT%\storage\*" /S /D
attrib -R "%APP_ROOT%\bootstrap\cache\*" /S /D

REM Führe Migrationen aus
echo [5/6] Fuehre Datenbank-Migrationen aus...
echo    Dies kann einige Minuten dauern...
"%PHP_EXE%" artisan migrate --force --seed

if %errorlevel% neq 0 (
    echo.
    echo FEHLER: Migration fehlgeschlagen!
    exit /b 1
)

REM Cache aufbauen
echo [6/6] Baue Cache auf...
"%PHP_EXE%" artisan config:cache
"%PHP_EXE%" artisan route:cache
"%PHP_EXE%" artisan view:cache

echo.
echo ========================================
echo  Initialisierung erfolgreich!
echo ========================================
echo.

exit /b 0
