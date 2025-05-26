# Drupal Deployment Plan

This document outlines the steps for deploying a Drupal website to a Contabo VPS (Ubuntu) with a full Git-based development workflow.

**I. Information Gathering and Clarification**

1.  **Review User Requirements:** Carefully re-read the user's instructions to ensure a complete understanding of all requirements, including optional enhancements.
2.  **Clarify Ambiguities:** Identify any ambiguous points in the instructions and formulate specific questions to the user. For example:
    *   Which Git repository (GitHub/GitLab) will be used?
    *   What is the domain name?
    *   What database server (MariaDB/PostgreSQL) should be used?
    *   Should Apache or Nginx be used?
    *   Should I use .env or settings.local.php for environment configuration?
    *   Should I use Docker Compose?
    *   Which security modules should be installed for Drupal?
    *   Which email service (Postfix/Mailgun/SendGrid) should be used?
    *   What backup and restore strategy should be used?
    *   What monitoring stack should be used?
3.  **Define Scope:** Clearly define the scope of the guide, including which optional enhancements will be included.

**II. Plan Creation**

1.  **Outline the Guide:** Create a high-level outline of the guide, with sections corresponding to the user's requirements.
2.  **Break Down Each Section:** Decompose each section into smaller, more manageable steps.
3.  **Identify Commands and Scripts:** For each step, identify the necessary bash commands or scripts.
4.  **Define Configuration Files:** Identify the configuration files that need to be created or modified.
5.  **Determine Folder Structure:** Define the folder structure for the project, including the location of configuration files, scripts, and Drupal files.
6.  **Create Mermaid Diagrams:** Use Mermaid diagrams to visualize the folder structure, deployment workflow, and other key aspects of the plan.

**III. Guide Structure**

Here's a detailed outline of the guide, incorporating the user's requirements and best practices:

```mermaid
graph LR
    A[Initial Server Setup] --> B(Install Required Packages);
    B --> C(Create Secure Sudo User);
    C --> D(Enable UFW Firewall);
    D --> E(Enable Fail2Ban);
    E --> F(Configure SSH Key-Based Access);

    G[Git-Based Drupal Deployment] --> H(Clone Drupal Site from Git);
    H --> I(Set Up Git Hooks/CI-CD);
    I --> J(Folder Structure Setup);

    K[Environment Setup] --> L(Set Up Virtual Hosts/Subdomains);
    L --> M(Configure Separate Databases);
    M --> N(Implement Environment-Specific Configuration);

    O[SSL Configuration] --> P(Install Certbot);
    P --> Q(Generate SSL Certificates);
    Q --> R(Configure HTTP to HTTPS Redirection);

    S[Database and File Sync] --> T(Create Drush/Bash Scripts for Syncing);

    U[Email Integration] --> V(Set Up Outbound Email System);
    V --> W(Configure SPF/DKIM/DMARC);
    W --> X(Verify PHP mail() or SMTP);

    Y[Performance & Security] --> Z(Enable Caching);
    Z --> AA(Tune PHP-FPM & OPCache);
    AA --> BB(Set Proper File Permissions);
    BB --> CC(Implement Fail2Ban & Firewall Rules);
    CC --> DD(Install Drupal Security Modules);

    EE[Backup & Restore] --> FF(Implement Backup Strategy);
    FF --> GG(Implement Restore Strategy);

    HH[Staging Approval Workflow] --> II(Describe Staging Approval Workflow);

    JJ[Monitoring] --> KK(SSL Renewal Monitoring);
    KK --> LL(Error Log Monitoring);
    LL --> MM(Deployment Log Monitoring);

    NN[User Guide] --> OO(Create User Guide);
```

**A. Initial Server Setup**

1.  **Install Required Packages:**
    *   Update package lists: `sudo apt update`
    *   Install Apache/Nginx, PHP 8.1+, MariaDB/PostgreSQL, Composer, Git, Certbot: `sudo apt install ...` (The specific command will depend on the choices made for web server and database server)
2.  **Create Secure Sudo User:**
    *   Add a new user: `sudo adduser deploy`
    *   Add the user to the sudo group: `sudo usermod -aG sudo deploy`
    *   Disable password authentication for root: `sudo passwd -l root`
3.  **Enable UFW Firewall:**
    *   Enable UFW: `sudo ufw enable`
    *   Allow SSH: `sudo ufw allow OpenSSH`
    *   Allow HTTP: `sudo ufw allow 'Apache Full'` or `sudo ufw allow 'Nginx Full'`
    *   Enable the firewall: `sudo ufw enable`
4.  **Enable Fail2Ban:**
    *   Install Fail2Ban: `sudo apt install fail2ban`
    *   Configure Fail2Ban: `/etc/fail2ban/jail.local` (customize settings)
    *   Start Fail2Ban: `sudo systemctl enable fail2ban`
5.  **Configure SSH Key-Based Access:**
    *   Generate SSH key pair on local machine: `ssh-keygen -t rsa -b 4096`
    *   Copy public key to server: `ssh-copy-id deploy@your_server_ip`
    *   Disable password authentication in `/etc/ssh/sshd_config`:
        *   `PasswordAuthentication no`
        *   `PermitRootLogin no`
    *   Restart SSH service: `sudo systemctl restart sshd`

**B. Git-Based Drupal Deployment**

1.  **Clone Drupal Site from Git:**
    *   Create the directory structure: `sudo mkdir -p /var/www/dev /var/www/staging /var/www/test /var/www/live`
    *   Clone the repository: `sudo git clone your_repo_url /var/www/dev`
2.  **Set Up Git Hooks/CI-CD:**
    *   Create a post-receive hook in `/var/www/dev/.git/hooks/post-receive`:
        ```bash
        #!/bin/bash
        while read oldrev newrev ref
        do
            if [[ $ref =~ .*/main$ ]]; then
                echo "Main branch was updated. Deploying..."
                git checkout -f main
                drush cr
            fi
        done
        ```
    *   Make the hook executable: `sudo chmod +x /var/www/dev/.git/hooks/post-receive`
3.  **Folder Structure Setup:**
    *   `/var/www/dev`: Development environment
    *   `/var/www/staging`: Staging environment
    *   `/var/www/test`: Test environment
    *   `/var/www/live`: Live environment
    *   `/var/www/shared`: Shared configuration files (settings.php, .env)

**C. Environment Setup**

1.  **Set Up Virtual Hosts/Subdomains:**
    *   Create Apache/Nginx virtual host files for each environment (dev.domain.com, staging.domain.com, test.domain.com, live.domain.com).
    *   Configure document root to point to the corresponding directory in `/var/www`.
2.  **Configure Separate Databases:**
    *   Create separate databases for each environment (dev_db, staging_db, test_db, live_db).
    *   Grant appropriate permissions to the database users.
3.  **Implement Environment-Specific Configuration:**
    *   Create `.env` files in each environment's directory (or use `settings.local.php` overrides).
    *   Define environment-specific variables (database credentials, etc.).

**D. SSL Configuration**

1.  **Install Certbot:**
    *   `sudo apt install certbot python3-certbot-apache` or `sudo apt install certbot python3-certbot-nginx`
2.  **Generate SSL Certificates:**
    *   `sudo certbot --apache -d dev.domain.com -d staging.domain.com -d test.domain.com -d live.domain.com` or `sudo certbot --nginx -d dev.domain.com -d staging.domain.com -d test.domain.com -d live.domain.com`
3.  **Configure HTTP to HTTPS Redirection:**
    *   Configure virtual hosts to redirect HTTP traffic to HTTPS.

**E. Database and File Sync**

1.  **Create Drush/Bash Scripts for Syncing:**
    *   Create a script to sync the database from live to test:
        ```bash
        drush sql-dump --result-file=/tmp/live_db.sql -r /var/www/live
        drush sql-cli < /tmp/live_db.sql -r /var/www/test
        ```
    *   Create a script to sync files from live to test:
        ```bash
        rsync -avz /var/www/live/sites/default/files/ /var/www/test/sites/default/files/
        ```

**F. Email Integration**

1.  **Set Up Outbound Email System:**
    *   Install Postfix: `sudo apt install postfix`
    *   Configure Postfix: `/etc/postfix/main.cf`
    *   Alternatively, use a transactional email service like Mailgun or SendGrid.
2.  **Configure SPF/DKIM/DMARC:**
    *   Add SPF, DKIM, and DMARC records to your domain's DNS settings.
3.  **Verify PHP mail() or SMTP:**
    *   Configure Drupal to use SMTP if necessary.
    *   Test email functionality.

**G. Performance & Security**

1.  **Enable Caching:**
    *   Install Redis or Memcached: `sudo apt install redis` or `sudo apt install memcached`
    *   Configure Drupal to use Redis or Memcached.
2.  **Tune PHP-FPM & OPCache:**
    *   Configure PHP-FPM: `/etc/php/8.1/fpm/pool.d/www.conf`
    *   Enable and configure OPCache: `/etc/php/8.1/mods-available/opcache.ini`
3.  **Set Proper File Permissions:**
    *   `sudo chown -R www-data:www-data /var/www`
    *   `sudo chmod 755 /var/www`
    *   `sudo chmod 644 /var/www/*`
4.  **Implement Fail2Ban & Firewall Rules:**
    *   (Already covered in Initial Server Setup)
5.  **Install Drupal Security Modules:**
    *   Install security modules like Security Review, Paranoia, Two-Factor Authentication, and Field Permissions.

6.  **Install Drupal Dashboard Modules:**
    *   Install Admin Toolbar module for improved administration interface.
    *   Install Monitoring module for server and application monitoring.

    *   Install Admin Toolbar module for improved administration interface.
    *   Install Monitoring module for server and application monitoring.

**H. Backup & Restore**

1.  **Implement Backup Strategy:**
    *   Create a script to back up the database and files:
        ```bash
        drush sql-dump --result-file=/tmp/backup_db.sql -r /var/www/live
        tar -czvf /tmp/backup_files.tar.gz /var/www/live/sites/default/files/
        ```
    *   Schedule the script to run regularly using cron. Consider using a cloud storage service (e.g., AWS S3, Google Cloud Storage) for offsite backups.

2.  **Implement Restore Strategy:**
    *   Create a script to restore the database and files:
        ```bash
        drush sql-cli < /tmp/backup_db.sql -r /var/www/live
        tar -xzvf /tmp/backup_files.tar.gz -C /var/www/live/sites/default/
        ```

**I. Staging Approval Workflow**

1.  **Describe Staging Approval Workflow:**
    *   Developers push changes to the staging branch.
    *   Changes are deployed to the staging environment.
    *   Stakeholders review the changes on the staging environment.
    *   If the changes are approved, the staging branch is merged into the main branch.
    *   Changes are deployed to the live environment.

**J. Monitoring**

1.  **SSL Renewal Monitoring:**
    *   Use a monitoring service like Uptime Kuma to check SSL certificate expiration.
2.  **System Monitoring:**
    *   Implement a monitoring stack like Uptime Kuma, Netdata, or Grafana+Prometheus to monitor server resources, application performance, and error logs.
3.  **Error Log Monitoring:**
    *   Use a log management tool to monitor error logs.
    *   Use a log management tool to monitor deployment logs.

**K. User Guide**

1.  **Create User Guide:**
    *   Create a user guide that explains how to use the system, including how to deploy code, sync databases, and monitor the system.

**IV. Folder Structure Diagram**

```mermaid
graph LR
    A[/var/www] --> B(dev);
    A --> C(staging);
    A --> D(test);
    A --> E(live);
    A --> F(shared);
    B --> B1(Drupal Files);
    C --> C1(Drupal Files);
    D --> D1(Drupal Files);
    E --> E1(Drupal Files);
    F --> F1(settings.php);
    F --> F2(.env);