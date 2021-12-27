#!/bin/bash
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
# Provisions
#   VNET via ARM template
set -e

# Edit env.sh to your preferences
DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/env.sh

echo "This will take several minutes "
echo "-----------------EventHub Namespaces, Topics and Identities------------------"
az deployment group create --resource-group "$AZURE_RESOURCE_GROUP" \
    --template-file resource-templates/template-eventhubs.json \
    --parameters \
    userAssignedIdentities_identity_name="$EVENTHUBS_IDENTITY_NAME" \
    namespaces_namespace_name="$EVENTHUBS_NAMESPACE" \
    namespaces_namespace_authRule_manage_name="$EVENTHUBS_NAMESPACE_AUTH_RULE_MANAGE"\
    namespaces_namespace_authRule_client_name="$EVENTHUBS_NAMESPACE_AUTH_RULE_CLIENT"\
    schema_name="$EVENTHUBS_SCHEMA" \
    eventHubs_eventHub_data_name="$EVENTHUBS_HUB_NAME_DATA" \
    eventHubs_eventHub_success_name="$EVENTHUBS_HUB_NAME_SUCCESS" \
    eventHubs_eventHub_failure_name="$EVENTHUBS_HUB_NAME_FAIL" \
    eventHubs_eventHub_authRule_name="$EVENTHUBS_HUB_AUTH_RULE" \
    lastPublishedAt="$NOW_PUBLISHED_AT"

