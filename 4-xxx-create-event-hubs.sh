#!/bin/bash
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
#   resource group exists
# Provisions
#   Event Hubs namespace 
#       Enables a shared access token
#       Enables read/write for a user assigned identity
#   Event Hubs topics
#       Enables a shared access token

# Edit env.sh to your preferences
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/env.sh
source $DIR/env-identity.sh

echo "-----------event hub cluster-----------------"
echo "Not creating cluster. Don't want dedicated \$3K/month cluster"

echo "-----------namespace (kafka cluster)-----------------"
eh_namespace_metadata=$(az eventhubs namespace list --resource-group "$AZURE_RESOURCE_GROUP" --query "[?name=='$EVENTHUBS_NAMESPACE']")
echo "eh_eventhub_metadata: $eh_namespace_metadata"
if [ "[]" == "$eh_namespace_metadata" ]; then
    echo "creating eventhub namespace: $EVENTHUBS_NAMESPACE" \
    eh_namespace_create_results=$(az eventhubs namespace create  \
        --resource-group "$AZURE_RESOURCE_GROUP" \
        --name "$EVENTHUBS_NAMESPACE" \
        --location "$AZURE_REGION" \
        --enable-kafka true --sku Standard )
    echo "eventhubs namespace creation returned: $eh_namespace_create_results"
    # enables Shared Access Signature (SAS) on namespace - a token secret instead of AZ principal
    # Manage requires Listen and Send
    auth_rule_create_results=$(az eventhubs namespace authorization-rule create \
        --name $EVENTHUBS_NAMESPACE_AUTH_RULE \
        --namespace-name "$EVENTHUBS_NAMESPACE" \
        --resource-group "$AZURE_RESOURCE_GROUP" \
        --rights Listen Send Manage \
        )
    echo "eventhubs namespace auth-rule returned: $auth_rule_create_results"
else 
    echo "eventhubs namespace exists : $EVENTHUBS_NAMESPACE"
fi

# the only property that differs between calls is $eventhub_hub_name
eventhub_hub_create(){
    echo "-----------eventhubs eventhub (kafka topic)-----------------"
    eh_hub_metadata=$(az eventhubs eventhub list --resource-group "$AZURE_RESOURCE_GROUP" --namespace-name "$EVENTHUBS_NAMESPACE" --query "[?name=='$eventhub_hub_name']")
    echo "eh_hub_metadata for $EVENTHUBS_NAMESPACE:$eventhub_hub_name: $eh_hub_metadata"
    if [ "[]" == "$eh_hub_metadata" ]; then
        eh_hub_create_results=$(az eventhubs eventhub create \
            --name "$eventhub_hub_name" \
            --namespace-name "$EVENTHUBS_NAMESPACE" \
            --resource-group "$AZURE_RESOURCE_GROUP" \
            --message-retention 4 --partition-count 15  \
        )
        echo "eventubs eventhub $eventhub_hub_name creation returned: $eh_hub_create_results"
        # a bit of a hack.  we assume the consumer group's name is "cg-<hub-name>"
        eh_cg_create_results=$(az eventhubs eventhub consumer-group create \
            --eventhub-name "$eventhub_hub_name" \
            --name "cg-$eventhub_hub_name" \
            --namespace-name "$EVENTHUBS_NAMESPACE" \
            --resource-group "$AZURE_RESOURCE_GROUP" \
            )
        echo "eventubs eventhub consumer-group cg-$eventhub_hub_name creation returned: $eh_cg_create_results"
        # enables Shared Access Signature (SAS) on hub for Send - a token secret instead of AZ principal
        eh_auth_create_results=$(az eventhubs eventhub authorization-rule create \
            --eventhub-name "$eventhub_hub_name" \
            --name "$EVENTHUBS_HUB_AUTH_RULE" \
            --namespace-name "$EVENTHUBS_NAMESPACE" \
            --resource-group "$AZURE_RESOURCE_GROUP" \
            --rights Send \
        )
        echo "eventubs eventhub authorization-rule $EVENTHUBS_HUB_AUTH_RULE creation returned: $eh_auth_create_results"
    else
        echo "eventhubs eventhub consumer-group exists: $EVENTHUBS_NAMESPACE:$eventhub_hub_name"
        eh_hub_auth_rule_metadata=$(az eventhubs eventhub authorization-rule list \
            --eventhub-name "$eventhub_hub_name" \
            --namespace-name "$EVENTHUBS_NAMESPACE" \
            --resource-group "$AZURE_RESOURCE_GROUP" \
            )
        echo "eventhubs eventhub auth rule exists : $eh_hub_auth_rule_metadata"

    fi

}

# create the topic and success and failures similar to those used by spring cloud streaming
eventhub_hub_name="$EVENTHUBS_HUB_NAME_DATA"
eventhub_hub_create
eventhub_hub_name="$EVENTHUBS_HUB_NAME_SUCCESS"
eventhub_hub_create
eventhub_hub_name="$EVENTHUBS_HUB_NAME_FAIL"
eventhub_hub_create



