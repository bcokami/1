<?php
/**
 * Simple test runner for the UMD project
 * This script performs basic syntax checks and simple tests
 */

echo "=== UMD Project Test Runner ===\n";
echo "Starting test execution...\n\n";

// Test 1: PHP Syntax Check
echo "1. PHP Syntax Checks:\n";
echo "---------------------\n";

$php_files = [
    'umd/unilevelmlm.module',
    'umd/src/UmpClass.php',
    'umd/unilevelmlm.install'
];

$syntax_errors = 0;
foreach ($php_files as $file) {
    if (file_exists($file)) {
        echo "Checking: $file ... ";
        $output = [];
        $return_code = 0;
        exec("php -l \"$file\" 2>&1", $output, $return_code);
        
        if ($return_code === 0) {
            echo "✓ PASS\n";
        } else {
            echo "✗ FAIL\n";
            echo "  Error: " . implode("\n  ", $output) . "\n";
            $syntax_errors++;
        }
    } else {
        echo "Checking: $file ... ✗ FILE NOT FOUND\n";
        $syntax_errors++;
    }
}

echo "\n";

// Test 2: Configuration File Validation
echo "2. Configuration File Validation:\n";
echo "----------------------------------\n";

$config_files = [
    'umd/unilevelmlm.info.yml' => 'YAML',
    'umd/unilevelmlm.libraries.yml' => 'YAML',
    'umd/unilevelmlm.routing.yml' => 'YAML',
    'umd/drupal-cms/composer.json' => 'JSON'
];

$config_errors = 0;
foreach ($config_files as $file => $type) {
    if (file_exists($file)) {
        echo "Validating: $file ($type) ... ";
        
        if ($type === 'JSON') {
            $content = file_get_contents($file);
            $decoded = json_decode($content);
            if (json_last_error() === JSON_ERROR_NONE) {
                echo "✓ PASS\n";
            } else {
                echo "✗ FAIL - " . json_last_error_msg() . "\n";
                $config_errors++;
            }
        } elseif ($type === 'YAML') {
            // Basic YAML validation (checking for basic structure)
            $content = file_get_contents($file);
            if (strpos($content, ':') !== false) {
                echo "✓ PASS (basic structure)\n";
            } else {
                echo "✗ FAIL - Invalid YAML structure\n";
                $config_errors++;
            }
        }
    } else {
        echo "Validating: $file ... ✗ FILE NOT FOUND\n";
        $config_errors++;
    }
}

echo "\n";

// Test 3: Directory Structure Check
echo "3. Directory Structure Check:\n";
echo "-----------------------------\n";

$required_dirs = [
    'umd',
    'umd/css',
    'umd/js',
    'umd/templates',
    'umd/src',
    'umd/config',
    'umd/drupal-cms'
];

$structure_errors = 0;
foreach ($required_dirs as $dir) {
    echo "Checking directory: $dir ... ";
    if (is_dir($dir)) {
        echo "✓ EXISTS\n";
    } else {
        echo "✗ MISSING\n";
        $structure_errors++;
    }
}

echo "\n";

// Test 4: File Permissions Check (Windows compatible)
echo "4. File Accessibility Check:\n";
echo "-----------------------------\n";

$important_files = [
    'umd/unilevelmlm.module',
    'umd/unilevelmlm.info.yml',
    'umd/drupal-cms/composer.json'
];

$permission_errors = 0;
foreach ($important_files as $file) {
    echo "Checking accessibility: $file ... ";
    if (file_exists($file) && is_readable($file)) {
        echo "✓ READABLE\n";
    } else {
        echo "✗ NOT ACCESSIBLE\n";
        $permission_errors++;
    }
}

echo "\n";

// Test Summary
echo "=== TEST SUMMARY ===\n";
echo "Syntax Errors: $syntax_errors\n";
echo "Configuration Errors: $config_errors\n";
echo "Structure Errors: $structure_errors\n";
echo "Permission Errors: $permission_errors\n";

$total_errors = $syntax_errors + $config_errors + $structure_errors + $permission_errors;

if ($total_errors === 0) {
    echo "\n✓ ALL TESTS PASSED! The project structure and basic syntax are valid.\n";
    exit(0);
} else {
    echo "\n✗ $total_errors ERRORS FOUND. Please review the issues above.\n";
    exit(1);
}
?>
