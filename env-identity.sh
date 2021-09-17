#!/bin/bash
# The user identity was needed in more than one script

identity_metadata=$(az identity show --name $EVENTHUBS_IDENTITY_NAME --resource-group $AZURE_RESOURCE_GROUP)
# Yeah we're ovewriting this.  I don't remember why
EVENTHUBS_IDENTITY_NAME=$(jq -r ".name" <<< "$identity_metadata")
EVENTHUBS_ID_PRINCIPAL_ID=$(jq -r ".principalId" <<< "$identity_metadata")
EVENTHUBS_ID_IDENTITY_ID=$(jq -r ".id" <<< "$identity_metadata")
# client id is required for queries if multiple identities tied to VM
EVENTHUBS_ID_CLIENT_ID=$(        jq -r ".clientId"        <<< "$identity_metadata")
EVENTHUBS_ID_CLIENT_SECRET_URL=$(jq -r ".clientSecretUrl" <<< "$identity_metadata")
echo "UAI: $EVENTHUBS_IDENTITY_NAME principal: $EVENTHUBS_ID_PRINCIPAL_ID UAI id: $EVENTHUBS_ID_IDENTITY_ID "
echo "UAI client id: $EVENTHUBS_ID_CLIENT_ID"
echo "UAI client secret url: $EVENTHUBS_ID_CLIENT_SECRET_URL"
