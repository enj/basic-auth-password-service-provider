#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Set up apache htpasswd file
htpasswd -b -c /etc/httpd.htpasswd "testuser1" "password1"
chown apache /etc/httpd.htpasswd

# Make sure Apache can write logs
chown -R apache /etc/httpd/logs

# Start apache
httpd -k start

# Allow for easy interactive debugging
if [ -t 0 ] ; then
    echo 'Starting interactive shell.'
    /bin/bash
else
    echo 'Go loop.'
    while true ; do sleep 1000 & wait $! ; done
fi
