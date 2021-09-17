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


echo "-----------USER ASSIGNED IDENTITY-----------------"
# user assigned identity
rg_identity_metadata=$(az identity list --resource-group "$AZURE_RESOURCE_GROUP"  --query "[?name=='$EVENTHUBS_IDENTITY_NAME']")
echo "rg_identity_metadata: $rg_identity_metadata"
if [ "[]" == "$rg_identity_metadata" ]; then
    echo "creating identity: $EVENTHUBS_IDENTITY_NAME"
    identity_create_results=$(az identity create --resource-group "$AZURE_RESOURCE_GROUP" --name "$EVENTHUBS_IDENTITY_NAME")
    echo "identity creation returned: $identity_create_results"
else 
    echo "identity exists: $EVENTHUBS_IDENTITY_NAME"
fi
# retrieve the identity info
source env-identity.sh

# assign the identity somewhere if we needed like adding one to a key vault



