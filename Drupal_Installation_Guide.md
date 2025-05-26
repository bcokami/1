# Drupal Installation Guide

This document provides a step-by-step guide on how to install Drupal.

## Prerequisites

Before you begin, ensure you have the following:

*   A web server (e.g., Apache, Nginx)
*   PHP 7.3 or higher
*   A database server (e.g., MySQL, PostgreSQL)

## Installation Steps

1.  **Download Drupal:**
    *   Visit the official Drupal website ([https://www.drupal.org/](https://www.drupal.org/)).
    *   Click on the "Download" button.
    *   Download the latest stable version of Drupal in either `.zip` or `.tar.gz` format.

2.  **Extract Drupal Files:**
    *   Locate the downloaded Drupal archive file on your computer.
    *   Extract the contents of the archive file to a directory on your computer.
    *   The extracted files should include directories like `core`, `modules`, `themes`, and files like `index.php`, `autoload.php`, etc.

3.  **Move Extracted Files to Web Server Directory:**
    *   Identify your web server's document root directory (e.g., `public_html`, `htdocs`, `www`). This is the directory where your website's files are stored.
    *   Move all the extracted Drupal files and directories from the extraction directory to your web server's document root directory.

4.  **Create a Database:**
    *   Log in to your database server (e.g., MySQL, PostgreSQL) using a database management tool (e.g., phpMyAdmin, pgAdmin).
    *   Create a new database for your Drupal website.
    *   Note down the database name, username, and password.

5.  **Run the Drupal Installer:**
    *   Open your web browser and navigate to your website's URL (e.g., `http://localhost/drupal`).
    *   You should be redirected to the Drupal installation script.
    *   Follow the on-screen instructions to complete the Drupal installation process.

## Configuration

During the installation process, you will be prompted to provide the following information:

*   Database name
*   Database username
*   Database password
*   Site name
*   Administrator username
*   Administrator password

Please make sure to note down this information, as you will need it to access your Drupal website after the installation is complete.