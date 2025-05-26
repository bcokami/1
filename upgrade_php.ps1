# PowerShell script to upgrade PHP to 8.3+ for XAMPP
# Run this script as Administrator

Write-Host "=== PHP 8.3+ Upgrade Script for XAMPP ===" -ForegroundColor Green
Write-Host ""

# Check current PHP version
Write-Host "Current PHP Version:" -ForegroundColor Yellow
php --version

Write-Host ""
Write-Host "Upgrading to PHP 8.3..." -ForegroundColor Yellow

# Create backup directory
$backupDir = "C:\xampp\php_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Write-Host "Creating backup of current PHP installation..." -ForegroundColor Cyan
if (Test-Path "C:\xampp\php") {
    Copy-Item -Path "C:\xampp\php" -Destination $backupDir -Recurse -Force
    Write-Host "Backup created at: $backupDir" -ForegroundColor Green
}

# Download PHP 8.3 (Thread Safe version for Windows)
$phpUrl = "https://windows.php.net/downloads/releases/php-8.3.15-Win32-vs16-x64.zip"
$downloadPath = "$env:TEMP\php-8.3.15.zip"
$extractPath = "C:\xampp\php_new"

Write-Host "Downloading PHP 8.3.15..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $phpUrl -OutFile $downloadPath -UseBasicParsing
    Write-Host "Download completed!" -ForegroundColor Green
} catch {
    Write-Host "Download failed. Please download manually from: $phpUrl" -ForegroundColor Red
    Write-Host "Extract to C:\xampp\php_new and run this script again." -ForegroundColor Red
    exit 1
}

# Extract PHP
Write-Host "Extracting PHP 8.3.15..." -ForegroundColor Cyan
if (Test-Path $extractPath) {
    Remove-Item -Path $extractPath -Recurse -Force
}
Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

# Stop XAMPP services
Write-Host "Stopping XAMPP services..." -ForegroundColor Cyan
try {
    Stop-Service -Name "Apache2.4" -ErrorAction SilentlyContinue
    Stop-Service -Name "mysql" -ErrorAction SilentlyContinue
} catch {
    Write-Host "Could not stop services automatically. Please stop XAMPP manually." -ForegroundColor Yellow
}

# Replace PHP directory
Write-Host "Replacing PHP installation..." -ForegroundColor Cyan
if (Test-Path "C:\xampp\php") {
    Remove-Item -Path "C:\xampp\php" -Recurse -Force
}
Move-Item -Path $extractPath -Destination "C:\xampp\php"

# Copy php.ini from backup
Write-Host "Restoring php.ini configuration..." -ForegroundColor Cyan
if (Test-Path "$backupDir\php.ini") {
    Copy-Item -Path "$backupDir\php.ini" -Destination "C:\xampp\php\php.ini" -Force
    Write-Host "php.ini restored from backup" -ForegroundColor Green
} else {
    # Create basic php.ini from php.ini-development
    if (Test-Path "C:\xampp\php\php.ini-development") {
        Copy-Item -Path "C:\xampp\php\php.ini-development" -Destination "C:\xampp\php\php.ini" -Force
        Write-Host "Created php.ini from php.ini-development" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== Enabling Required Extensions ===" -ForegroundColor Green

# Enable GD extension and other required extensions
$phpIniPath = "C:\xampp\php\php.ini"
if (Test-Path $phpIniPath) {
    $phpIniContent = Get-Content $phpIniPath
    
    # Enable extensions
    $extensions = @(
        "extension=gd",
        "extension=curl",
        "extension=fileinfo",
        "extension=mbstring",
        "extension=openssl",
        "extension=pdo_mysql",
        "extension=pdo_sqlite",
        "extension=sqlite3"
    )
    
    foreach ($ext in $extensions) {
        $extName = $ext.Split('=')[1]
        $pattern = "^;?\s*$ext"
        
        if ($phpIniContent -match $pattern) {
            $phpIniContent = $phpIniContent -replace "^;?\s*$ext", $ext
            Write-Host "Enabled: $extName" -ForegroundColor Green
        } else {
            $phpIniContent += "`n$ext"
            Write-Host "Added: $extName" -ForegroundColor Green
        }
    }
    
    # Write updated php.ini
    $phpIniContent | Set-Content $phpIniPath
    Write-Host "php.ini updated with required extensions" -ForegroundColor Green
}

# Clean up
Remove-Item -Path $downloadPath -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "=== Upgrade Complete! ===" -ForegroundColor Green
Write-Host "Please restart XAMPP and verify the PHP version:" -ForegroundColor Yellow
Write-Host "php --version" -ForegroundColor Cyan
Write-Host ""
Write-Host "If you encounter issues, restore from backup:" -ForegroundColor Yellow
Write-Host "1. Stop XAMPP services" -ForegroundColor Cyan
Write-Host "2. Delete C:\xampp\php" -ForegroundColor Cyan
Write-Host "3. Rename $backupDir to C:\xampp\php" -ForegroundColor Cyan
Write-Host "4. Restart XAMPP" -ForegroundColor Cyan
