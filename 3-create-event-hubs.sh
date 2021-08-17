#!/bin/bash
#
# Assumes 
#   azure cli is installed
#   jq is installed
#   default subscription
#   resource group exists
# Provisions
#   #vent Hubs cluster 
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
eh_cluster_metadata=$(az eventhubs cluster list --resource-group "$AZURE_RESOURCE_GROUP" --query "[?name=='$EVENTHUBS_CLUSTER_NAME']")
echo "eh_eventhub_metadata: $eh_cluster_metadata"
if [ "[]" == "$eh_cluster_metadata" ]; then
    echo "creating eventhub cluster: $EVENTHUBS_CLUSTER_NAME"
    eh_cluster_create_results=$(az eventhubs cluster create  \
        --resource-group "$AZURE_RESOURCE_GROUP" \
        --name "$EVENTHUBS_CLUSTER_NAME" \
        --location "$AZURE_REGION" \
        )
    echo "event hubs cluster creation returned: $eh_cluster_create_results"
else 
    echo "event hub cluster exists : $EVENTHUBS_CLUSTER_NAME"
fi

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
    # enables Shared Access Signature (SAS) - a token secret instead of AZ principal
    auth_rule_create_results=$(az eventhubs namespace authorization-rule create \
        --name $EVENTHUBS_NAMESPACE_AUTH_RULE \
        --namespace-name "$EVENTHUBS_NAMESPACE" \
        --resource-group "$AZURE_RESOURCE_GROUP" \
        --rights Listen Send \
        )
    echo "eventhubs namespace augh-rule returned: $auth_rule_create_results"
else 
    echo "eventhubs namespace exists : $EVENTHUBS_NAMESPACE"
fi

echo "-----------namespace rbac for UAI (kafka cluster)-----------------"
# could be moved inside create block above
# enable user assigned identity as sender/receiver
# could do this with service principal instead
sender_role_id=$(az role definition list -n "Azure Event Hubs Data Sender" -o tsv --query '[0].id')
receiver_role_id=$(az role definition list -n "Azure Event Hubs Data Receiver" -o tsv --query '[0].id')
eventhubs_id=$(az eventhubs namespace show --resource-group $AZURE_RESOURCE_GROUP --name $EVENTHUBS_NAMESPACE -o tsv --query 'id')
az role assignment create --assignee $EVENTHUBS_ID_PRINCIPAL_ID --role $sender_role_id --scope $eventhubs_id
az role assignment create --assignee $EVENTHUBS_ID_PRINCIPAL_ID --role $receiver_role_id --scope $eventhubs_id  


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
        # enables Shared Access Signature (SAS) - a token secret instead of AZ principal
        eh_auth_create_results=$(az eventhubs eventhub authorization-rule create \
            --eventhub-name "$eventhub_hub_name" \
            --name "$EVENTHUBS_HUB_AUTH_RULE" \
            --namespace-name "$EVENTHUBS_NAMESPACE" \
            --resource-group "$AZURE_RESOURCE_GROUP" \
            --rights Listen Send \
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



