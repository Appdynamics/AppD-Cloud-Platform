#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AppDynamics Controller Platform Service by AppDynamics.
#
# The Controller sits at the center of an AppDynamics deployment. It's where AppDynamics agents
# send data on the activity in the monitored environment. It's also where users go
# to view, understand, and analyze that data.
#
# For more details, please visit:
#   https://docs.appdynamics.com/display/LATEST/Getting+Started
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with installed user privilege ('root' OR non-root user).
#
# TODO: Add logic to remove secondary host if not present.
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
appd_platform_domain="${appd_platform_domain:-localdomain}"

# [OPTIONAL] appdynamics controller install parameters [w/ defaults].
appd_controller_primary_host="${appd_controller_primary_host:-controller-node-01}"
appd_controller_secondary_host="${appd_controller_secondary_host:-controller-node-02}"
set +x  # temporarily turn command display OFF.
appd_controller_admin_username="${appd_controller_admin_username:-admin}"
appd_controller_admin_password="${appd_controller_admin_password:-welcome1}"
appd_controller_root_password="${appd_controller_root_password:-welcome1}"
appd_controller_mysql_password="${appd_controller_mysql_password:-welcome1}"
set -x  # turn command display back ON.
appd_controller_profile="${appd_controller_profile:-MEDIUM}"
appd_controller_tenancy_mode="${appd_controller_tenancy_mode:-SINGLE}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Install AppDynamics Controller Platform Service by AppDynamics.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with installed user privilege ('root' OR non-root user).

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [OPTIONAL] appdynamics platform install parameters [w/ defaults].
    [root]# export appd_home="/opt/appdynamics"                         # [optional] appd home (defaults to '/opt/appdynamics').
    [root]# export appd_platform_user_name="appduser"                   # [optional] platform user name (defaults to 'centos').
    [root]# export appd_platform_user_group="appduser"                  # [optional] platform group (defaults to 'centos').
    [root]# export appd_platform_admin_username="admin"                 # [optional] platform admin user name (defaults to user 'admin').
    [root]# export appd_platform_admin_password="welcome1"              # [optional] platform admin password (defaults to 'welcome1').
    [root]# export appd_platform_home="platform"                        # [optional] platform home folder (defaults to 'machine-agent').
    [root]# export appd_platform_name="My Platform"                     # [optional] platform name (defaults to 'My Platform').
    [root]# export appd_platform_description="My platform config."      # [optional] platform description (defaults to 'My platform config.').
    [root]# export appd_platform_product_home="product"                 # [optional] platform base installation directory for products
                                                                        #            (defaults to 'product').
    [root]# export appd_platform_credential_name="AppD-Cloud-Platform"  # [optional] platform credential name (defaults to 'AppD-Cloud-Platform').
    [root]# export appd_platform_credential_type="ssh"                  # [optional] platform credential type (defaults to 'ssh').
    [root]# export appd_platform_domain="localdomain"                   # [optional] platform domain (default to 'localdomain').

  [OPTIONAL] appdynamics controller install parameters [w/ defaults].
    [root]# export appd_controller_primary_host="controller-node-01"    # [optional] controller primary host (defaults to 'controller-node-01').
    [root]# export appd_controller_secondary_host="controller-node-02"  # [optional] controller secondary host (defaults to 'controller-node-02').
    [root]# export appd_controller_admin_username="admin"               # [optional] controller admin user name (defaults to 'admin').
    [root]# export appd_controller_admin_password="welcome1"            # [optional] controller admin password (defaults to 'welcome1').
    [root]# export appd_controller_root_password="welcome1"             # [optional] controller root password (defaults to 'welcome1').
    [root]# export appd_controller_mysql_password="welcome1"            # [optional] controller mysql root password (defaults to 'welcome1').
    [root]# export appd_controller_profile="MEDIUM"                     # [optional] appd controller profile (defaults to 'MEDIUM').
                                                                        #            valid profiles are:
                                                                        #              'INTERNAL', 'internal', 'DEMO', 'demo', 'SMALL', 'small',
                                                                        #              'MEDIUM', 'medium', 'LARGE', 'large', 'EXTRA-LARGE', 'extra-large'
    [root]# export appd_controller_tenancy_mode="SINGLE"                # [optional] appd controller tenancy mode (defaults to 'SINGLE').
                                                                        #            valid tenancy modes are:
                                                                        #              'SINGLE', 'single', 'MULTI', 'multi'
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

if [ -n "$appd_controller_profile" ]; then
  case $appd_controller_profile in
      INTERNAL|internal|DEMO|demo|SMALL|small|MEDIUM|medium|LARGE|large|EXTRA-LARGE|extra-large)
        ;;
      *)
        echo "Error: invalid 'appd_controller_profile'."
        usage
        exit 1
        ;;
  esac
fi

if [ -n "$appd_controller_tenancy_mode" ]; then
  case $appd_controller_tenancy_mode in
      SINGLE|single|MULTI|multi)
        ;;
      *)
        echo "Error: invalid 'appd_controller_tenancy_mode'."
        usage
        exit 1
        ;;
  esac
fi

# set appdynamics platform installation variables. -------------------------------------------------
appd_platform_folder="${appd_home}/${appd_platform_home}"
appd_product_folder="${appd_home}/${appd_platform_home}/${appd_platform_product_home}"

# start the appdynamics enterprise console. --------------------------------------------------------
cd ${appd_platform_folder}/platform-admin/bin
${appd_platform_folder}/platform-admin/bin/platform-admin.sh start-platform-admin

# verify installation.
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

# add primary and secondary hosts to platform. -----------------------------------------------------
${appd_platform_folder}/platform-admin/bin/platform-admin.sh \
  add-hosts \
    --hosts "${appd_controller_primary_host}.${appd_platform_domain}" \
    --credential "${appd_platform_credential_name}"
${appd_platform_folder}/platform-admin/bin/platform-admin.sh \
  add-hosts \
    --hosts "${appd_controller_secondary_host}.${appd_platform_domain}" \
    --credential "${appd_platform_credential_name}"

# install appdynamics controller. ------------------------------------------------------------------
set +x  # temporarily turn command display OFF.
${appd_platform_folder}/platform-admin/bin/platform-admin.sh \
  install-controller \
    --platform-name "${appd_platform_name}" \
    --host "${appd_controller_primary_host}.${appd_platform_domain}#Controller#Primary" \
           "${appd_controller_secondary_host}.${appd_platform_domain}#Controller#Secondary" \
    --profile "${appd_controller_profile}" \
    --tenancy-mode "${appd_controller_tenancy_mode}" \
    --admin-username "${appd_controller_admin_username}" \
    --admin-password "${appd_controller_admin_password}" \
    --controller-root-password "${appd_controller_root_password}" \
    --db-root-password "${appd_controller_mysql_password}"
set -x  # turn command display back ON.

# verify installation.
curl --silent http://${appd_controller_primary_host}:8090/controller/rest/serverstatus

# verify overall platform installation. ------------------------------------------------------------
${appd_platform_folder}/platform-admin/bin/platform-admin.sh list-supported-services
${appd_platform_folder}/platform-admin/bin/platform-admin.sh show-service-status --service controller
