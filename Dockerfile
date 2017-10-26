FROM php:7.1-apache

# install the PHP extensions we need
RUN set -ex; \
        \
        apt-get update; \
        apt-get install -y \
                libapache2-mod-shib2 \
                libjpeg-dev \
                libpng-dev \
                zip \
        ; \
        rm -rf /var/lib/apt/lists/*; \
        \
        docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
        docker-php-ext-install gd mysqli opcache
# TODO consider removing the *-dev deps and only keeping the necessary lib* packages

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
                echo 'opcache.memory_consumption=128'; \
                echo 'opcache.interned_strings_buffer=8'; \
                echo 'opcache.max_accelerated_files=4000'; \
                echo 'opcache.revalidate_freq=2'; \
                echo 'opcache.fast_shutdown=1'; \
                echo 'opcache.enable_cli=1'; \
        } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN a2enmod rewrite expires shib2 ssl

VOLUME /var/www/html

ENV WORDPRESS_VERSION 4.8.1
ENV WORDPRESS_SHA1 5376cf41403ae26d51ca55c32666ef68b10e35a4


COPY docker-entrypoint.sh /usr/local/bin/
COPY apache2-shibd-foreground /usr/local/bin/
COPY conf/apache2/homepage-test.conf /etc/apache2/sites-available/homepage-test.conf
COPY conf/apache2/homepage-test-ssl.conf /etc/apache2/sites-available/homepage-test-ssl.conf
#COPY conf/apache2/homeadmin-test.usc.edu_2048.key /etc/ssl/private/homeadmin-test.usc.edu_2048.key
COPY conf/apache2/homeadmin-test.usc.edu_20200224.crt /etc/ssl/certs/homeadmin-test.usc.edu_20200224.crt
COPY conf/apache2/homeadmin-test.usc.edu.interm2.crt /etc/ssl/certs/homeadmin-test.usc.edu.interm2.crt
COPY conf/shibboleth/attribute-map.xml /etc/shibboleth/attribute-map.xml
COPY conf/shibboleth/attribute-policy.xml /etc/shibboleth/attribute-policy.xml
COPY conf/shibboleth/customsites-shib.usc.edu.crt /etc/shibboleth/customsites-shib.usc.edu.crt
#COPY conf/shibboleth/customsites-shib.usc.edu.key /etc/shibboleth/customsites-shib.usc.edu.key
COPY conf/shibboleth/localLogout.html /etc/shibboleth/localLogout.html
COPY conf/shibboleth/shibboleth2.xml /etc/shibboleth/shibboleth2.xml

RUN a2ensite homepage-test
RUN a2ensite homepage-test-ssl

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-shibd-foreground"]
#CMD ["apache2-foreground"]

