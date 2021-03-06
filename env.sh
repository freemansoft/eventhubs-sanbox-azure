#!/bin/bash

# should set the subscription
AZURE_REGION="eastus"
#AZURE_SUBSCRIPTION=[to be filled]


# add version # to name  to avoid complications with soft-deleted keyvaults while testing
# keyvault deletes are soft deletes witha purgable recovery == 90 days 2021/07
root_name="FSIExample-EventHub"

# decided to not prefix the resource names with the resource type rg, ia, cl...
AZURE_RESOURCE_GROUP="$root_name-RG"

NOW_PUBLISHED_AT="$(date +%F-%T)"

# user assigned managed identity instead of system assigned so we can 
# should make one for READ and one for WRITE but this is just a demo
EVENTHUBS_IDENTITY_NAME="$root_name-identity"

EVENTHUBS_NAMESPACE="$root_name-namespace"
EVENTHUBS_NAMESPACE_AUTH_RULE_MANAGE="$root_name-manage"
EVENTHUBS_NAMESPACE_AUTH_RULE_CLIENT="$root_name-client"

EVENTHUBS_SCHEMA_GROUP="$root_name-schema-grp"

EVENTHUBS_HUB_NAME_DATA="$root_name-data-1"
EVENTHUBS_HUB_NAME_SUCCESS="$root_name-success-1"
EVENTHUBS_HUB_NAME_FAIL="$root_name-failure-1"
EVENTHUBS_HUB_AUTH_RULE="$root_name-send"

# Use git commands.  We know this is a git repo and that you had to use git to get it
# This should reall be the git tag but I don't tag in my demo repos
# long commit hash
COMMIT_HASH="$(git log -1 --format='%H')"
# short commit hash
COMMIT_HASH="$(git log --pretty=format:'%h' -n 1)"
CURRENT_BRANCH="$(git branch --show-current)"
CURRENT_REPO="$(basename $(git remote get-url origin) .git)"
VERSION=$CURRENT_REPO:$CURRENT_BRANCH:$COMMIT_HASH
# echo $VERSION
PROJECT="EventHubs IaC Example"
