#!/bin/sh -eux
# appdynamics lpad cloud-init script to initialize aws ec2 instance launched from ami.

# set default values for input environment variables if not set. -----------------------------------
# [MANDATORY] aws cli config parameters [w/ defaults].
set +x  # temporarily turn command display OFF.
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-}"
set -x  # turn command display back ON.

# [OPTIONAL] aws user and host name config parameters [w/ defaults].
user_name="${user_name:-centos}"
aws_ec2_hostname="${aws_ec2_hostname:-lpad}"
aws_ec2_domain="${aws_ec2_domain:-localdomain}"

# [OPTIONAL] aws cli config parameters [w/ defaults].
aws_cli_default_region_name="${aws_cli_default_region_name:-us-east-1}"
aws_cli_default_output_format="${aws_cli_default_output_format:-json}"

# validate environment variables. ------------------------------------------------------------------
set +x    # temporarily turn command display OFF.
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "Error: 'AWS_ACCESS_KEY_ID' environment variable not set."
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Error: 'AWS_SECRET_ACCESS_KEY' environment variable not set."
  exit 1
fi
set -x    # turn command display back ON.

if [ -n "$aws_cli_default_output_format" ]; then
  case $aws_cli_default_output_format in
      json|text|table)
        ;;
      *)
        echo "Error: invalid 'aws_cli_default_output_format'."
        exit 1
        ;;
  esac
fi

# configure public keys for specified user. --------------------------------------------------------
user_authorized_keys_file="/home/${user_name}/.ssh/authorized_keys"
user_key_name="AppD-Cloud-Platform"
user_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCumK6tu+GOsk6PmRBMo3pZVYOZkfvFlGcWJJjvdGUQn/9rW/yZU95Iy0MYVCn8m1cpD5bzT6c62W2lt305OeJOu8vH2nc4JZ+bMXAxAP4oG1tCxVs6VofdUcbD64yA+bIfoB/liqZoC/eN43s0r7wmD1AajqcSmjzO9PunDi67UzMU2x/5ilP02xGy/TPHbCDDmE7uGg2e0wSZaydFy6pRB1IddK6TIGxs0DKhr03DA9v/f8vougjJ0Me/nrVSR5y0dlOzVcSKXgzv4v0NFr3RYEK3IlG3o9EkbXaMWaenXV/pSPEk8aF51vZjwFrCPinIqMqBmlGvtnoUIgyiaGXx AppD-Cloud-Platform"

# 'grep' to see if the user's public key is already present, if not, append to the file.
grep -qF "${user_key_name}" ${user_authorized_keys_file} || echo "${user_public_key}}" >> ${user_authorized_keys_file}
chmod 600 ${user_authorized_keys_file}

# delete public key inserted by packer during the ami build.
sed -i -e "/packer/d" ${user_authorized_keys_file}

# configure the hostname of the aws ec2 instance. --------------------------------------------------
# export environment variables.
export aws_ec2_hostname
export aws_ec2_domain

# set the hostname.
./config_al2_system_hostname.sh

# configure the aws cli client. --------------------------------------------------------------------
# remove current configuration if it exists.
aws_cli_config_dir="/home/${user_name}/.aws"
if [ -d "$aws_cli_config_dir" ]; then
  rm -Rf ${aws_cli_config_dir}
fi

set +x    # temporarily turn command display OFF.
aws_config_cmd=$(printf "aws configure <<< \$\'%s\\\\n%s\\\\n%s\\\\n%s\\\\n\'\n" ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} ${aws_cli_default_region_name} ${aws_cli_default_output_format})
runuser -c "PATH=/home/${user_name}/.local/bin:${PATH} eval ${aws_config_cmd}" - ${user_name}
set -x    # turn command display back ON.

# verify the aws cli configuration by displaying a list of aws regions in table format.
runuser -c "PATH=/home/${user_name}/.local/bin:${PATH} aws ec2 describe-regions --output table" - ${user_name}
