#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Configure AppDynamics Load Balancer URL in the Controller by AppDynamics.
#
# To distribute load among the members of an Events Service cluster, you need to set up a
# load balancer. For a single node Events Service deployment, using a load balancer is optional
# but recommended, since it minimizes the work of scaling up to an Events Service cluster later.
#
# For more details, please visit:
#   https://docs.appdynamics.com/display/LATEST/Events+Service+Deployment
#   https://docs.appdynamics.com/display/LATEST/Load+Balance+Events+Service+Traffic
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [MANDATORY] appdynamics events service controller configuration parameters.
appd_events_service_load_balancer_url="${appd_events_service_load_balancer_url:-}"

# [OPTIONAL] appdynamics controller configuration parameters [w/ defaults].
appd_controller_url="${appd_controller_url:-http://controller-node-01:8090}"
#appd_controller_url="${appd_controller_url:-http://controller-node-01.localdomain:8090}"

# validate environment variables. ------------------------------------------------------------------
if [ -z "$appd_events_service_load_balancer_url" ]; then
  echo "Error: 'appd_events_service_load_balancer_url' environment variable not set."
  usage
  exit 1
fi

# set current date for temporary filename. ---------------------------------------------------------
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# set events service load balancer url property in the controller. ---------------------------------
appd_controller_config_key="appdynamics.on.premise.event.service.url"
appd_controller_config_value="${appd_events_service_load_balancer_url}"
post_data_filename="post-data.${curdate}.json"

# create the post data json payload file.
rm -f "${post_data_filename}"
cat <<EOF > ${post_data_filename}
{
  "name": "${appd_controller_config_key}",
  "value": "${appd_controller_config_value}"
}
EOF
chmod 644 "${post_data_filename}"

# authenticate to the appdynamics controller and store the jsession id and csrf token.
set +x  # temporarily turn command display OFF.
auth_cookies=$(curl --silent --include --user root@system:welcome1 ${appd_controller_url}/controller/auth?action=login | awk '/Set-Cookie/ {cookie = cookie $2} END {print cookie}')
set -x  # turn command display back ON.
jsession_id=$(echo $auth_cookies | awk -F ';' '{print $1}')
csrf_token=$(echo $auth_cookies | awk -F ';' '{print $2}')

# set the events service url property.
echo "Setting the events service URL property in the Controller:"
echo "  ${appd_controller_config_key}: ${appd_controller_config_value}"
curl --silent --request POST --data @${post_data_filename} --header "Cookie: ${jsession_id};${csrf_token};" --header "Accept: */*" --header "Content-Type: application/json;charset=UTF-8" "${appd_controller_url}/controller/restui/admin/configuration/set?${csrf_token}"

# clean-up the post data file.
rm -f ${post_data_filename}
