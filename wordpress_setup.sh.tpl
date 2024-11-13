#!/bin/bash

# Update system and install required packages:
sudo yum update -y
sudo amazon-linux-extras enable php8.2
sudo yum clean metadata
sudo yum install -y httpd php-cli php-fpm php-mysqlnd php-opcache php-xml php-gd php-mbstring php-curl unzip

# Add apache to autostart and start it
sudo systemctl start httpd
sudo systemctl enable httpd

# Install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/bin/wp

# WordPress download and extract
cd /var/www/html
sudo wget https://wordpress.org/latest.zip
sudo unzip latest.zip
sudo mv wordpress/* ./
sudo rm -rf wordpress latest.zip

# Set file and folders permissions WordPress
sudo chown -R apache:apache /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

# Generate wp-config.php from template
sudo -u apache cat <<'EOCONFIG' > /var/www/html/wp-config.php
${wp_config_content}
EOCONFIG

# WordPress installation
sudo -u apache wp core install \
  --url='${site_url}' \
  --title='${site_title}' \
  --admin_user='admin' \
  --admin_password='${admin_password}' \
  --admin_email='${admin_email}' \
  --path='/var/www/html'

# Create new user with viewer role
sudo -u apache wp user create viewer viewer@example.com --role='subscriber' --user_pass='passwd' --path='/var/www/html'

# Install and enable Redis Cache plugin
sudo -u apache wp plugin install https://github.com/rhubarbgroup/redis-cache/archive/refs/heads/develop.zip --activate
sudo -u apache wp redis enable --path='/var/www/html'

# Modify Apache config
sudo sed -i 's|^DocumentRoot ".*"|DocumentRoot "/var/www/html"|' /etc/httpd/conf/httpd.conf
sudo sed -i 's|<Directory "/var/www">|<Directory "/var/www/html">|' /etc/httpd/conf/httpd.conf

# Restart Apache 
sudo systemctl restart httpd