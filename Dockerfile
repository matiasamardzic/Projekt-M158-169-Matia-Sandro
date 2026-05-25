FROM php:8.1-apache
 
# Benötigte Server-Pakete installieren
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    curl \
&& docker-php-ext-install mysqli gd zip intl soap opcache exif
 
# Moodle 4.1.1 direkt über den offiziellen GitHub-Release ziehen (Die stabile LTS-Version)
RUN curl -L https://github.com/moodle/moodle/archive/refs/tags/v4.1.1.tar.gz | tar xz -C /var/www/html --strip-components=1
 
# PHP Limit für Moodle erhöhen (Behebt den max_input_vars Fehler, den wir auf Sandros VM hatten)
RUN echo "max_input_vars = 5000" > /usr/local/etc/php/conf.d/moodle.ini
 
# Unsere config.php in den Container kopieren
COPY config.php /var/www/html/config.php
 
# Berechtigungen setzen
RUN chown -R www-data:www-data /var/www/html