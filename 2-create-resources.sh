#!/bin/bash
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
# Provisions
#   Resource Group
#   User Assigned Identity

# Edit env.sh to your preferences
DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/env.sh

echo "---------RESOURCE GROUP-------------------"
# TODO: add the region to this query!
rg_exists=$(az group exists --resource-group "$AZURE_RESOURCE_GROUP")
if [ "false" = "$rg_exists" ]; then 
    echo "creating resource group : $AZURE_RESOURCE_GROUP"
    # should we capture the output of this? would we lose error messages?
    az group create --name "$AZURE_RESOURCE_GROUP" -l "$AZURE_REGION"
else
    echo "resource group exists: $AZURE_RESOURCE_GROUP"
fi
rg_metadata=$(az group list --query "[?name=='$AZURE_RESOURCE_GROUP']")
echo "using resource group: $rg_metadata"


echo "-----------USER ASSIGNED IDENTITY-----------------"
# user assigned identity
rg_identity_metadata=$(az identity list --resource-group "$AZURE_RESOURCE_GROUP"  --query "[?name=='$EVENTHUBS_ID_NAME']")
echo "rg_identity_metadata: $rg_identity_metadata"
if [ "[]" == "$rg_identity_metadata" ]; then
    echo "creating identity: $EVENTHUBS_ID_NAME"
    identity_create_results=$(az identity create --resource-group "$AZURE_RESOURCE_GROUP" --name "$EVENTHUBS_ID_NAME")
    echo "identity creation returned: $identity_create_results"
else 
    echo "identity exists: $EVENTHUBS_ID_NAME"
fi
# retrieve the identity info
source env-identity.sh

# assign the identity somewhere if we needed like adding one to a key vault



