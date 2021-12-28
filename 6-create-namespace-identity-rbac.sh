#!/bin/bash
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
#   resource group exists
# Provisions
#   Event Hubs namespace 
#       Enables a shared access token - now in the ARM template
#       Enables read/write for a user assigned identity
#   Event Hubs topics
#       Enables a shared access token - now in the ARM template
#   Schema Registry
#       Enables Contributor for a user assigned identity

# Edit env.sh to your preferences
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/env.sh
source $DIR/env-identity.sh

echo "-----------namespace rbac for UAI (kafka cluster)-----------------"
# enable user assigned identity as sender/receiver
# could do this with service principal instead
eventhubs_namespace_id=$(az eventhubs namespace show --resource-group $AZURE_RESOURCE_GROUP --name $EVENTHUBS_NAMESPACE -o tsv --query 'id')

sender_role_id=$(az role definition list -n "Azure Event Hubs Data Sender" -o tsv --query '[0].id')
receiver_role_id=$(az role definition list -n "Azure Event Hubs Data Receiver" -o tsv --query '[0].id')
az role assignment create --assignee $EVENTHUBS_ID_PRINCIPAL_ID --role $sender_role_id --scope $eventhubs_namespace_id
az role assignment create --assignee $EVENTHUBS_ID_PRINCIPAL_ID --role $receiver_role_id --scope $eventhubs_namespace_id  

schema_reader_role_id=$(az role definition list -n "Schema Registry Reader (Preview)" -o tsv --query '[0].id')
schema_contributor_role_id=$(az role definition list -n "Schema Registry Contributor (Preview)" -o tsv --query '[0].id')
az role assignment create --assignee $EVENTHUBS_ID_PRINCIPAL_ID --role $schema_reader_role_id --scope $eventhubs_namespace_id
az role assignment create --assignee $EVENTHUBS_ID_PRINCIPAL_ID --role $schema_contributor_role_id --scope $eventhubs_namespace_id  
