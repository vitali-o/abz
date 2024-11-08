#!/bin/bash

# Обновление системы и установка необходимых пакетов
sudo yum update -y
sudo amazon-linux-extras enable php8.2
sudo yum clean metadata
sudo yum install -y httpd php-cli php-fpm php-mysqlnd php-opcache php-xml php-gd php-mbstring php-curl unzip

# Запуск и настройка автозагрузки Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Установка WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/bin/wp

# Загрузка и установка WordPress
cd /var/www/html
sudo wget https://wordpress.org/latest.zip
sudo unzip latest.zip
sudo mv wordpress/* ./
sudo rm -rf wordpress latest.zip

# Настройка прав доступа для файлов WordPress
sudo chown -R apache:apache /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

# Генерация wp-config.php
sudo -u apache cat <<'EOCONFIG' > /var/www/html/wp-config.php
${wp_config_content}
EOCONFIG

# Установка WordPress с начальной конфигурацией
sudo -u apache wp core install \
  --url='${site_url}' \
  --title='ABZ Homework' \
  --admin_user='admin' \
  --admin_password='${admin_password}' \
  --admin_email='${admin_email}' \
  --path='/var/www/html'

# Создание нового пользователя с ролью 'Подписчик'
sudo -u apache wp user create viewer viewer@example.com --role=subscriber --user_pass=viewerpassword --path='/var/www/html'

# Установка и активация плагина Redis
sudo -u apache wp plugin install https://github.com/rhubarbgroup/redis-cache/archive/refs/heads/develop.zip --activate
sudo -u apache wp redis enable --path='/var/www/html'

# Настройка Apache для правильной директории
sudo sed -i 's|^DocumentRoot ".*"|DocumentRoot "/var/www/html"|' /etc/httpd/conf/httpd.conf
sudo sed -i 's|<Directory "/var/www">|<Directory "/var/www/html">|' /etc/httpd/conf/httpd.conf

# Перезапуск Apache для применения изменений
sudo systemctl restart httpd