# Clone from the latest Fedora image
FROM fedora:latest

# Let us hope I do no regret this...
MAINTAINER Mo Khan <monis@redhat.com>

# Install Apache with PHP and TLS support
RUN dnf install -y \
    httpd \
    php \
    mod_php \
    mod_ssl \
    && dnf clean all

# Add conf file for Apache that handles
# the remote basic auth IDP flow
ADD remote_basic.conf /etc/httpd/conf.d/remote_basic.conf

# Stomp on default MPM config file
# Use mpm_prefork_module so that PHP works without threading support
ADD mpm.conf /etc/httpd/conf.modules.d/00-mpm.conf

# Add root CA that is used to verify TLS
ADD certs/ca.crt /etc/pki/tls/certs/ca.crt

# Add SSLCertificate{Key}File so that OpenShift
# can verify connections to the remote basic auth IDP
# Name them localhost.{crt,key} to match the default https ssl.conf
# This stomps on the default files
ADD certs/localhost.crt /etc/pki/tls/certs/localhost.crt
ADD certs/localhost.key /etc/pki/tls/private/localhost.key

# Add PHP script that turns the Apache REMOTE_USER env var
# into a JSON formatted response that OpenShift understands
ADD check_user.php /var/www/html/check_user.php

# 443 = https, we only expose this since
# we do not support any other protocol
EXPOSE 443

# Set up htpasswd and start Apache
# Has hooks to allow for easy interactive debugging
ADD configure.sh /usr/sbin/configure.sh
ENTRYPOINT /usr/sbin/configure.sh
