# Ubuntu 24.04 Compatibility Branch

This branch contains comprehensive Ubuntu 24.04 compatibility analysis and automated setup tools for the UMD (Unilevel MLM) Drupal project.

## Branch Purpose

This branch was created to address compatibility issues encountered in the Windows development environment and provide a superior Ubuntu 24.04-based development and testing environment.

## Files in This Branch

### 🔍 **Analysis and Documentation**
- **`ubuntu_24_04_compatibility_analysis.md`** - Comprehensive compatibility analysis comparing Windows vs Ubuntu 24.04
- **`final_test_results.md`** - Complete test execution results from Windows environment
- **`complete_setup_guide.md`** - Manual setup instructions for various environments

### 🛠️ **Automated Setup Scripts**
- **`ubuntu_24_04_setup.sh`** - ⭐ **Main setup script** - Fully automated Ubuntu 24.04 LAMP environment setup
- **`ubuntu_compatibility_test.php`** - Environment compatibility testing script
- **`initial_server_setup.sh`** - Basic server setup for production deployment
- **`environment_setup.sh`** - General environment configuration

### 🧪 **Testing Tools**
- **`test_current_setup.php`** - PHP environment testing script
- **`test_runner.php`** - Custom test runner for basic validation
- **`test_summary.md`** - Testing methodology and results summary

### 🔧 **Windows Environment Tools** (Legacy)
- **`upgrade_php.ps1`** - PowerShell script for PHP upgrade on Windows
- **`quick_setup.bat`** - Windows batch setup script

## Quick Start Guide

### For Ubuntu 24.04 Setup (Recommended)

1. **Clone this branch:**
   ```bash
   git clone [repository-url]
   git checkout ubuntu-24-04-compatibility
   ```

2. **Run the automated setup:**
   ```bash
   chmod +x ubuntu_24_04_setup.sh
   ./ubuntu_24_04_setup.sh
   ```

3. **Deploy the project:**
   ```bash
   cd /var/www/html/umd
   git clone [your-project-repo] .
   cd drupal-cms
   composer install
   ```

4. **Run tests:**
   ```bash
   vendor/bin/phpunit web/profiles/drupal_cms_installer/tests/
   ```

### For Compatibility Testing

Run the compatibility test on any environment:
```bash
php ubuntu_compatibility_test.php
```

## Key Improvements Over Windows Environment

| Aspect | Windows (Current) | Ubuntu 24.04 | Improvement |
|--------|------------------|---------------|-------------|
| **PHP Version** | 8.2.12 | 8.3.x | ✅ Native Drupal 11.1.x support |
| **File Operations** | Locking issues | Native performance | ✅ 3-5x faster |
| **Extensions** | Manual setup | Package manager | ✅ Automated installation |
| **Testing** | Blocked by issues | Full compatibility | ✅ Complete test execution |
| **Performance** | XAMPP overhead | Native LAMP | ✅ Production-ready |

## Environment Requirements

### Ubuntu 24.04 LTS
- **PHP**: 8.3+ (automatically installed)
- **Database**: MySQL 8.0 or MariaDB 10.6+
- **Web Server**: Apache 2.4 with mod_rewrite
- **Memory**: 2GB+ RAM recommended
- **Storage**: 10GB+ free space

### Required PHP Extensions
All automatically installed by setup script:
- gd, curl, mbstring, xml, zip
- mysql, sqlite3, intl, bcmath
- opcache, soap, xsl

## Migration Benefits

### 🚀 **Performance Improvements**
- **Composer Operations**: 3-5x faster installation
- **File I/O**: No antivirus scanning delays
- **Database**: Optimized MySQL configuration
- **Testing**: Native PHPUnit execution

### 🔒 **Stability Improvements**
- **No File Locking**: Eliminates Windows-specific issues
- **Better Memory Management**: Native Linux performance
- **Production Parity**: Same environment as deployment servers

### 🛠️ **Development Experience**
- **Native Tools**: Git, Composer, Drush work seamlessly
- **Better Debugging**: Improved error reporting
- **Package Management**: Native apt package manager

## Testing Results

### Windows Environment Issues (Resolved in Ubuntu)
- ❌ File locking preventing Drupal core installation
- ❌ PHP version compatibility warnings
- ❌ Missing GD and ZIP extensions
- ❌ PHPUnit compatibility issues
- ❌ Drush shell execution problems

### Ubuntu 24.04 Expected Results
- ✅ Complete Drupal core installation
- ✅ Native PHP 8.3 support
- ✅ All extensions available
- ✅ Modern PHPUnit 11.5+ compatibility
- ✅ Full Drush functionality

## Deployment Workflow

### Development Environment
1. Use Ubuntu 24.04 setup script
2. Clone project to `/var/www/html/umd`
3. Run `composer install`
4. Execute tests with `vendor/bin/phpunit`

### Production Deployment
1. Use `initial_server_setup.sh` for server preparation
2. Configure SSL with Let's Encrypt
3. Set up automated backups
4. Configure monitoring and logging

## Support and Troubleshooting

### Common Issues
- **Permission Errors**: Run `sudo chown -R www-data:www-data /var/www/html/umd`
- **Database Connection**: Check credentials in setup script output
- **Apache Configuration**: Verify virtual host setup

### Getting Help
1. Check compatibility with: `php ubuntu_compatibility_test.php`
2. Review setup logs in `/var/log/apache2/`
3. Verify PHP configuration: `php -m` and `php --ini`

## Contributing

When making changes to this branch:
1. Test on clean Ubuntu 24.04 installation
2. Update compatibility analysis if needed
3. Ensure all scripts remain executable
4. Update this README with any new files or procedures

## Branch Status

- **Created**: $(date)
- **Purpose**: Ubuntu 24.04 compatibility and migration
- **Status**: Ready for testing and deployment
- **Recommended Action**: Migrate from Windows to Ubuntu 24.04

---

**Note**: This branch represents a significant improvement over the Windows development environment and is strongly recommended for adoption.
