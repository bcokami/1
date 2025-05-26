# Contabo VPS Deployment Guide for UMD Drupal Project

## Overview
This guide provides step-by-step instructions for deploying the UMD (Unilevel MLM) Drupal project on a Contabo VPS using Ubuntu 24.04 LTS.

## Contabo VPS Specifications

### Recommended VPS Plans for UMD Drupal

#### **VPS S (Minimum)**
- **CPU**: 4 vCPU cores
- **RAM**: 8 GB
- **Storage**: 100 GB NVMe SSD
- **Bandwidth**: 32 TB
- **Cost**: ~€4.99/month
- **Suitable for**: Development and small production

#### **VPS M (Recommended)**
- **CPU**: 6 vCPU cores
- **RAM**: 16 GB
- **Storage**: 200 GB NVMe SSD
- **Bandwidth**: 32 TB
- **Cost**: ~€8.99/month
- **Suitable for**: Production with moderate traffic

#### **VPS L (High Performance)**
- **CPU**: 8 vCPU cores
- **RAM**: 32 GB
- **Storage**: 400 GB NVMe SSD
- **Bandwidth**: 32 TB
- **Cost**: ~€14.99/month
- **Suitable for**: High-traffic production

## Pre-Deployment Checklist

### 1. Contabo VPS Setup
- [ ] Order Contabo VPS with Ubuntu 24.04 LTS
- [ ] Receive VPS credentials (IP, root password)
- [ ] Configure DNS records (A record pointing to VPS IP)
- [ ] Set up SSH key authentication (recommended)

### 2. Domain Configuration
- [ ] Point domain to Contabo VPS IP address
- [ ] Configure DNS records:
  - `A record`: `yourdomain.com` → `VPS_IP`
  - `A record`: `www.yourdomain.com` → `VPS_IP`
  - `CNAME`: `umd.yourdomain.com` → `yourdomain.com` (optional subdomain)

### 3. Security Preparation
- [ ] Generate SSH key pair for secure access
- [ ] Plan firewall rules and security policies
- [ ] Prepare SSL certificate strategy (Let's Encrypt recommended)

## Step-by-Step Deployment

### Step 1: Initial VPS Access
```bash
# Connect to your Contabo VPS
ssh root@YOUR_VPS_IP

# Update system immediately
apt update && apt upgrade -y

# Install essential tools
apt install -y curl wget git unzip
```

### Step 2: Clone the Project
```bash
# Navigate to web directory
cd /var/www/html

# Clone the project with Ubuntu compatibility branch
git clone https://github.com/your-username/umd-drupal-project.git umd
cd umd

# Switch to Ubuntu compatibility branch
git checkout ubuntu-24-04-compatibility
```

### Step 3: Run Automated Setup
```bash
# Make setup script executable
chmod +x ubuntu_24_04_setup.sh

# Run the automated setup (this handles everything)
./ubuntu_24_04_setup.sh
```

### Step 4: Configure Domain and SSL
```bash
# Update Apache virtual host with your domain
sudo nano /etc/apache2/sites-available/umd-drupal.conf

# Replace 'umd-drupal.local' with your actual domain
# Example: ServerName yourdomain.com

# Install Certbot for SSL
sudo apt install -y certbot python3-certbot-apache

# Get SSL certificate
sudo certbot --apache -d yourdomain.com -d www.yourdomain.com
```

### Step 5: Deploy Drupal Application
```bash
# Navigate to Drupal directory
cd /var/www/html/umd/drupal-cms

# Install Composer dependencies
composer install --no-dev --optimize-autoloader

# Set proper permissions
sudo chown -R www-data:www-data /var/www/html/umd
sudo chmod -R 755 /var/www/html/umd
sudo chmod -R 777 /var/www/html/umd/drupal-cms/web/sites/default/files
```

## Contabo-Specific Optimizations

### 1. Network Configuration
```bash
# Optimize network settings for Contabo
echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem = 4096 65536 16777216' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem = 4096 65536 16777216' >> /etc/sysctl.conf
sysctl -p
```

### 2. Storage Optimization
```bash
# Enable SSD optimizations
echo 'vm.swappiness = 10' >> /etc/sysctl.conf
echo 'vm.vfs_cache_pressure = 50' >> /etc/sysctl.conf
sysctl -p

# Set up log rotation
sudo nano /etc/logrotate.d/drupal
```

### 3. Security Hardening
```bash
# Configure UFW firewall
ufw allow ssh
ufw allow http
ufw allow https
ufw --force enable

# Install fail2ban
apt install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban
```

## Database Configuration

### MySQL Setup for Production
```bash
# Secure MySQL installation
mysql_secure_installation

# Create production database
mysql -u root -p
```

```sql
CREATE DATABASE drupal_umd_prod;
CREATE USER 'drupal_prod'@'localhost' IDENTIFIED BY 'STRONG_PASSWORD_HERE';
GRANT ALL PRIVILEGES ON drupal_umd_prod.* TO 'drupal_prod'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Database Import (if migrating)
```bash
# Import existing database
mysql -u drupal_prod -p drupal_umd_prod < database_backup.sql

# Or use Drush for Drupal-specific migration
cd /var/www/html/umd/drupal-cms
vendor/bin/drush sql-cli < database_backup.sql
```

## Performance Optimization

### 1. PHP-FPM Configuration
```bash
# Configure PHP-FPM for better performance
sudo nano /etc/php/8.3/fpm/pool.d/www.conf

# Recommended settings for Contabo VPS:
# pm = dynamic
# pm.max_children = 50
# pm.start_servers = 5
# pm.min_spare_servers = 5
# pm.max_spare_servers = 35
```

### 2. Apache Optimization
```bash
# Enable Apache modules for performance
sudo a2enmod deflate
sudo a2enmod expires
sudo a2enmod headers
sudo a2enmod rewrite

# Configure Apache for Contabo VPS
sudo nano /etc/apache2/apache2.conf
```

### 3. OpCache Configuration
```bash
# Optimize OpCache for production
sudo nano /etc/php/8.3/apache2/conf.d/10-opcache.ini

# Add these settings:
# opcache.memory_consumption=256
# opcache.interned_strings_buffer=16
# opcache.max_accelerated_files=10000
# opcache.revalidate_freq=2
```

## Monitoring and Maintenance

### 1. Set Up Monitoring
```bash
# Install monitoring tools
apt install -y htop iotop nethogs

# Set up log monitoring
tail -f /var/log/apache2/error.log
tail -f /var/log/mysql/error.log
```

### 2. Automated Backups
```bash
# Create backup script
sudo nano /usr/local/bin/backup-drupal.sh
```

### 3. Update Strategy
```bash
# Set up automatic security updates
apt install -y unattended-upgrades
dpkg-reconfigure unattended-upgrades
```

## Testing Deployment

### 1. Functionality Tests
```bash
# Test web server
curl -I http://yourdomain.com

# Test SSL
curl -I https://yourdomain.com

# Test Drupal
cd /var/www/html/umd/drupal-cms
vendor/bin/drush status
```

### 2. Performance Tests
```bash
# Test PHP performance
php -i | grep opcache

# Test database connection
mysql -u drupal_prod -p -e "SELECT 1;"

# Test file permissions
ls -la /var/www/html/umd/drupal-cms/web/sites/default/files/
```

## Troubleshooting Common Issues

### 1. Permission Issues
```bash
# Fix ownership
sudo chown -R www-data:www-data /var/www/html/umd

# Fix permissions
find /var/www/html/umd -type d -exec chmod 755 {} \;
find /var/www/html/umd -type f -exec chmod 644 {} \;
```

### 2. Memory Issues
```bash
# Check memory usage
free -h
htop

# Increase PHP memory limit if needed
sudo nano /etc/php/8.3/apache2/php.ini
# memory_limit = 512M
```

### 3. Database Connection Issues
```bash
# Check MySQL status
systemctl status mysql

# Test connection
mysql -u drupal_prod -p drupal_umd_prod -e "SHOW TABLES;"
```

## Post-Deployment Checklist

- [ ] Website accessible via domain
- [ ] SSL certificate working
- [ ] Database connection established
- [ ] File uploads working
- [ ] Email functionality configured
- [ ] Backup system operational
- [ ] Monitoring tools active
- [ ] Security measures in place
- [ ] Performance optimized
- [ ] Documentation updated

## Contabo VPS Management

### Control Panel Access
- **URL**: https://my.contabo.com
- **Features**: Server restart, rescue mode, backup management
- **Monitoring**: Resource usage, bandwidth consumption

### Support Resources
- **Documentation**: https://docs.contabo.com
- **Support**: Available 24/7 via ticket system
- **Community**: Contabo community forums

## Cost Optimization

### Monthly Costs (Estimated)
- **VPS S**: €4.99/month
- **Domain**: €10-15/year
- **SSL**: Free (Let's Encrypt)
- **Backup Storage**: €2-5/month (optional)
- **Total**: ~€6-10/month for production-ready setup

### Cost-Saving Tips
1. Use Let's Encrypt for free SSL certificates
2. Implement efficient caching to reduce resource usage
3. Regular cleanup of logs and temporary files
4. Monitor resource usage to avoid overprovisioning

---

**Deployment Time**: 30-60 minutes for complete setup
**Maintenance**: 1-2 hours/month for updates and monitoring
**Scalability**: Easy vertical scaling with Contabo VPS plans
