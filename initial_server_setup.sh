#!/bin/bash
# This script automates the initial server setup on a Contabo VPS (Ubuntu).

# Set variables
USERNAME="deploy"
DOMAIN="your_domain.com" # Replace with your actual domain
EMAIL="your_email@example.com" # Replace with your actual email

# 1. Install Required Packages
echo "Installing required packages..."
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y apache2 mariadb-server php8.1 php8.1-cli php8.1-mysql php8.1-gd php8.1-curl composer git certbot python3-certbot-apache unzip

# 6. Configure MariaDB
echo "Configuring MariaDB..."
sudo mysql -e "CREATE DATABASE drupal;"
sudo mysql -e "CREATE USER 'drupaluser'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON drupal.* TO 'drupaluser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# 2. Create Secure Sudo User
echo "Configuring MariaDB..."
sudo mysql -e "CREATE DATABASE drupal;"
sudo mysql -e "CREATE USER 'drupaluser'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON drupal.* TO 'drupaluser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# 2. Create Secure Sudo User
echo "Creating secure sudo user..."
sudo adduser $USERNAME
sudo usermod -aG sudo $USERNAME
sudo passwd -l root

# 3. Enable UFW Firewall
echo "Enabling UFW firewall..."
sudo ufw enable
sudo ufw allow OpenSSH
sudo ufw allow 'Apache Full'
sudo ufw enable

# 4. Enable Fail2Ban
echo "Enabling Fail2Ban..."
sudo apt install -y fail2ban
# Configure Fail2Ban (customize settings in /etc/fail2ban/jail.local)
sudo systemctl enable fail2ban

# 5. Configure SSH Key-Based Access
echo "Configuring SSH key-based access..."
# (This step requires manual intervention - copy your public key to the server)
echo "Please copy your public key to the server using ssh-copy-id $USERNAME@your_server_ip"
# After copying the key, run the following commands:
echo "After copying the key, run the following commands:"
echo "sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config"
echo "sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config"
echo "sudo systemctl restart sshd"

echo "Initial server setup complete!"