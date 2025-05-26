#!/bin/bash
# This script automates the SSL configuration using Let's Encrypt with Certbot.

# Set variables
DOMAIN="extremelifeherbal.com" # Replace with your actual domain

# 1. Install Certbot
echo "Installing Certbot..."
sudo apt install -y certbot python3-certbot-apache

# 2. Generate SSL Certificates
echo "Generating SSL Certificates..."
sudo certbot --apache -d dev.$DOMAIN -d staging.$DOMAIN -d test.$DOMAIN -d $DOMAIN

# 3. Configure HTTP to HTTPS Redirection
echo "Configuring HTTP to HTTPS Redirection..."
# (This step requires manual configuration of Apache virtual host files)
echo "Please configure Apache virtual host files to redirect HTTP traffic to HTTPS."

echo "SSL configuration complete!"