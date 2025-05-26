# User Guide

This document provides a guide on how to use the Drupal deployment system.

## Deploying Code

1.  Commit your changes to the Git repository.
2.  Push your changes to the main branch.
3.  The changes will be automatically deployed to the live environment.

## Syncing the Database

1.  Ensure you have Drush installed and configured on the server.
2.  Ensure you have SSH access to the server.
3.  Run the `database_file_sync.sh` script to sync the database from live to test:
    `bash database_file_sync.sh`

## Monitoring the System

1.  Use a monitoring service like Uptime Kuma to check SSL certificate expiration.
2.  Use a log management tool to monitor error logs and deployment logs. Consider using Netdata or Grafana+Prometheus for more comprehensive monitoring.

## Security

1.  Ensure you have installed the following security modules: Security Review, Paranoia, and Two-Factor Authentication.