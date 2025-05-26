@echo off
echo === Quick PHP 8.3 Setup for Drupal Testing ===
echo.

echo Current PHP Version:
php --version
echo.

echo === Step 1: Download and Install PHP 8.3 ===
echo Please follow these manual steps:
echo 1. Download PHP 8.3.15 Thread Safe from: https://windows.php.net/downloads/releases/
echo 2. Stop XAMPP services
echo 3. Backup C:\xampp\php to C:\xampp\php_backup
echo 4. Extract downloaded PHP to C:\xampp\php
echo 5. Copy php.ini from backup or create from php.ini-development
echo.

echo === Step 2: Enable GD Extension ===
echo Edit C:\xampp\php\php.ini and uncomment/add:
echo extension=gd
echo extension=curl
echo extension=fileinfo
echo extension=mbstring
echo extension=openssl
echo extension=pdo_mysql
echo extension=pdo_sqlite
echo extension=sqlite3
echo.

echo === Step 3: Restart XAMPP ===
echo Restart Apache and MySQL services
echo.

echo === Step 4: Verify Installation ===
echo Run: php --version
echo Should show PHP 8.3.x
echo.

echo === Step 5: Install Drush ===
echo Run: composer global require drush/drush
echo.

echo === Step 6: Install Project Dependencies ===
echo cd to project directory and run: composer install
echo.

echo === Step 7: Run Tests ===
echo Run: vendor/bin/phpunit web/profiles/drupal_cms_installer/tests/
echo.

pause
