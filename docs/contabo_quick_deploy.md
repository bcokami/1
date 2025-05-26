# Quick Contabo VPS Deployment for UMD Drupal

## 🚀 One-Command Deployment

### Prerequisites
1. **Contabo VPS** with Ubuntu 24.04 LTS
2. **Domain name** pointed to your VPS IP
3. **SSH access** to your VPS as root

### Step 1: Connect to Your Contabo VPS
```bash
ssh root@YOUR_VPS_IP
```

### Step 2: Download and Run Deployment Script
```bash
# Download the deployment script
wget https://raw.githubusercontent.com/your-repo/ubuntu-24-04-compatibility/contabo_vps_deploy.sh

# Make it executable
chmod +x contabo_vps_deploy.sh

# Run the deployment (will prompt for domain and email)
./contabo_vps_deploy.sh
```

### Step 3: Deploy Your UMD Project
```bash
# Navigate to project directory
cd /var/www/html/umd/drupal-cms

# Clone your project (replace with your actual repository)
git clone https://github.com/your-username/umd-drupal-project.git .
git checkout ubuntu-24-04-compatibility

# Install dependencies
composer install --no-dev --optimize-autoloader

# Set permissions
sudo chown -R www-data:www-data .
sudo chmod -R 755 .
sudo chmod -R 777 web/sites/default/files
```

### Step 4: Configure Drupal Database
```bash
# Edit Drupal settings
nano web/sites/default/settings.php

# Add database configuration:
$databases['default']['default'] = [
  'database' => 'drupal_umd_prod',
  'username' => 'drupal_prod',
  'password' => 'YOUR_GENERATED_PASSWORD',
  'host' => 'localhost',
  'port' => '3306',
  'driver' => 'mysql',
  'prefix' => '',
];
```

## 🎯 What Gets Installed Automatically

### ✅ **LAMP Stack**
- **Apache 2.4** with mod_rewrite, SSL, compression
- **MySQL 8.0** with production optimizations
- **PHP 8.3** with all required Drupal extensions
- **Composer** for dependency management

### ✅ **Security Features**
- **UFW Firewall** (SSH, HTTP, HTTPS only)
- **fail2ban** for intrusion prevention
- **Let's Encrypt SSL** with auto-renewal
- **Security headers** and hardening

### ✅ **Performance Optimizations**
- **OpCache** configured for production
- **Apache compression** and caching
- **MySQL tuning** for Contabo VPS specs
- **Network optimizations** for Contabo infrastructure

### ✅ **Monitoring & Backups**
- **Daily monitoring** reports
- **Automated backups** (database + files)
- **Log rotation** and cleanup
- **Resource monitoring** tools

## 📊 Contabo VPS Recommendations

### **VPS S** (Development/Testing)
- **Specs**: 4 vCPU, 8GB RAM, 100GB SSD
- **Cost**: ~€4.99/month
- **Suitable for**: Development, small sites

### **VPS M** (Production - Recommended)
- **Specs**: 6 vCPU, 16GB RAM, 200GB SSD
- **Cost**: ~€8.99/month
- **Suitable for**: Production with moderate traffic

### **VPS L** (High Performance)
- **Specs**: 8 vCPU, 32GB RAM, 400GB SSD
- **Cost**: ~€14.99/month
- **Suitable for**: High-traffic production

## 🔧 Post-Deployment Tasks

### 1. Test Your Website
```bash
# Check website status
curl -I https://yourdomain.com

# Test Drupal
cd /var/www/html/umd/drupal-cms
vendor/bin/drush status
```

### 2. Import Existing Data (if migrating)
```bash
# Import database
mysql -u drupal_prod -p drupal_umd_prod < your_backup.sql

# Or use Drush
vendor/bin/drush sql-cli < your_backup.sql
```

### 3. Configure Email (Optional)
```bash
# Install Postfix for email
apt install -y postfix

# Configure for your domain
dpkg-reconfigure postfix
```

## 🛠️ Management Commands

### Monitor Server Status
```bash
/usr/local/bin/contabo-monitor.sh
```

### Manual Backup
```bash
/usr/local/bin/backup-drupal.sh
```

### View Logs
```bash
# Apache errors
tail -f /var/log/apache2/error.log

# MySQL errors
tail -f /var/log/mysql/error.log

# System logs
journalctl -f
```

### Restart Services
```bash
systemctl restart apache2
systemctl restart mysql
systemctl restart php8.3-fpm
```

## 🚨 Troubleshooting

### Common Issues

#### 1. **Permission Errors**
```bash
sudo chown -R www-data:www-data /var/www/html/umd
sudo chmod -R 755 /var/www/html/umd
```

#### 2. **Database Connection Issues**
```bash
# Test MySQL connection
mysql -u drupal_prod -p drupal_umd_prod -e "SHOW TABLES;"

# Check MySQL status
systemctl status mysql
```

#### 3. **SSL Certificate Issues**
```bash
# Renew SSL certificate
certbot renew --dry-run

# Check certificate status
certbot certificates
```

#### 4. **Performance Issues**
```bash
# Check resource usage
htop
iotop
nethogs

# Check Apache status
apache2ctl status
```

## 📈 Performance Optimization

### After Deployment
1. **Enable Drupal Caching**
   - Go to Admin → Performance
   - Enable page caching and CSS/JS aggregation

2. **Install Redis** (Optional)
```bash
apt install -y redis-server php8.3-redis
systemctl enable redis-server
```

3. **Configure CDN** (Optional)
   - Use Cloudflare or similar CDN
   - Configure in Drupal settings

## 💰 Cost Breakdown

### Monthly Costs
- **VPS M**: €8.99/month
- **Domain**: €1-2/month (annual)
- **SSL**: Free (Let's Encrypt)
- **Backups**: Included
- **Total**: ~€10-11/month

### Annual Savings
- **12-month commitment**: 10% discount
- **24-month commitment**: 15% discount

## 📞 Support Resources

### Contabo Support
- **Control Panel**: https://my.contabo.com
- **Documentation**: https://docs.contabo.com
- **Support Tickets**: 24/7 availability
- **Community**: Contabo forums

### Technical Support
- **Server Monitoring**: Built-in monitoring tools
- **Backup Management**: Automated daily backups
- **Security Updates**: Automatic security patches
- **Performance Monitoring**: Resource usage tracking

## 🎉 Success Checklist

After deployment, verify:
- [ ] Website loads at https://yourdomain.com
- [ ] SSL certificate is valid and auto-renewing
- [ ] Database connection is working
- [ ] File uploads are functional
- [ ] Drupal admin panel is accessible
- [ ] Email functionality is working (if configured)
- [ ] Backups are running daily
- [ ] Monitoring is active
- [ ] Security measures are in place

---

**Deployment Time**: 15-30 minutes
**Total Setup Cost**: €10-15/month
**Performance**: Production-ready with 99.9% uptime
**Support**: 24/7 Contabo support + automated monitoring
