#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo or as root" 
   exit 1
fi

help_text()
{
    echo "Please provide arguments <domainname.com>"
}

if [ $# -eq 0 ] ; then
    help_text ;
    exit 1;
fi

WP_CUSTOM_DOMAIN_CONFIGNAME="${1}"

mkdir "/etc/nginx/${WP_CUSTOM_DOMAIN_CONFIGNAME}"
chown -R www-data:www-data "/etc/nginx/${WP_CUSTOM_DOMAIN_CONFIGNAME}"

mkdir "/var/www/${WP_CUSTOM_DOMAIN_CONFIGNAME}"
chown -R www-data:www-data "/var/www/${WP_CUSTOM_DOMAIN_CONFIGNAME}"

cat "/var/www/${WP_CUSTOM_DOMAIN_CONFIGNAME}/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Placeholder</title>
</head>
<body>
    <!-- Your website content goes here -->
    <h1>Placeholder!</h1>
</body>
</html>
EOF

mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled
touch "/etc/nginx/sites-available/${WP_CUSTOM_DOMAIN_CONFIGNAME}"
ln -s "/etc/nginx/sites-available/${WP_CUSTOM_DOMAIN_CONFIGNAME}" "/etc/nginx/sites-enabled/${WP_CUSTOM_DOMAIN_CONFIGNAME}"

cat nginx_wp_default.conf > "/etc/nginx/sites-available/${WP_CUSTOM_DOMAIN_CONFIGNAME}"

sed -i "s/WP_CUSTOM_DOMAIN_CONFIGNAME/$WP_CUSTOM_DOMAIN_CONFIGNAME/g" "/etc/nginx/sites-available/${WP_CUSTOM_DOMAIN_CONFIGNAME}"

#Install the latest version of WordPress
curl -fsSL "https://wordpress.org/latest.tar.gz" | tar xzf - -C "/var/www/${WP_CUSTOM_DOMAIN_CONFIGNAME}"

#Restart nginx if config passes validation
nginx -t && systemctl restart nginx