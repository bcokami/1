# Installing the UnilevelMLM Module on Hostinger

**1. Introduction**

The UnilevelMLM module is a powerful tool for implementing a unilevel marketing structure within your Drupal website. This guide provides a step-by-step walkthrough on how to install the UnilevelMLM module on a Hostinger hosting environment. It is designed to be clear and easy to follow, even for users with limited technical expertise.

**2. Prerequisites**

Before you begin, ensure you have the following:

*   **A Hostinger hosting account:** You'll need an active Hostinger account with access to either the cPanel or hPanel control panel.
*   **A working Drupal 11.0 installation:** You should have a functional Drupal 11.0 website already set up on your Hostinger server. If you don't have Drupal installed yet, follow the steps in the "Installing Drupal 11.0 on Hostinger" section below.
*   **FTP client or Hostinger File Manager access:** You'll need a way to upload files to your Hostinger server. This can be done using an FTP client like FileZilla, or directly through Hostinger's built-in File Manager.

**Installing Drupal 11.0 on Hostinger (Basic Guide)**

This is a simplified guide to get Drupal 11.0 running on Hostinger. For more detailed instructions, refer to the official Drupal documentation.

1.  **Create a Database:**
    *   In your Hostinger control panel, find the "MySQL Databases" section.
    *   Create a new database, noting the database name, username, and password.
2.  **Download Drupal 11.0:**
    *   Download the latest version of Drupal 11.0 from the official Drupal website.
3.  **Upload Drupal Files:**
    *   Upload the downloaded Drupal files to your `public_html` directory (or a subdirectory) on your Hostinger server using FTP or the File Manager.
4.  **Run the Drupal Installer:**
    *   Visit your website in a web browser. You should be redirected to the Drupal installation script.
    *   Follow the on-screen instructions, providing the database details you created earlier.
    *   Choose a site name, administrator username, and password.
5.  **Complete Installation:**
    *   Once the installation is complete, you should be able to log in to your new Drupal 11.0 website.

**4. Uploading the Module Files to Hostinger**

Next, you'll need to upload the module files to your Hostinger server. This section provides detailed instructions on setting up FTP with Hostinger and uploading the files.

*   **Setting up FTP with Hostinger:**
    1.  **Access your Hostinger account:** Log in to your Hostinger account and navigate to your hosting control panel (cPanel or hPanel).
    2.  **Find FTP Accounts:** Look for the "FTP Accounts" section in your control panel. The location may vary depending on whether you are using cPanel or hPanel.
    3.  **Create an FTP Account:** If you don't already have an FTP account, create one. You'll need to provide a username, password, and a directory for the account to access. For full access to your Drupal installation, you can set the directory to the root directory (usually `/` or `/public_html`). However, for security reasons, it's recommended to create an account with access only to the necessary directories.
    4.  **Note FTP Credentials:** Make sure to note down the following FTP credentials:
        *   **Host:** This is usually your domain name or a specific FTP server address provided by Hostinger.
        *   **Username:** The username you created for the FTP account.
        *   **Password:** The password you created for the FTP account.
        *   **Port:** The default FTP port is 21.
*   **Connecting to your Hostinger server via FTP:**
    1.  **Open your FTP client:** Launch your preferred FTP client (e.g., FileZilla).
    2.  **Enter FTP Credentials:** Enter the FTP credentials you noted down in the corresponding fields in your FTP client.
    3.  **Connect to the server:** Click the "Connect" or "Quickconnect" button to connect to your Hostinger server.
*   **Navigating to the Drupal installation directory:** Once connected, navigate to the root directory of your Drupal installation. This is usually `public_html` or a subdirectory within `public_html`. If you're unsure, check your Drupal settings to determine the correct directory.
*   **Create the `modules` directory (if it doesn't exist):** If a `modules` directory doesn't already exist in your Drupal installation, you'll need to create one. This is where Drupal modules are stored.
*   **Create the `contrib` directory (if it doesn't exist):** Inside the `modules` directory, create a `contrib` directory. This is where contributed modules (modules not part of Drupal core) are typically placed.
*   **Upload the UnilevelMLM module files:** Upload the *extracted* UnilevelMLM module folder (the folder containing the module's files, such as `unilevelmlm.info.yml`, `unilevelmlm.module`, etc.) to the `modules/contrib` directory. Do not upload the zipped archive file.

**5. Enabling the UnilevelMLM Module in Drupal**

Now that the module files are on your server, you need to enable the module within Drupal.

*   **Log in to your Drupal administration interface:** Access your Drupal website as an administrator.
*   **Navigate to the Modules page:** In the Drupal administration menu, click on `Modules` (usually found at `/admin/modules`).
*   **Locate the UnilevelMLM module:** On the Modules page, find the UnilevelMLM module in the list. It might be located under the `Contrib` category or you can use the filter to search for it.
*   **Enable the module:** Check the box next to the UnilevelMLM module name to enable it.
*   **Install the module:** Scroll to the bottom of the page and click the `Install` button. Drupal will then install the module and its dependencies.

**6. Configuring the UnilevelMLM Module**

With the module enabled, you can now configure its settings.

*   **Navigate to the module configuration page:** After enabling the module, a configuration link should appear. This might be under the `Configuration` menu in the Drupal administration interface, or a custom menu link provided by the module. The exact location depends on how the module was designed.
*   **Configure the module settings:** On the configuration page, you'll find various settings related to the UnilevelMLM module. These settings will allow you to customize the module to fit your specific needs. This might include:
    *   Setting up the MLM structure (e.g., the number of levels in the unilevel structure).
    *   Defining commission rates for different levels.
    *   Configuring payout methods (e.g., PayPal, bank transfer).
    *   Setting up registration options.
*   **Save the configuration:** Once you've configured the settings, click the `Save configuration` button to save your changes.

**7. Troubleshooting**

If you encounter any issues during the installation process, here are some things to check:

*   **Drupal logs:** Check the Drupal logs for any error messages. These logs can provide valuable information about what went wrong. You can usually find the logs under `Reports` -> `Recent log messages` in the Drupal administration interface.
*   **Module documentation:** Consult the UnilevelMLM module documentation for troubleshooting tips and solutions to common problems.
*   **Module developers:** If you're still stuck, contact the module developers for support. They may be able to provide specific guidance or bug fixes.

**8. Conclusion**

Congratulations! You have successfully installed the UnilevelMLM module on your Hostinger server. Now you can explore the module's features and start building your unilevel marketing structure within your Drupal website.