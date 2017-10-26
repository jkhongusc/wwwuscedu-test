#!/bin/bash
set -euo pipefail


echoerr() { echo "$@" 1>&2; }

#echo `pwd`
github_user=`cat /run/secrets/github_username`
github_passwd=`cat /run/secrets/github_oauth`
wpconfig=`cat /run/secrets/homeadmin-test-wp-config.php`
if [[ -z "$github_user" ]]; then
    echoerr "missing github user secret"
    exit 1
fi
if [[ -z "$github_passwd" ]]; then
    echoerr "missing github password secret"
    exit 1
fi
if [[ -z "$wpconfig" ]]; then
    echoerr "missing wp-config.php secret"
    exit 1
fi
echoerr "passed secret check"



if [[ "$1" == apache2* ]] || [ "$1" == php-fpm ]; then
        if ! [ -e index.php -a -e wp-includes/version.php ]; then
                if [ -e master.zip ]; then
                        echo
                        rm master.zip
                fi
                echo >&2 "WordPress not found in $PWD - pulling master now..."
                curl -u $github_user:$github_passwd -L  https://github.com/uscwebservices/aws-homepage-test/archive/master.zip -o master.zip
                if [ -e master.zip ]; then
                        echo >&2 "extracting master now..."
                        unzip -qqo master.zip
                        (cd /var/www/html/aws-homepage-test-master && tar c .) | (cd /var/www/html && tar xf -)
                        #mv aws-homepage-test-master/.* .
                        #mv aws-homepage-test-master/* .
                        rm -rf aws-homepage-test-master
                        rm master.zip
                fi
                cp /run/secrets/homeadmin-test-wp-config.php ./wp-config.php
        fi

fi





exec "$@"
