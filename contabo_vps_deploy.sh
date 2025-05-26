#!/bin/bash
# Contabo VPS Deployment Script for UMD Drupal Project
# Optimized for Contabo VPS infrastructure with Ubuntu 24.04

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="umd-drupal"
PROJECT_DIR="/var/www/html/umd"
DB_NAME="drupal_umd_prod"
DB_USER="drupal_prod"
DB_PASS="UMD_$(openssl rand -base64 12 | tr -d '=+/' | cut -c1-16)"
DOMAIN=""
EMAIL=""

# Contabo VPS optimizations
CONTABO_OPTIMIZATIONS=true
ENABLE_SSL=true
ENABLE_MONITORING=true
ENABLE_BACKUPS=true

# Function to print colored output
print_status() {
    echo -e "${BLUE}[CONTABO-DEPLOY]${NC} $1"
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

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root on Contabo VPS"
        print_status "Please run: sudo $0"
        exit 1
    fi
}

# Function to get user input
get_user_input() {
    print_header "Contabo VPS Configuration"
    
    # Get domain name
    while [[ -z "$DOMAIN" ]]; do
        read -p "Enter your domain name (e.g., yourdomain.com): " DOMAIN
        if [[ ! "$DOMAIN" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
            print_warning "Please enter a valid domain name"
            DOMAIN=""
        fi
    done
    
    # Get email for SSL
    while [[ -z "$EMAIL" ]]; do
        read -p "Enter your email for SSL certificate: " EMAIL
        if [[ ! "$EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            print_warning "Please enter a valid email address"
            EMAIL=""
        fi
    done
    
    print_success "Configuration set:"
    echo "  Domain: $DOMAIN"
    echo "  Email: $EMAIL"
    echo "  Database: $DB_NAME"
    echo "  DB User: $DB_USER"
    echo "  DB Password: $DB_PASS"
}

# Function to detect Contabo VPS
detect_contabo() {
    print_status "Detecting Contabo VPS environment..."
    
    # Check for Contabo-specific indicators
    if grep -q "contabo" /proc/version 2>/dev/null || \
       grep -q "contabo" /etc/hostname 2>/dev/null || \
       [[ $(hostname) == *"contabo"* ]]; then
        print_success "Contabo VPS detected"
        return 0
    fi
    
    # Check IP ranges (Contabo uses specific ranges)
    PUBLIC_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip)
    if [[ "$PUBLIC_IP" =~ ^(213\.239\.|5\.189\.|207\.180\.|144\.76\.) ]]; then
        print_success "Contabo IP range detected: $PUBLIC_IP"
        return 0
    fi
    
    print_warning "Contabo VPS not definitively detected, but continuing..."
    return 0
}

# Function to optimize for Contabo VPS
optimize_for_contabo() {
    if [[ "$CONTABO_OPTIMIZATIONS" != "true" ]]; then
        return 0
    fi
    
    print_status "Applying Contabo VPS optimizations..."
    
    # Network optimizations for Contabo infrastructure
    cat >> /etc/sysctl.conf << EOF

# Contabo VPS Network Optimizations
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 65536 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq

# Memory optimizations for SSD storage
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
EOF
    
    sysctl -p
    
    # Optimize for Contabo's NVMe SSD storage
    echo 'deadline' > /sys/block/sda/queue/scheduler 2>/dev/null || true
    
    print_success "Contabo optimizations applied"
}

# Function to install base system
install_base_system() {
    print_status "Installing base system for Contabo VPS..."
    
    # Update system
    apt update
    apt upgrade -y
    
    # Install essential packages
    apt install -y \
        curl \
        wget \
        git \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        htop \
        iotop \
        nethogs \
        tree \
        vim \
        fail2ban \
        ufw
    
    print_success "Base system installed"
}

# Function to install LAMP stack
install_lamp_stack() {
    print_status "Installing LAMP stack optimized for Contabo..."
    
    # Install Apache
    apt install -y apache2
    
    # Install MySQL
    apt install -y mysql-server
    
    # Install PHP 8.3 and extensions
    apt install -y \
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
    
    # Install Composer
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
    
    # Install Node.js (for Drupal frontend tools)
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
    
    print_success "LAMP stack installed"
}

# Function to configure Apache for Contabo
configure_apache() {
    print_status "Configuring Apache for Contabo VPS..."
    
    # Enable required modules
    a2enmod rewrite ssl headers deflate expires php8.3
    
    # Create optimized virtual host
    cat > /etc/apache2/sites-available/${PROJECT_NAME}.conf << EOF
<VirtualHost *:80>
    ServerName ${DOMAIN}
    ServerAlias www.${DOMAIN}
    DocumentRoot ${PROJECT_DIR}/drupal-cms/web
    
    <Directory ${PROJECT_DIR}/drupal-cms/web>
        AllowOverride All
        Require all granted
        Options -Indexes +FollowSymLinks
        
        # Security headers
        Header always set X-Content-Type-Options nosniff
        Header always set X-Frame-Options DENY
        Header always set X-XSS-Protection "1; mode=block"
        Header always set Referrer-Policy "strict-origin-when-cross-origin"
        
        # Performance optimizations
        ExpiresActive On
        ExpiresByType text/css "access plus 1 month"
        ExpiresByType application/javascript "access plus 1 month"
        ExpiresByType image/png "access plus 1 month"
        ExpiresByType image/jpg "access plus 1 month"
        ExpiresByType image/jpeg "access plus 1 month"
        ExpiresByType image/gif "access plus 1 month"
        ExpiresByType image/svg+xml "access plus 1 month"
    </Directory>
    
    # Logging optimized for Contabo
    ErrorLog \${APACHE_LOG_DIR}/${PROJECT_NAME}_error.log
    CustomLog \${APACHE_LOG_DIR}/${PROJECT_NAME}_access.log combined
    LogLevel warn
</VirtualHost>
EOF
    
    # Enable the site
    a2ensite ${PROJECT_NAME}.conf
    a2dissite 000-default.conf
    
    # Optimize Apache for Contabo VPS resources
    cat > /etc/apache2/conf-available/contabo-optimization.conf << EOF
# Contabo VPS Apache Optimizations
ServerTokens Prod
ServerSignature Off

# Memory optimizations
StartServers 2
MinSpareServers 2
MaxSpareServers 5
MaxRequestWorkers 150
ThreadsPerChild 25

# Connection optimizations
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5

# Compression
LoadModule deflate_module modules/mod_deflate.so
<Location />
    SetOutputFilter DEFLATE
    SetEnvIfNoCase Request_URI \
        \.(?:gif|jpe?g|png)$ no-gzip dont-vary
    SetEnvIfNoCase Request_URI \
        \.(?:exe|t?gz|zip|bz2|sit|rar)$ no-gzip dont-vary
</Location>
EOF
    
    a2enconf contabo-optimization
    systemctl restart apache2
    systemctl enable apache2
    
    print_success "Apache configured for Contabo VPS"
}

# Function to configure MySQL
configure_mysql() {
    print_status "Configuring MySQL for production..."
    
    # Secure MySQL installation
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASS}';"
    mysql -u root -p${DB_PASS} -e "DELETE FROM mysql.user WHERE User='';"
    mysql -u root -p${DB_PASS} -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    mysql -u root -p${DB_PASS} -e "DROP DATABASE IF EXISTS test;"
    mysql -u root -p${DB_PASS} -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    
    # Create production database and user
    mysql -u root -p${DB_PASS} -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
    mysql -u root -p${DB_PASS} -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
    mysql -u root -p${DB_PASS} -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
    mysql -u root -p${DB_PASS} -e "FLUSH PRIVILEGES;"
    
    # Optimize MySQL for Contabo VPS
    cat >> /etc/mysql/mysql.conf.d/contabo-optimization.cnf << EOF
[mysqld]
# Contabo VPS MySQL Optimizations
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT
query_cache_type = 1
query_cache_size = 64M
max_connections = 100
thread_cache_size = 8
table_open_cache = 2000
EOF
    
    systemctl restart mysql
    systemctl enable mysql
    
    print_success "MySQL configured for production"
}

# Function to optimize PHP
optimize_php() {
    print_status "Optimizing PHP for Contabo VPS..."
    
    # Create production PHP configuration
    cat > /etc/php/8.3/apache2/conf.d/99-contabo-drupal.ini << EOF
; Contabo VPS PHP Optimizations for Drupal
memory_limit = 512M
max_execution_time = 300
max_input_vars = 3000
post_max_size = 64M
upload_max_filesize = 64M
max_file_uploads = 20

; OpCache optimizations for Contabo SSD
opcache.enable = 1
opcache.memory_consumption = 256
opcache.interned_strings_buffer = 16
opcache.max_accelerated_files = 10000
opcache.revalidate_freq = 2
opcache.fast_shutdown = 1
opcache.validate_timestamps = 0

; Security
expose_php = Off
allow_url_fopen = Off
allow_url_include = Off
session.cookie_httponly = 1
session.cookie_secure = 1

; Performance
realpath_cache_size = 4096K
realpath_cache_ttl = 600
EOF
    
    # Copy to CLI configuration
    cp /etc/php/8.3/apache2/conf.d/99-contabo-drupal.ini /etc/php/8.3/cli/conf.d/
    
    systemctl restart apache2
    
    print_success "PHP optimized for Contabo VPS"
}

# Function to setup SSL with Let's Encrypt
setup_ssl() {
    if [[ "$ENABLE_SSL" != "true" ]]; then
        return 0
    fi
    
    print_status "Setting up SSL certificate with Let's Encrypt..."
    
    # Install Certbot
    apt install -y certbot python3-certbot-apache
    
    # Get SSL certificate
    certbot --apache --non-interactive --agree-tos --email ${EMAIL} -d ${DOMAIN} -d www.${DOMAIN}
    
    # Set up auto-renewal
    systemctl enable certbot.timer
    systemctl start certbot.timer
    
    print_success "SSL certificate installed and auto-renewal configured"
}

# Function to configure security
configure_security() {
    print_status "Configuring security for Contabo VPS..."
    
    # Configure UFW firewall
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow http
    ufw allow https
    ufw --force enable
    
    # Configure fail2ban
    cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log

[apache-auth]
enabled = true
port = http,https
filter = apache-auth
logpath = /var/log/apache2/*error.log

[apache-badbots]
enabled = true
port = http,https
filter = apache-badbots
logpath = /var/log/apache2/*access.log
EOF
    
    systemctl restart fail2ban
    systemctl enable fail2ban
    
    print_success "Security configured"
}

# Function to deploy Drupal project
deploy_drupal() {
    print_status "Deploying UMD Drupal project..."
    
    # Create project directory
    mkdir -p ${PROJECT_DIR}
    cd ${PROJECT_DIR}
    
    # Clone project (assuming it's available in a repository)
    # For now, we'll create the structure
    mkdir -p drupal-cms
    cd drupal-cms
    
    # This would typically be:
    # git clone https://github.com/your-username/umd-drupal-project.git .
    # git checkout ubuntu-24-04-compatibility
    
    print_warning "Please clone your UMD Drupal project to ${PROJECT_DIR}/drupal-cms"
    print_status "Then run: composer install --no-dev --optimize-autoloader"
    
    # Set proper ownership and permissions
    chown -R www-data:www-data ${PROJECT_DIR}
    chmod -R 755 ${PROJECT_DIR}
    
    print_success "Drupal deployment structure ready"
}

# Function to setup monitoring
setup_monitoring() {
    if [[ "$ENABLE_MONITORING" != "true" ]]; then
        return 0
    fi
    
    print_status "Setting up monitoring for Contabo VPS..."
    
    # Install monitoring tools
    apt install -y htop iotop nethogs vnstat
    
    # Create monitoring script
    cat > /usr/local/bin/contabo-monitor.sh << 'EOF'
#!/bin/bash
# Contabo VPS Monitoring Script

echo "=== Contabo VPS Status Report ==="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime)"
echo ""

echo "=== System Resources ==="
echo "Memory Usage:"
free -h
echo ""
echo "Disk Usage:"
df -h
echo ""
echo "CPU Load:"
cat /proc/loadavg
echo ""

echo "=== Network ==="
echo "Network Connections:"
ss -tuln | head -10
echo ""

echo "=== Services ==="
echo "Apache Status: $(systemctl is-active apache2)"
echo "MySQL Status: $(systemctl is-active mysql)"
echo "PHP-FPM Status: $(systemctl is-active php8.3-fpm)"
echo ""

echo "=== Recent Errors ==="
echo "Apache Errors (last 5):"
tail -5 /var/log/apache2/error.log 2>/dev/null || echo "No errors"
echo ""
EOF
    
    chmod +x /usr/local/bin/contabo-monitor.sh
    
    # Set up daily monitoring report
    echo "0 6 * * * root /usr/local/bin/contabo-monitor.sh > /var/log/daily-status.log" >> /etc/crontab
    
    print_success "Monitoring configured"
}

# Function to setup backups
setup_backups() {
    if [[ "$ENABLE_BACKUPS" != "true" ]]; then
        return 0
    fi
    
    print_status "Setting up automated backups..."
    
    # Create backup script
    cat > /usr/local/bin/backup-drupal.sh << EOF
#!/bin/bash
# Automated Drupal Backup Script for Contabo VPS

BACKUP_DIR="/var/backups/drupal"
DATE=\$(date +%Y%m%d_%H%M%S)
PROJECT_DIR="${PROJECT_DIR}"
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASS="${DB_PASS}"

# Create backup directory
mkdir -p \$BACKUP_DIR

# Backup database
mysqldump -u \$DB_USER -p\$DB_PASS \$DB_NAME > \$BACKUP_DIR/database_\$DATE.sql

# Backup files
tar -czf \$BACKUP_DIR/files_\$DATE.tar.gz \$PROJECT_DIR

# Keep only last 7 days of backups
find \$BACKUP_DIR -name "*.sql" -mtime +7 -delete
find \$BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: \$DATE"
EOF
    
    chmod +x /usr/local/bin/backup-drupal.sh
    
    # Set up daily backups
    echo "0 2 * * * root /usr/local/bin/backup-drupal.sh >> /var/log/backup.log 2>&1" >> /etc/crontab
    
    print_success "Automated backups configured"
}

# Function to display final information
display_final_info() {
    print_header "Contabo VPS Deployment Complete!"
    
    echo -e "${GREEN}Your UMD Drupal project is ready on Contabo VPS!${NC}"
    echo ""
    echo "=== Access Information ==="
    echo "Domain: https://${DOMAIN}"
    echo "Server IP: $(curl -s ifconfig.me)"
    echo "SSH Access: ssh root@$(curl -s ifconfig.me)"
    echo ""
    echo "=== Database Credentials ==="
    echo "Database: ${DB_NAME}"
    echo "Username: ${DB_USER}"
    echo "Password: ${DB_PASS}"
    echo ""
    echo "=== Next Steps ==="
    echo "1. Clone your UMD Drupal project to ${PROJECT_DIR}/drupal-cms"
    echo "2. Run: cd ${PROJECT_DIR}/drupal-cms && composer install"
    echo "3. Configure Drupal settings.php with database credentials"
    echo "4. Import your database if migrating"
    echo "5. Test the website: https://${DOMAIN}"
    echo ""
    echo "=== Management Commands ==="
    echo "Monitor status: /usr/local/bin/contabo-monitor.sh"
    echo "Manual backup: /usr/local/bin/backup-drupal.sh"
    echo "View logs: tail -f /var/log/apache2/error.log"
    echo ""
    echo "=== Support ==="
    echo "Contabo Control Panel: https://my.contabo.com"
    echo "Server Documentation: /root/contabo-deployment-info.txt"
    
    # Save deployment info
    cat > /root/contabo-deployment-info.txt << EOF
Contabo VPS Deployment Information
Generated: $(date)

Domain: ${DOMAIN}
Database: ${DB_NAME}
DB User: ${DB_USER}
DB Password: ${DB_PASS}
Project Directory: ${PROJECT_DIR}

SSL Certificate: Let's Encrypt (auto-renewal enabled)
Firewall: UFW (SSH, HTTP, HTTPS allowed)
Security: fail2ban enabled
Monitoring: Daily reports in /var/log/daily-status.log
Backups: Daily automated backups in /var/backups/drupal

Contabo Optimizations: Applied
Performance Tuning: Enabled
Security Hardening: Configured
EOF
    
    print_success "Deployment information saved to /root/contabo-deployment-info.txt"
}

# Main execution
main() {
    print_header "Contabo VPS Deployment for UMD Drupal Project"
    
    check_root
    detect_contabo
    get_user_input
    install_base_system
    optimize_for_contabo
    install_lamp_stack
    configure_apache
    configure_mysql
    optimize_php
    setup_ssl
    configure_security
    deploy_drupal
    setup_monitoring
    setup_backups
    display_final_info
    
    print_success "Contabo VPS deployment completed successfully!"
}

# Run main function
main "$@"
