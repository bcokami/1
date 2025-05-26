# Complete PHP 8.3+ Setup Guide for Drupal Testing

## Current Situation
- **Current PHP**: 8.2.12 (XAMPP installation)
- **Required PHP**: 8.3+ for Drupal 11.1.x
- **Missing Extensions**: GD extension not enabled
- **Goal**: Run full Drupal test suite

## Option 1: Quick Fix - Enable GD Extension (Temporary Solution)

### Step 1: Edit php.ini
1. Open `C:\xampp\php\php.ini` in a text editor (as Administrator)
2. Find the line `;extension=gd` (around line 900-950)
3. Remove the semicolon: `extension=gd`
4. Save the file
5. Restart XAMPP Apache service

### Step 2: Verify GD Extension
```bash
php -m | findstr gd
```

### Step 3: Try Installing Dependencies with Platform Override
```bash
cd C:\Install\eds\MLM\1\umd\drupal-cms
composer install --ignore-platform-req=php --ignore-platform-req=ext-gd
```

## Option 2: Full PHP 8.3 Upgrade (Recommended)

### Method A: Download New XAMPP
1. **Download**: XAMPP 8.3.12 from https://www.apachefriends.org/download.html
2. **Backup**: Copy your current `C:\xampp` to `C:\xampp_backup`
3. **Install**: New XAMPP (will replace current installation)
4. **Restore**: Copy databases and configurations from backup

### Method B: Manual PHP Upgrade (Keep Current XAMPP)
1. **Download PHP 8.3.15**: https://windows.php.net/downloads/releases/php-8.3.15-Win32-vs16-x64.zip
2. **Stop XAMPP**: Stop Apache and MySQL services
3. **Backup**: `copy C:\xampp\php C:\xampp\php_backup`
4. **Extract**: New PHP to `C:\xampp\php` (replace existing)
5. **Configure**: Copy `php.ini` from backup or create new
6. **Enable Extensions**: Edit php.ini to enable required extensions

### Required Extensions for Drupal
```ini
extension=curl
extension=fileinfo
extension=gd
extension=mbstring
extension=openssl
extension=pdo_mysql
extension=pdo_sqlite
extension=sqlite3
extension=xml
extension=zip
```

## Step-by-Step Commands After PHP Upgrade

### 1. Verify PHP Version
```bash
php --version
# Should show PHP 8.3.x
```

### 2. Check Extensions
```bash
php -m | findstr -E "(gd|curl|mbstring|pdo)"
```

### 3. Install Drush Globally
```bash
composer global require drush/drush
```

### 4. Add Composer Global Bin to PATH
Add `%APPDATA%\Composer\vendor\bin` to your system PATH environment variable

### 5. Navigate to Project Directory
```bash
cd C:\Install\eds\MLM\1\umd\drupal-cms
```

### 6. Install Project Dependencies
```bash
composer install
```

### 7. Run Tests
```bash
# Run all tests
vendor\bin\phpunit web\profiles\drupal_cms_installer\tests\

# Run specific test
vendor\bin\phpunit web\profiles\drupal_cms_installer\tests\src\Functional\CommandLineInstallTest.php

# Run with verbose output
vendor\bin\phpunit --verbose web\profiles\drupal_cms_installer\tests\
```

## Alternative: Use Docker for Testing

If PHP upgrade is problematic, consider using Docker:

### Create Dockerfile
```dockerfile
FROM php:8.3-cli

# Install required extensions
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    unzip \
    git

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

RUN composer install
```

### Run Tests in Docker
```bash
docker build -t drupal-test .
docker run -it drupal-test vendor/bin/phpunit web/profiles/drupal_cms_installer/tests/
```

## Troubleshooting Common Issues

### Issue 1: Composer Memory Limit
```bash
php -d memory_limit=-1 composer install
```

### Issue 2: Network Timeouts
```bash
composer config --global process-timeout 2000
composer install
```

### Issue 3: Platform Requirements
```bash
composer install --ignore-platform-reqs
```

### Issue 4: PHPUnit Not Found
```bash
# Install PHPUnit globally
composer global require phpunit/phpunit

# Or use project-specific installation
./vendor/bin/phpunit
```

## Expected Test Results

After successful setup, you should see output like:
```
PHPUnit 10.x.x by Sebastian Bergmann and contributors.

..                                                                  2 / 2 (100%)

Time: 00:30.123, Memory: 128.00 MB

OK (2 tests, 8 assertions)
```

## Next Steps After Successful Test Run

1. **Create Custom Tests**: Write tests for UMD module functionality
2. **Set up CI/CD**: Implement automated testing pipeline
3. **Code Coverage**: Generate test coverage reports
4. **Performance Testing**: Add performance benchmarks

---

**Note**: If you encounter issues with any step, please run the commands one by one and check for error messages. The most critical steps are:
1. PHP 8.3+ installation
2. GD extension enabled
3. Composer dependencies installed
4. PHPUnit available in vendor/bin/
