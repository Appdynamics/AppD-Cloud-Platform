#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AppDynamics Events Service.
#
# The Events Service is the on-premises data storage facility for unstructured data generated by
# Application Analytics, Database Visibility, and End User Monitoring deployments. It provides
# high-volume, performance-intensive, and horizontally scalable storage for analytics data.
#
# For more details, please visit:
#   https://docs.appdynamics.com/display/LATEST/Events+Service+Deployment
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with installed user privilege ('root' OR non-root user).
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] appdynamics platform install parameters [w/ defaults].
appd_home="${appd_home:-/opt/appdynamics}"
set +x  # temporarily turn command display OFF.
appd_platform_admin_username="${appd_platform_admin_username:-admin}"
appd_platform_admin_password="${appd_platform_admin_password:-welcome1}"
set -x  # turn command display back ON.
appd_platform_home="${appd_platform_home:-platform}"
appd_platform_name="${appd_platform_name:-My Platform}"
appd_platform_product_home="${appd_platform_product_home:-product}"
appd_platform_credential_name="${appd_platform_credential_name:-AppD-Cloud-Platform}"
appd_platform_domain="${appd_platform_domain:-localdomain}"

# [OPTIONAL] appdynamics events service install parameters [w/ defaults].
appd_events_service_host1="${appd_events_service_host1:-es-node-01}"
appd_events_service_host2="${appd_events_service_host2:-es-node-02}"
appd_events_service_host3="${appd_events_service_host3:-es-node-03}"
appd_events_service_profile="${appd_events_service_profile:-PROD}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Install AppDynamics Events Service.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with installed user privilege ('root' OR non-root user).

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [OPTIONAL] appdynamics platform install parameters [w/ defaults].
    [root]# export appd_home="/opt/appdynamics"                         # [optional] appd home (defaults to '/opt/appdynamics').
    [root]# export appd_platform_admin_username="admin"                 # [optional] platform admin user name (defaults to user 'admin').
    [root]# export appd_platform_admin_password="welcome1"              # [optional] platform admin password (defaults to 'welcome1').
    [root]# export appd_platform_home="platform"                        # [optional] platform home folder (defaults to 'machine-agent').
    [root]# export appd_platform_name="My Platform"                     # [optional] platform name (defaults to 'My Platform').
    [root]# export appd_platform_product_home="product"                 # [optional] platform base installation directory for products
                                                                        #            (defaults to 'product').
    [root]# export appd_platform_credential_name="AppD-Cloud-Platform"  # [optional] platform credential name (defaults to 'AppD-Cloud-Platform').
    [root]# export appd_platform_domain="localdomain"                   # [optional] platform domain (default to 'localdomain').

  [OPTIONAL] appdynamics events service install parameters [w/ defaults].
    [root]# export appd_events_service_host1="es-node-01"               # [optional] events service host 1 (defaults to 'es-node-01').
    [root]# export appd_events_service_host2="es-node-02"               # [optional] events service host 2 (defaults to 'es-node-02').
    [root]# export appd_events_service_host3="es-node-03"               # [optional] events service host 3 (defaults to 'es-node-03').
    [root]# export appd_events_service_profile="PROD"                   # [optional] appd events service profile (defaults to 'PROD').
                                                                        #            valid profiles are:
                                                                        #              'DEV', 'dev', 'PROD', 'prod'
  --------
  Example:
  --------
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
if [ -n "$appd_events_service_profile" ]; then
  case $appd_events_service_profile in
      DEV|dev|PROD|prod)
        ;;
      *)
        echo "Error: invalid 'appd_events_service_profile'."
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

# add events service hosts to platform. ------------------------------------------------------------
${appd_platform_folder}/platform-admin/bin/platform-admin.sh \
  add-hosts \
    --hosts "${appd_events_service_host1}.${appd_platform_domain}" \
    --credential "${appd_platform_credential_name}"
${appd_platform_folder}/platform-admin/bin/platform-admin.sh \
  add-hosts \
    --hosts "${appd_events_service_host2}.${appd_platform_domain}" \
    --credential "${appd_platform_credential_name}"
${appd_platform_folder}/platform-admin/bin/platform-admin.sh \
  add-hosts \
    --hosts "${appd_events_service_host3}.${appd_platform_domain}" \
    --credential "${appd_platform_credential_name}"

# install appdynamics events service. --------------------------------------------------------------
set +x  # temporarily turn command display OFF.
${appd_platform_folder}/platform-admin/bin/platform-admin.sh \
  install-events-service \
    --platform-name "${appd_platform_name}" \
    --profile "${appd_events_service_profile}" \
    --hosts "${appd_events_service_host1}.${appd_platform_domain}" \
            "${appd_events_service_host2}.${appd_platform_domain}" \
            "${appd_events_service_host3}.${appd_platform_domain}"
set -x  # turn command display back ON.

# verify installation.
${appd_platform_folder}/platform-admin/bin/platform-admin.sh show-events-service-health

# verify overall platform installation. ------------------------------------------------------------
${appd_platform_folder}/platform-admin/bin/platform-admin.sh list-supported-services
${appd_platform_folder}/platform-admin/bin/platform-admin.sh show-service-status --service events-service
