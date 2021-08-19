#!/bin/bash

# should set the subscription
AZURE_REGION="EastUS"
#AZURE_SUBSCRIPTION=[to be filled]


# add version # to name  to avoid complications with soft-deleted keyvaults while testing
# keyvault deletes are soft deletes witha purgable recovery == 90 days 2021/07
root_name="event-hub-example-1"

# decided to not prefix the resource names with the resource type rg, ia, cl...
AZURE_RESOURCE_GROUP="$root_name"

# user assigned managed identity instead of system assigned so we can 
# should make one for READ and one for WRITE but this is just a demo
EVENTHUBS_ID_NAME="identity-$root_name"

EVENTHUBS_NAMESPACE="namespace-$root_name"
EVENTHUBS_NAMESPACE_AUTH_RULE="send-receive-$root_name"
EVENTHUBS_HUB_NAME_DATA="$root_name-data-1"
EVENTHUBS_HUB_NAME_SUCCESS="$root_name-success-1"
EVENTHUBS_HUB_NAME_FAIL="$root_name-failure-1"
EVENTHUBS_HUB_AUTH_RULE="send-receive-$root_name"

