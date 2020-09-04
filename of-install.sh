#! /usr/bin/env bash
# Office Forge installation script
#
# (c) Pillar Falls Software, LLC
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.

if [[ $EUID -ne 0 ]]; then
    echo "Please run this as root"
    exit 1
fi

echo "What is the ServerName for this installation?"
read server_name

echo "Updating system packages..."
apt update && apt upgrade -y

echo "Installing apache2..."
apt install -y apache2 zip certbot python3-certbot-apache

echo "Enabling mod_ssl and mod_rewrite..."
a2enmod ssl && a2enmod rewrite

echo "Disabling default sites"
a2dissite 000-default
a2dissite default-ssl

echo "Installing mysql-server..."
apt install -y mysql-server

echo "Running mysql_secure_installation with defaults..."
mysql_secure_installation --use-default

echo "Creating officeforge database..."
mysql -e "CREATE DATABASE officeforge CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

echo "What is the database user's password?"
echo "Make sure to include upper and lowercase characters, numbers, and special characters"
read db_password

echo "Creating officeforge database user..."
mysql -e "CREATE USER 'officeforge'@'localhost' IDENTIFIED BY '$db_password'"
mysql -e "GRANT ALL PRIVILEGES ON officeforge.* TO 'officeforge'@'localhost' WITH GRANT OPTION"

echo "Installing PHP..."
apt install -y php libapache2-mod-php php-mysql php-bcmath php-json php-mbstring php-tokenizer php-xml php-gd



echo "Installing composer..."


EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
then
    >&2 echo 'ERROR: Invalid installer checksum'
    rm composer-setup.php
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "Error installing composer"
    echo "Unable to complete setup"
    echo "Exiting"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
fi

php composer-setup.php --quiet
RESULT=$?
rm composer-setup.php

mv composer.phar /usr/local/bin/composer






echo "Creating site directory..."
mkdir /var/www/officeforge/

echo "Cloning Office Forge repository..."
git clone https://github.com/noahheck/office-forge.git /var/www/officeforge/


echo "Creating Office Forge vhost..."
siteconf="/etc/apache2/sites-available/officeforge.conf"
touch $siteconf

echo "<VirtualHost *:80>" >> $siteconf
echo "    ServerName $server_name" >> $siteconf
echo "    ServerAdmin  webmaster@localhost" >> $siteconf
echo "    DocumentRoot /var/www/officeforge/public" >> $siteconf
echo "    ErrorLog ${APACHE_LOG_DIR}/error.log" >> $siteconf
echo "    CustomLog ${APACHE_LOG_DIR}/access.log combined" >> $siteconf
echo "    <Directory /var/www/officeforge/public>" >> $siteconf
echo "        Options FollowSymLinks" >> $siteconf
echo "        AllowOverride All" >> $siteconf
echo "        Require all granted" >> $siteconf
echo "    </Directory>" >> $siteconf
echo "</VirtualHost>" >> $siteconf

echo "Enabling Office Forge vhost..."
a2ensite officeforge

echo "Restarting apache2 service..."
apache2ctl restart

echo "Running certbot..."
echo "Please make sure to redirect all traffic to the ssl secured port..."
certbot --apache

echo "Changing directory to Office Forge root..."
cd /var/www/officeforge/

echo "Installing composer dependencies..."
composer install

echo "Copying .env.example to .env..."
cp .env.example .env

echo "Running artisan key:generate..."
./artisan key:generate

echo "Changing ownership of project files and direcories..."
chown -R www-data:www-data /var/www/officeforge



echo "Adding Office Forge cron job..."
cronfile="/etc/cron.d/officeforge"
touch $cronfile

echo "# /etc/cron.d/officeforge: crontab entries for the officeforge installation" > $cronfile
echo "" >> $cronfile
echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin" >> $cronfile
echo "" >> $cronfile
echo "* * * * * root cd /var/www/officeforge/ && php artisan schedule:run >> /dev/null 2>&1" >> $cronfile


echo "Installation complete!"
echo ""
echo "The server's URL is:"
echo "    https://$server_name"
echo ""
echo "Please set the APP_URL value to this in the .env file"
echo ""
echo "The database user's password is:"
echo "    $db_password"
echo ""

echo "Please set the DB_PASSWORD value to this in the .env file"
echo "and make sure you run"
echo ""
echo "    ./artisan migrate"
echo ""

echo "After performing the database migrations, generate the server setup key"
echo "and provide to the client to finish setting up the installation:"
echo ""
echo "    ./artisan of:generate-setup-key"
echo ""
