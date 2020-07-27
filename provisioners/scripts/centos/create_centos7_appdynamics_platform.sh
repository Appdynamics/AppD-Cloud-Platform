#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Create AppDynamics Platform by AppDynamics.
#
# The platform is the collection of AppDynamics components and their hosts.
# The Enterprise Console supports up to 20 platforms at a time by default.
# 
# For more details, please visit:
#   https://docs.appdynamics.com/display/LATEST/Administer+the+Enterprise+Console
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with installed user privilege ('root' OR non-root user).
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] appdynamics platform install parameters [w/ defaults].
appd_home="${appd_home:-/opt/appdynamics}"
appd_platform_user_name="${appd_platform_user_name:-centos}"
set +x  # temporarily turn command display OFF.
appd_platform_admin_username="${appd_platform_admin_username:-admin}"
appd_platform_admin_password="${appd_platform_admin_password:-welcome1}"
set -x  # turn command display back ON.
appd_platform_home="${appd_platform_home:-platform}"
appd_platform_name="${appd_platform_name:-My Platform}"
appd_platform_description="${appd_platform_description:-My platform config.}"
appd_platform_product_home="${appd_platform_product_home:-product}"
appd_platform_credential_name="${appd_platform_credential_name:-AppD-Cloud-Platform}"
appd_platform_credential_type="${appd_platform_credential_type:-ssh}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Create AppDynamics Platform by AppDynamics.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with installed user privilege ('root' OR non-root user).

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [OPTIONAL] appdynamics platform install parameters [w/ defaults].
    [root]# export appd_home="/opt/appdynamics"                         # [optional] appd home (defaults to '/opt/appdynamics').
    [root]# export appd_platform_user_name="appduser"                   # [optional] platform user name (defaults to 'centos').
    [root]# export appd_platform_admin_username="admin"                 # [optional] platform admin user name (defaults to user 'admin').
    [root]# export appd_platform_admin_password="welcome1"              # [optional] platform admin password (defaults to 'welcome1').
    [root]# export appd_platform_home="platform"                        # [optional] platform home folder (defaults to 'machine-agent').
    [root]# export appd_platform_name="My Platform"                     # [optional] platform name (defaults to 'My Platform').
    [root]# export appd_platform_description="My platform config."      # [optional] platform description (defaults to 'My platform config.').
    [root]# export appd_platform_product_home="product"                 # [optional] platform base installation directory for products
                                                                        #            (defaults to 'product').
    [root]# export appd_platform_credential_name="AppD-Cloud-Platform"  # [optional] platform credential name (defaults to 'AppD-Cloud-Platform').
    [root]# export appd_platform_credential_type="ssh"                  # [optional] platform credential type (defaults to 'ssh').

  --------
  Example:
  --------
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
if [ -n "$appd_platform_credential_type" ]; then
  case $appd_platform_credential_type in
      ssh|powershell)
        ;;
      *)
        echo "Error: invalid 'appd_platform_credential_type'."
        usage
        exit 1
        ;;
  esac
fi

# set appdynamics platform installation variables. -------------------------------------------------
appd_platform_folder="${appd_home}/${appd_platform_home}"
appd_product_folder="${appd_home}/${appd_platform_home}/${appd_platform_product_home}"

# verify appdynamics enterprise console installation. ----------------------------------------------
cd ${appd_platform_folder}/platform-admin/bin
${appd_platform_folder}/platform-admin/bin/platform-admin.sh show-platform-admin-version

# login to the appdynamics platform. ---------------------------------------------------------------
set +x  # temporarily turn command display OFF.
${appd_platform_folder}/platform-admin/bin/platform-admin.sh \
  login \
    --user-name "${appd_platform_admin_username}" \
    --password "${appd_platform_admin_password}"
set -x  # turn command display back ON.

# create an appdynamics platform. ------------------------------------------------------------------
${appd_platform_folder}/platform-admin/bin/platform-admin.sh \
  create-platform \
    --name "${appd_platform_name}" \
    --description "${appd_platform_description}" \
    --installation-dir "${appd_product_folder}"
#export APPD_CURRENT_PLATFORM="${appd_platform_name}"

# add the platform credentials. --------------------------------------------------------------------
${appd_platform_folder}/platform-admin/bin/platform-admin.sh \
  add-credential \
    --credential-name "${appd_platform_credential_name}" \
    --type "${appd_platform_credential_type}" \
    --user-name "${appd_platform_user_name}" \
    --ssh-key-file "/home/${appd_platform_user_name}/.ssh/${appd_platform_credential_name}.pem"

# verify platform installation. --------------------------------------------------------------------
${appd_platform_folder}/platform-admin/bin/platform-admin.sh list-platforms
${appd_platform_folder}/platform-admin/bin/platform-admin.sh get-current-working-platform
${appd_platform_folder}/platform-admin/bin/platform-admin.sh list-credentials
