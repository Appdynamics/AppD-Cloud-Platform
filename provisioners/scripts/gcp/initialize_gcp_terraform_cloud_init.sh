#!/bin/sh -eux
# appdynamics terraform cloud-init script to initialize gcp compute engine instance.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] gcp user and host name config parameters [w/ defaults].
user_name="${user_name:-centos}"
gcp_gce_hostname="${gcp_gce_hostname:-terraform-user}"
gcp_gce_domain="${gcp_gce_domain:-localdomain}"
use_gcp_gce_num_suffix="${use_gcp_gce_num_suffix:-true}"

# configure public keys for specified user. --------------------------------------------------------
user_home=$(eval echo "~${user_name}")
user_authorized_keys_file="${user_home}/.ssh/authorized_keys"
user_key_name="AppD-Cloud-Platform"
user_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCumK6tu+GOsk6PmRBMo3pZVYOZkfvFlGcWJJjvdGUQn/9rW/yZU95Iy0MYVCn8m1cpD5bzT6c62W2lt305OeJOu8vH2nc4JZ+bMXAxAP4oG1tCxVs6VofdUcbD64yA+bIfoB/liqZoC/eN43s0r7wmD1AajqcSmjzO9PunDi67UzMU2x/5ilP02xGy/TPHbCDDmE7uGg2e0wSZaydFy6pRB1IddK6TIGxs0DKhr03DA9v/f8vougjJ0Me/nrVSR5y0dlOzVcSKXgzv4v0NFr3RYEK3IlG3o9EkbXaMWaenXV/pSPEk8aF51vZjwFrCPinIqMqBmlGvtnoUIgyiaGXx AppD-Cloud-Platform"

# 'grep' to see if the user's public key is already present, if not, append to the file.
grep -qF "${user_key_name}" ${user_authorized_keys_file} || echo "${user_public_key}" >> ${user_authorized_keys_file}
chmod 600 ${user_authorized_keys_file}

# delete public key inserted by packer during the ami build.
sed -i -e "/packer/d" ${user_authorized_keys_file}

# configure the hostname of the gcp gce instance. --------------------------------------------------
# export environment variables.
export gcp_gce_hostname
export gcp_gce_domain

# set the hostname.
./config_gcp_system_hostname.sh
