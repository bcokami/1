<?php
/**
 * Ubuntu 24.04 Compatibility Test for UMD Drupal Project
 * Run this script to verify Ubuntu 24.04 environment compatibility
 */

echo "=== Ubuntu 24.04 Compatibility Test ===\n";
echo "Testing environment for UMD Drupal project...\n\n";

// Test 1: Operating System Check
echo "1. Operating System Check:\n";
echo "-------------------------\n";

$os_info = [];
if (file_exists('/etc/os-release')) {
    $os_release = file_get_contents('/etc/os-release');
    preg_match('/VERSION_ID="([^"]+)"/', $os_release, $version_matches);
    preg_match('/NAME="([^"]+)"/', $os_release, $name_matches);
    
    $os_version = $version_matches[1] ?? 'Unknown';
    $os_name = $name_matches[1] ?? 'Unknown';
    
    echo "OS: $os_name $os_version\n";
    
    if ($os_name === 'Ubuntu' && version_compare($os_version, '24.04', '>=')) {
        echo "✓ Ubuntu 24.04+ detected - EXCELLENT compatibility\n";
        $os_score = 100;
    } elseif ($os_name === 'Ubuntu' && version_compare($os_version, '22.04', '>=')) {
        echo "⚠ Ubuntu 22.04+ detected - Good compatibility (consider upgrading)\n";
        $os_score = 80;
    } elseif (strpos($os_name, 'Ubuntu') !== false) {
        echo "⚠ Older Ubuntu detected - May need manual PHP 8.3 installation\n";
        $os_score = 60;
    } else {
        echo "⚠ Non-Ubuntu system detected - Compatibility may vary\n";
        $os_score = 40;
    }
} else {
    echo "✗ Cannot determine OS version\n";
    $os_score = 0;
}

echo "\n";

// Test 2: PHP Version and Extensions
echo "2. PHP Environment Check:\n";
echo "-------------------------\n";

$php_version = PHP_VERSION;
echo "PHP Version: $php_version\n";

if (version_compare($php_version, '8.3.0', '>=')) {
    echo "✓ PHP 8.3+ detected - Perfect for Drupal 11.1.x\n";
    $php_score = 100;
} elseif (version_compare($php_version, '8.2.0', '>=')) {
    echo "⚠ PHP 8.2 detected - Compatible with workarounds\n";
    $php_score = 80;
} elseif (version_compare($php_version, '8.1.0', '>=')) {
    echo "⚠ PHP 8.1 detected - Minimum requirement, upgrade recommended\n";
    $php_score = 60;
} else {
    echo "✗ PHP version too old for Drupal 11.1.x\n";
    $php_score = 0;
}

// Check required extensions
$required_extensions = [
    'gd' => 'Image processing',
    'curl' => 'HTTP requests',
    'mbstring' => 'Multibyte strings',
    'openssl' => 'SSL/TLS support',
    'pdo' => 'Database abstraction',
    'pdo_mysql' => 'MySQL support',
    'pdo_sqlite' => 'SQLite support',
    'xml' => 'XML processing',
    'zip' => 'Archive handling',
    'fileinfo' => 'File type detection',
    'json' => 'JSON processing',
    'intl' => 'Internationalization'
];

echo "\nPHP Extensions:\n";
$missing_extensions = [];
$extension_score = 0;
foreach ($required_extensions as $ext => $description) {
    if (extension_loaded($ext)) {
        echo "✓ $ext ($description)\n";
        $extension_score += 8.33; // 100/12 extensions
    } else {
        echo "✗ $ext ($description) - MISSING\n";
        $missing_extensions[] = $ext;
    }
}

echo "\n";

// Test 3: Web Server Check
echo "3. Web Server Check:\n";
echo "-------------------\n";

$web_server = $_SERVER['SERVER_SOFTWARE'] ?? 'CLI';
echo "Environment: $web_server\n";

if (strpos($web_server, 'Apache') !== false) {
    echo "✓ Apache detected - Excellent for Drupal\n";
    $server_score = 100;
} elseif (strpos($web_server, 'nginx') !== false) {
    echo "✓ Nginx detected - Good for Drupal\n";
    $server_score = 90;
} elseif ($web_server === 'CLI') {
    echo "ℹ Running in CLI mode - Web server check skipped\n";
    $server_score = 50;
} else {
    echo "⚠ Unknown web server - May need configuration\n";
    $server_score = 30;
}

echo "\n";

// Test 4: Database Connectivity
echo "4. Database Support Check:\n";
echo "--------------------------\n";

$db_score = 0;
$db_drivers = [];

if (extension_loaded('pdo_mysql')) {
    echo "✓ MySQL/MariaDB support available\n";
    $db_drivers[] = 'MySQL';
    $db_score += 50;
}

if (extension_loaded('pdo_sqlite')) {
    echo "✓ SQLite support available\n";
    $db_drivers[] = 'SQLite';
    $db_score += 30;
}

if (extension_loaded('pdo_pgsql')) {
    echo "✓ PostgreSQL support available\n";
    $db_drivers[] = 'PostgreSQL';
    $db_score += 20;
}

if (empty($db_drivers)) {
    echo "✗ No database drivers found\n";
} else {
    echo "Available drivers: " . implode(', ', $db_drivers) . "\n";
}

echo "\n";

// Test 5: File System Permissions
echo "5. File System Check:\n";
echo "--------------------\n";

$temp_dir = sys_get_temp_dir();
$test_file = $temp_dir . '/drupal_test_' . uniqid();

$fs_score = 0;
try {
    // Test file creation
    if (file_put_contents($test_file, 'test') !== false) {
        echo "✓ File creation: Working\n";
        $fs_score += 25;
        
        // Test file reading
        if (file_get_contents($test_file) === 'test') {
            echo "✓ File reading: Working\n";
            $fs_score += 25;
        }
        
        // Test file modification
        if (file_put_contents($test_file, 'modified', LOCK_EX) !== false) {
            echo "✓ File locking: Working\n";
            $fs_score += 25;
        }
        
        // Test file deletion
        if (unlink($test_file)) {
            echo "✓ File deletion: Working\n";
            $fs_score += 25;
        }
    } else {
        echo "✗ File operations: Failed\n";
    }
} catch (Exception $e) {
    echo "✗ File system error: " . $e->getMessage() . "\n";
}

echo "\n";

// Test 6: Memory and Performance
echo "6. Performance Check:\n";
echo "--------------------\n";

$memory_limit = ini_get('memory_limit');
$max_execution_time = ini_get('max_execution_time');

echo "Memory Limit: $memory_limit\n";
echo "Max Execution Time: {$max_execution_time}s\n";

$perf_score = 0;
$memory_bytes = return_bytes($memory_limit);
if ($memory_bytes >= 512 * 1024 * 1024) { // 512MB
    echo "✓ Memory limit adequate for Drupal\n";
    $perf_score += 50;
} else {
    echo "⚠ Memory limit may be too low for Drupal\n";
    $perf_score += 20;
}

if ($max_execution_time >= 120 || $max_execution_time == 0) {
    echo "✓ Execution time adequate\n";
    $perf_score += 50;
} else {
    echo "⚠ Execution time may be too short\n";
    $perf_score += 20;
}

echo "\n";

// Calculate overall score
$overall_score = ($os_score + $php_score + $extension_score + $server_score + $db_score + $fs_score + $perf_score) / 7;

// Display summary
echo "=== COMPATIBILITY SUMMARY ===\n";
echo "OS Compatibility: " . round($os_score) . "%\n";
echo "PHP Environment: " . round(($php_score + $extension_score) / 2) . "%\n";
echo "Web Server: " . round($server_score) . "%\n";
echo "Database Support: " . round($db_score) . "%\n";
echo "File System: " . round($fs_score) . "%\n";
echo "Performance: " . round($perf_score) . "%\n";
echo "\nOVERALL COMPATIBILITY: " . round($overall_score) . "%\n";

if ($overall_score >= 90) {
    echo "🎉 EXCELLENT - Ready for production deployment!\n";
} elseif ($overall_score >= 75) {
    echo "✅ GOOD - Minor optimizations recommended\n";
} elseif ($overall_score >= 60) {
    echo "⚠️  FAIR - Some issues need attention\n";
} else {
    echo "❌ POOR - Significant issues need resolution\n";
}

// Recommendations
echo "\n=== RECOMMENDATIONS ===\n";

if ($os_score < 80) {
    echo "• Consider upgrading to Ubuntu 24.04 LTS for best compatibility\n";
}

if ($php_score < 90) {
    echo "• Upgrade to PHP 8.3+ for optimal Drupal 11.1.x support\n";
}

if (!empty($missing_extensions)) {
    echo "• Install missing PHP extensions:\n";
    foreach ($missing_extensions as $ext) {
        echo "  sudo apt install php8.3-$ext\n";
    }
}

if ($fs_score < 100) {
    echo "• Check file system permissions and disk space\n";
}

if ($perf_score < 80) {
    echo "• Optimize PHP configuration for better performance\n";
}

echo "\n";

// Helper function to convert memory limit to bytes
function return_bytes($val) {
    $val = trim($val);
    $last = strtolower($val[strlen($val)-1]);
    $val = (int)$val;
    switch($last) {
        case 'g':
            $val *= 1024;
        case 'm':
            $val *= 1024;
        case 'k':
            $val *= 1024;
    }
    return $val;
}

echo "Test completed at: " . date('Y-m-d H:i:s') . "\n";
?>
