# office-forge-install

This script will install and configure a suitable production environment for running the Office Forge application (or other LAMP/Laravel application).

It is designed and tested to run effectively on a standard Digital Ocean Ubuntu 20.04 installation. For other environments/operating systems/hosts/etc, your mileage may vary.

### Executing the script

You'll be prompted for a few pieces of information during the installation. Please pay close attention and provide the requested information when asked:

- **ServerName** - the Apache ServerName directive - usually "test.example.com" for the server at https://test.example.com
- **MySQL Root Password** - This is asked for during the execution of the *mysql_secure_installation* script; it uses default values for everything else, but you'll need to provide and confirm this while it's running. *Note: Current versions of MySQL default to requiring socket authentication for the *root* user, so setting this value now won't allow password based **root** login.*
- **Database User's Password** - We create a database user named "officeforge" and this is the password that will be set for this user. *mysql_secure_installation* sets password requirements that include upper- and lower-case letters, numbers, and special characters. This user is created with "localhost" host specification, so you won't be able to connect to the database remotely. To make a secure password, this value should be a long (24 characters or more) randomized string and must include the characters mentioned above.
- **Let's Encrypt prompts** - You'll be prompted with a number of queries from the **certbot** process. These should be generally self-explanatory, but depending on your server environment, these prompts may differ. Provide a valid email address to you can be notified of any update issues for your Free Let's Encrypt SSL certificate.

> The Let's Encrypt/certbot portion of this process may fail depending on how quickly the DNS entry for your Office Forge server propogates. If you see a certbot failure during the installation, you may need to wait a few minutes and then execute the certbot program manually, e.g., `certbot --apache`

After the installation process is completed, you'll be given a few additional activities to complete.

- Set the **APP_URL** and **DB_PASSWORD** values in the */var/www/officeforge/.env* file
- Execute the database migrations: `php /var/www/officeforge/artisan migrate`

Congratulations! Your Office Forge server should now be set up and ready to accept connections from the Internet. Try loading your Office Forge server's URL in your web browser.

### Notes

Aside from taking the opinionated actions of

- disabling the default 000-default and default-ssl Apache vhosts
- creating an officeforge database and mysql user

this script should be suitable to execute on an existing environment, though this hasn't been tested.

More details will follow as the Office Forge installation process is refined.
