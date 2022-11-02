#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install eksctl CLI for Amazon EKS.
#
# eksctl is a simple CLI tool for creating clusters on EKS - Amazon's new managed Kubernetes
# service for EC2. It is written in Go, and uses CloudFormation.
#
# You can create a cluster in minutes with just one command: 'eksctl create cluster'!
#
# For more details, please visit:
#   https://github.com/weaveworks/eksctl
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# install eksctl cli. ------------------------------------------------------------------------------
eksctl_release="0.116.0"
eksctl_binary="eksctl_$(uname -s)_amd64.tar.gz"
eksctl_sha256="59ba2383f4abcf863c1586541f5792d7707f954f169c2745661229c0a2b58c5b"

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download eksctl binary from github.com.
rm -f ${eksctl_binary}
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/v${eksctl_release}/${eksctl_binary}" --output ${eksctl_binary}

# verify the downloaded binary.
echo "${eksctl_sha256} ${eksctl_binary}" | sha256sum --check
# eksctl_$(uname -s)_amd64.tar.gz: OK

# extract eksctl binary.
rm -f eksctl
tar -zxvf ${eksctl_binary} --no-same-owner --no-overwrite-dir
chown root:root eksctl
rm -f ${eksctl_binary}

# change execute permissions.
chmod 755 eksctl

# set eksctl environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
eksctl version
