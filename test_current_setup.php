<?php
/**
 * Test current PHP setup for Drupal requirements
 */

echo "=== PHP Environment Test ===\n";
echo "PHP Version: " . PHP_VERSION . "\n";
echo "PHP SAPI: " . php_sapi_name() . "\n";
echo "\n";

// Check required extensions
$required_extensions = [
    'gd' => 'GD (Image processing)',
    'curl' => 'cURL (HTTP requests)',
    'mbstring' => 'Multibyte String',
    'openssl' => 'OpenSSL',
    'pdo' => 'PDO (Database)',
    'pdo_mysql' => 'PDO MySQL',
    'pdo_sqlite' => 'PDO SQLite',
    'xml' => 'XML',
    'zip' => 'ZIP',
    'fileinfo' => 'File Info'
];

echo "=== Extension Check ===\n";
$missing_extensions = [];
foreach ($required_extensions as $ext => $description) {
    if (extension_loaded($ext)) {
        echo "✓ $ext ($description)\n";
    } else {
        echo "✗ $ext ($description) - MISSING\n";
        $missing_extensions[] = $ext;
    }
}

echo "\n";

// Check PHP version compatibility
echo "=== Version Compatibility ===\n";
if (version_compare(PHP_VERSION, '8.3.0', '>=')) {
    echo "✓ PHP version is compatible with Drupal 11.1.x\n";
} else {
    echo "✗ PHP version is too old. Drupal 11.1.x requires PHP 8.3+\n";
    echo "  Current: " . PHP_VERSION . "\n";
    echo "  Required: 8.3.0+\n";
}

echo "\n";

// Check Composer
echo "=== Composer Check ===\n";
$composer_output = [];
$composer_return = 0;
exec('composer --version 2>&1', $composer_output, $composer_return);

if ($composer_return === 0) {
    echo "✓ Composer is available\n";
    echo "  " . implode("\n  ", $composer_output) . "\n";
} else {
    echo "✗ Composer not found or not working\n";
}

echo "\n";

// Memory and other settings
echo "=== PHP Configuration ===\n";
echo "Memory Limit: " . ini_get('memory_limit') . "\n";
echo "Max Execution Time: " . ini_get('max_execution_time') . "s\n";
echo "Upload Max Filesize: " . ini_get('upload_max_filesize') . "\n";
echo "Post Max Size: " . ini_get('post_max_size') . "\n";

echo "\n";

// Summary
echo "=== Summary ===\n";
if (empty($missing_extensions) && version_compare(PHP_VERSION, '8.3.0', '>=')) {
    echo "✓ Environment is ready for Drupal 11.1.x testing!\n";
    echo "\nNext steps:\n";
    echo "1. cd umd/drupal-cms\n";
    echo "2. composer install\n";
    echo "3. vendor/bin/phpunit web/profiles/drupal_cms_installer/tests/\n";
} else {
    echo "✗ Environment needs fixes:\n";
    
    if (!empty($missing_extensions)) {
        echo "\nMissing extensions (enable in php.ini):\n";
        foreach ($missing_extensions as $ext) {
            echo "  - extension=$ext\n";
        }
    }
    
    if (version_compare(PHP_VERSION, '8.3.0', '<')) {
        echo "\nPHP upgrade needed:\n";
        echo "  - Download PHP 8.3+ from https://windows.php.net/downloads/\n";
        echo "  - Or download XAMPP 8.3+ from https://www.apachefriends.org/\n";
    }
    
    echo "\nAlternative: Try with platform overrides:\n";
    echo "  composer install --ignore-platform-reqs\n";
}

echo "\n";
?>
