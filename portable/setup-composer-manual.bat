@echo off
REM ============================================
REM Monica Portable - Manuelle Composer Installation
REM Nutzen Sie dieses Script, wenn setup-composer.bat nicht funktioniert
REM ============================================
SETLOCAL ENABLEDELAYEDEXPANSION

echo.
echo ========================================
echo  Monica Portable - Composer Manuell
echo ========================================
echo.

set SCRIPT_DIR=%~dp0
set APP_ROOT=%SCRIPT_DIR%..
set PHP_DIR=%SCRIPT_DIR%php
set PHP_EXE=%PHP_DIR%\php.exe
set COMPOSER_PHAR=%SCRIPT_DIR%composer.phar

REM Zeige Pfade zur Verifizierung
echo Verzeichnis-Informationen:
echo ========================
echo Script-Verzeichnis: %SCRIPT_DIR%
echo Monica-Verzeichnis: %APP_ROOT%
echo.

REM Prüfe ob wir im richtigen Verzeichnis sind
if not exist "%APP_ROOT%\composer.json" (
    echo WARNUNG: composer.json nicht im Monica-Verzeichnis gefunden!
    echo Erwartet in: %APP_ROOT%\composer.json
    echo.
    echo Sind Sie im richtigen Ordner?
    echo Dieses Script MUSS aus dem portable\ Unterordner
    echo des Monica-Projekts ausgefuehrt werden!
    echo.
    pause
)

REM Prüfe ob PHP installiert ist
if not exist "%PHP_EXE%" (
    echo FEHLER: PHP nicht gefunden!
    echo Erwartet in: %PHP_EXE%
    echo.
    echo Bitte fuehren Sie zuerst setup-php.bat aus.
    pause
    exit /b 1
)

echo Diese Anleitung hilft Ihnen, Composer manuell zu installieren.
echo.
echo WICHTIG: composer.phar muss in diesem Ordner gespeichert werden:
echo %SCRIPT_DIR%
echo.

REM Prüfe ob composer.phar bereits vorhanden
if exist "%COMPOSER_PHAR%" (
    echo [OK] Composer.phar wurde gefunden!
    echo Vollstaendiger Pfad: %COMPOSER_PHAR%
    echo.

    REM Prüfe ob composer.json auch existiert
    if not exist "%APP_ROOT%\composer.json" (
        echo [FEHLER] composer.json NICHT gefunden!
        echo Erwartet in: %APP_ROOT%\composer.json
        echo.
        echo Das bedeutet, dass Sie vermutlich im FALSCHEN Ordner sind!
        echo.
        echo RICHTIG: monica-claude-monica-...\portable\composer.phar
        echo FALSCH:   CRM\portable\composer.phar
        echo.
        echo Bitte verschieben Sie composer.phar in den richtigen Ordner:
        echo %SCRIPT_DIR%
        echo.
        pause
        exit /b 1
    )

    goto :install_dependencies
) else (
    echo [!] Composer.phar wurde NICHT gefunden.
    echo Erwartet in: %COMPOSER_PHAR%
    echo.
)

echo ========================================
echo  OPTION 1: Direkter Download (Empfohlen)
echo ========================================
echo.
echo 1. Oeffnen Sie im Browser:
echo    https://getcomposer.org/download/
echo.
echo 2. Klicken Sie auf "Download Composer (executable)"
echo    oder laden Sie direkt herunter:
echo    https://getcomposer.org/composer.phar
echo.
echo 3. Speichern Sie die Datei als "composer.phar" in:
echo    %SCRIPT_DIR%
echo.
echo 4. Druecken Sie danach eine Taste um fortzufahren
echo.
pause

REM Prüfe erneut
if not exist "%COMPOSER_PHAR%" (
    echo.
    echo ========================================
    echo  OPTION 2: Mit curl herunterladen
    echo ========================================
    echo.
    echo Falls Sie curl haben, versuchen wir den Download...
    echo.

    curl -sS https://getcomposer.org/installer -o "%TEMP%\composer-setup.php"

    if errorlevel 1 (
        echo Curl-Download fehlgeschlagen.
        goto :manual_only
    )

    echo Installiere Composer...
    "%PHP_EXE%" "%TEMP%\composer-setup.php" --install-dir="%SCRIPT_DIR%" --filename=composer.phar
    del "%TEMP%\composer-setup.php" 2>nul

    if not exist "%COMPOSER_PHAR%" (
        goto :manual_only
    )

    echo Composer erfolgreich installiert!
    goto :install_dependencies
)

:manual_only
echo.
echo Composer konnte nicht automatisch installiert werden.
echo.
echo Bitte laden Sie composer.phar manuell herunter:
echo  1. Browser: https://getcomposer.org/composer.phar
echo  2. Datei speichern in: %SCRIPT_DIR%
echo  3. Dieses Script erneut ausfuehren
echo.
pause
exit /b 1

:install_dependencies
echo.
echo ========================================
echo  Monica Dependencies installieren
echo ========================================
echo.

cd /d "%APP_ROOT%"

if not exist "composer.json" (
    echo FEHLER: composer.json nicht gefunden!
    pause
    exit /b 1
)

echo ACHTUNG: Dies kann 5-15 Minuten dauern!
echo Bitte haben Sie Geduld...
echo.
pause

REM Setze Composer Variablen
set COMPOSER_HOME=%SCRIPT_DIR%\.composer
set COMPOSER_CACHE_DIR=%SCRIPT_DIR%\.composer\cache

if not exist "%COMPOSER_HOME%" mkdir "%COMPOSER_HOME%"
if not exist "%COMPOSER_CACHE_DIR%" mkdir "%COMPOSER_CACHE_DIR%"

echo Starte Installation...
echo.

"%PHP_EXE%" "%COMPOSER_PHAR%" install --no-dev --optimize-autoloader --no-interaction

if errorlevel 1 (
    echo.
    echo FEHLER: Composer Install fehlgeschlagen!
    echo.
    echo Versuchen Sie:
    echo  1. Als Administrator ausfuehren
    echo  2. Antivirenprogramm temporaer deaktivieren
    echo  3. Internetverbindung pruefen
    echo  4. Anderen Browser fuer Download versuchen
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo  Installation erfolgreich!
echo ========================================
echo.

if exist "vendor\autoload.php" (
    echo [OK] vendor\autoload.php gefunden
    echo.
    echo Monica ist jetzt bereit!
    echo Fuehren Sie start-monica.bat aus.
) else (
    echo [FEHLER] vendor\autoload.php nicht gefunden!
    echo Bitte pruefen Sie die Installation.
)

echo.
pause
