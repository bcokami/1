#!/bin/bash
# This script automates the Git-based Drupal deployment.

# Set variables
REPO_URL="https://github.com/your_username/your_drupal_repo.git" # Replace with your actual repository URL
DEPLOY_USER="deploy"

# 1. Create the directory structure
echo "Creating the directory structure..."
sudo mkdir -p /var/www/dev /var/www/staging /var/www/test /var/www/live /var/www/shared

# 2. Clone the Drupal site from Git
echo "Cloning the Drupal site from Git..."
sudo git clone $REPO_URL /var/www/dev

# 3. Set up Git hooks/CI-CD
echo "Setting up Git hooks/CI-CD..."
# Create a post-receive hook
cat <<EOF | sudo tee /var/www/dev/.git/hooks/post-receive
#!/bin/bash
while read oldrev newrev ref
do
    if [[ \$ref =~ .*/main\$ ]]; then
        echo "Main branch was updated. Deploying..."
        git checkout -f main
        drush cr
    fi
done
EOF
sudo chmod +x /var/www/dev/.git/hooks/post-receive

echo "Git-based Drupal deployment setup complete!"