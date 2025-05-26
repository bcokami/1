#!/bin/bash
# Ubuntu 24.04 Setup Script for UMD Drupal Project
# This script sets up a complete LAMP environment optimized for Drupal 11.1.x

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
PROJECT_NAME="umd-drupal"
PROJECT_DIR="/var/www/html/umd"
DB_NAME="drupal_umd"
DB_USER="drupal_user"
DB_PASS="secure_drupal_pass_$(date +%s)"
DOMAIN="umd-drupal.local"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
        exit 1
    fi
}

# Function to check Ubuntu version
check_ubuntu_version() {
    print_status "Checking Ubuntu version..."
    
    if ! command -v lsb_release &> /dev/null; then
        sudo apt update && sudo apt install -y lsb-release
    fi
    
    UBUNTU_VERSION=$(lsb_release -rs)
    if [[ "$UBUNTU_VERSION" != "24.04" ]]; then
        print_warning "This script is optimized for Ubuntu 24.04. Current version: $UBUNTU_VERSION"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "Ubuntu 24.04 detected"
    fi
}

# Function to update system
update_system() {
    print_status "Updating system packages..."
    sudo apt update
    sudo apt upgrade -y
    print_success "System updated"
}

# Function to install LAMP stack
install_lamp() {
    print_status "Installing LAMP stack with PHP 8.3..."
    
    # Install Apache
    sudo apt install -y apache2
    
    # Install MySQL
    sudo apt install -y mysql-server
    
    # Install PHP 8.3 and required extensions
    sudo apt install -y \
        php8.3 \
        php8.3-cli \
        php8.3-fpm \
        php8.3-mysql \
        php8.3-gd \
        php8.3-curl \
        php8.3-mbstring \
        php8.3-xml \
        php8.3-zip \
        php8.3-sqlite3 \
        php8.3-intl \
        php8.3-bcmath \
        php8.3-opcache \
        php8.3-soap \
        php8.3-xsl \
        libapache2-mod-php8.3
    
    print_success "LAMP stack installed"
}

# Function to install additional tools
install_tools() {
    print_status "Installing additional development tools..."
    
    sudo apt install -y \
        composer \
        git \
        unzip \
        curl \
        wget \
        vim \
        htop \
        tree \
        nodejs \
        npm
    
    print_success "Development tools installed"
}

# Function to configure Apache
configure_apache() {
    print_status "Configuring Apache..."
    
    # Enable required modules
    sudo a2enmod rewrite
    sudo a2enmod ssl
    sudo a2enmod headers
    sudo a2enmod php8.3
    
    # Create virtual host configuration
    sudo tee /etc/apache2/sites-available/${PROJECT_NAME}.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName ${DOMAIN}
    DocumentRoot ${PROJECT_DIR}/drupal-cms/web
    
    <Directory ${PROJECT_DIR}/drupal-cms/web>
        AllowOverride All
        Require all granted
        Options -Indexes +FollowSymLinks
    </Directory>
    
    # Security headers
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
    
    ErrorLog \${APACHE_LOG_DIR}/${PROJECT_NAME}_error.log
    CustomLog \${APACHE_LOG_DIR}/${PROJECT_NAME}_access.log combined
</VirtualHost>
EOF
    
    # Enable the site
    sudo a2ensite ${PROJECT_NAME}.conf
    sudo a2dissite 000-default.conf
    
    # Add domain to hosts file
    if ! grep -q "${DOMAIN}" /etc/hosts; then
        echo "127.0.0.1 ${DOMAIN}" | sudo tee -a /etc/hosts
    fi
    
    # Restart Apache
    sudo systemctl restart apache2
    sudo systemctl enable apache2
    
    print_success "Apache configured"
}

# Function to configure MySQL
configure_mysql() {
    print_status "Configuring MySQL..."
    
    # Secure MySQL installation
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASS}';"
    
    # Create database and user
    sudo mysql -u root -p${DB_PASS} -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
    sudo mysql -u root -p${DB_PASS} -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
    sudo mysql -u root -p${DB_PASS} -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
    sudo mysql -u root -p${DB_PASS} -e "FLUSH PRIVILEGES;"
    
    # Start and enable MySQL
    sudo systemctl start mysql
    sudo systemctl enable mysql
    
    print_success "MySQL configured"
    print_status "Database credentials:"
    echo "  Database: ${DB_NAME}"
    echo "  Username: ${DB_USER}"
    echo "  Password: ${DB_PASS}"
}

# Function to optimize PHP configuration
optimize_php() {
    print_status "Optimizing PHP configuration..."
    
    # Create custom PHP configuration
    sudo tee /etc/php/8.3/apache2/conf.d/99-drupal.ini > /dev/null <<EOF
; Drupal optimizations
memory_limit = 512M
max_execution_time = 300
max_input_vars = 3000
post_max_size = 64M
upload_max_filesize = 64M
max_file_uploads = 20

; OpCache optimizations
opcache.enable = 1
opcache.memory_consumption = 128
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = 4000
opcache.revalidate_freq = 2
opcache.fast_shutdown = 1

; Security
expose_php = Off
allow_url_fopen = Off
allow_url_include = Off
EOF
    
    # Copy configuration to CLI
    sudo cp /etc/php/8.3/apache2/conf.d/99-drupal.ini /etc/php/8.3/cli/conf.d/
    
    print_success "PHP optimized"
}

# Function to set up project directory
setup_project_directory() {
    print_status "Setting up project directory..."
    
    # Create project directory
    sudo mkdir -p ${PROJECT_DIR}
    sudo chown -R $USER:www-data ${PROJECT_DIR}
    sudo chmod -R 755 ${PROJECT_DIR}
    
    print_success "Project directory created: ${PROJECT_DIR}"
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    # Check PHP version
    PHP_VERSION=$(php -r "echo PHP_VERSION;")
    if [[ $PHP_VERSION == 8.3* ]]; then
        print_success "PHP 8.3 installed: $PHP_VERSION"
    else
        print_error "PHP 8.3 not found. Current version: $PHP_VERSION"
    fi
    
    # Check required PHP extensions
    REQUIRED_EXTENSIONS=("gd" "curl" "mbstring" "mysql" "xml" "zip" "json" "openssl")
    for ext in "${REQUIRED_EXTENSIONS[@]}"; do
        if php -m | grep -q "^$ext$"; then
            print_success "PHP extension $ext: ✓"
        else
            print_error "PHP extension $ext: ✗"
        fi
    done
    
    # Check services
    if systemctl is-active --quiet apache2; then
        print_success "Apache2: Running"
    else
        print_error "Apache2: Not running"
    fi
    
    if systemctl is-active --quiet mysql; then
        print_success "MySQL: Running"
    else
        print_error "MySQL: Not running"
    fi
    
    # Check Composer
    if command -v composer &> /dev/null; then
        COMPOSER_VERSION=$(composer --version | cut -d' ' -f3)
        print_success "Composer installed: $COMPOSER_VERSION"
    else
        print_error "Composer not found"
    fi
}

# Function to display next steps
display_next_steps() {
    print_success "Ubuntu 24.04 setup completed!"
    echo
    print_status "Next steps to deploy your UMD Drupal project:"
    echo
    echo "1. Clone your project:"
    echo "   cd ${PROJECT_DIR}"
    echo "   git clone [your-repository-url] ."
    echo
    echo "2. Install Drupal dependencies:"
    echo "   cd ${PROJECT_DIR}/drupal-cms"
    echo "   composer install"
    echo
    echo "3. Configure Drupal database settings:"
    echo "   Edit web/sites/default/settings.php with:"
    echo "   Database: ${DB_NAME}"
    echo "   Username: ${DB_USER}"
    echo "   Password: ${DB_PASS}"
    echo
    echo "4. Set proper file permissions:"
    echo "   sudo chown -R www-data:www-data ${PROJECT_DIR}/drupal-cms/web/sites/default/files"
    echo "   sudo chmod -R 777 ${PROJECT_DIR}/drupal-cms/web/sites/default/files"
    echo
    echo "5. Run tests:"
    echo "   cd ${PROJECT_DIR}/drupal-cms"
    echo "   vendor/bin/phpunit web/profiles/drupal_cms_installer/tests/"
    echo
    echo "6. Access your site:"
    echo "   http://${DOMAIN}"
    echo
    print_status "Database credentials saved to: /tmp/drupal_db_credentials.txt"
    echo "Database: ${DB_NAME}" > /tmp/drupal_db_credentials.txt
    echo "Username: ${DB_USER}" >> /tmp/drupal_db_credentials.txt
    echo "Password: ${DB_PASS}" >> /tmp/drupal_db_credentials.txt
}

# Main execution
main() {
    print_status "Starting Ubuntu 24.04 setup for UMD Drupal project..."
    
    check_root
    check_ubuntu_version
    update_system
    install_lamp
    install_tools
    configure_apache
    configure_mysql
    optimize_php
    setup_project_directory
    verify_installation
    display_next_steps
    
    print_success "Setup completed successfully!"
}

# Run main function
main "$@"
