#!/bin/sh -eux
# appdynamics terraform cloud-init script to initialize aws ec2 instance launched from ami.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] aws user and host name config parameters [w/ defaults].
user_name="${user_name:-centos}"
aws_ec2_hostname="${aws_ec2_hostname:-terraform-user}"
aws_ec2_domain="${aws_ec2_domain:-localdomain}"
use_aws_ec2_num_suffix="${use_aws_ec2_num_suffix:-true}"

# [OPTIONAL] aws cli config parameters [w/ defaults].
aws_cli_default_region_name="${aws_cli_default_region_name:-us-east-1}"

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

# configure the hostname of the aws ec2 instance. --------------------------------------------------
# retrieve the num suffix from the ec2 instance name tag.
if [ "$use_aws_ec2_num_suffix" == "true" ]; then
  aws_ec2_instance_id="$(curl --silent http://169.254.169.254/latest/meta-data/instance-id)"
  aws_cli_cmd="aws ec2 describe-tags --filters \"Name=resource-id,Values=${aws_ec2_instance_id}\" \"Name=key,Values=Name\" --region ${aws_cli_default_region_name} | jq -r '.Tags[0].Value'"
  aws_ec2_name_tag=$(runuser -c "PATH=${user_home}/.local/bin:${PATH} eval ${aws_cli_cmd}" - ${user_name})
  aws_ec2_num_suffix=$(runuser -c "PATH=${user_home}/.local/bin:${PATH} eval ${aws_cli_cmd}" - ${user_name} | awk -F "-" '{print $NF}')
  aws_ec2_lab_hostname=$(printf "${aws_ec2_hostname}-%02d\n" "${aws_ec2_num_suffix}")
  aws_ec2_hostname=${aws_ec2_lab_hostname}
fi

# export environment variables.
export aws_ec2_hostname
export aws_ec2_domain

# set the hostname.
./config_al2_system_hostname.sh
