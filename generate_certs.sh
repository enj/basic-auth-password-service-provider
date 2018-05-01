#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

certs_dir="certs"
current_dir="$( dirname "${BASH_SOURCE[0]}" )"
mkdir -p "${current_dir}/${certs_dir}"
cd "${current_dir}/${certs_dir}"

# Root CA
openssl req -subj "/CN=root_ca" -new -newkey rsa:4096 -days 365 -nodes -x509 -keyout ca.key -out ca.crt -sha256

# Openshift master and Apache (localhost) certs
serial=0
clients=(openshift_master localhost)
for client in ${clients[@]}; do
    serial=$((serial + 1))
    openssl genrsa -out "${client}.key" 4096
    openssl req -subj "/CN=${client}" -new -key "${client}.key" -out "${client}.csr"
    openssl x509 -req -days 365 -in "${client}.csr" -CA ca.crt -CAkey ca.key -set_serial "${serial}" -out "${client}.crt"
done
