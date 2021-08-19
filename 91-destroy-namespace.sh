#!/bin/bash
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
# Removes
#   eventhubs namespace and all contained eventhubs


# Edit env.sh to your preferences
source env.sh

az eventhubs namespace delete --name "$EVENTHUBS_NAMESPACE" --resource-group "$AZURE_RESOURCE_GROUP"