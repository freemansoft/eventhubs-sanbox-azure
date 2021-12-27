# Purpose
Create an eventhub sandbox that can be used for example programs. This project has provisioning and de-provisioning scripts. 

1. Create a resource group to hold everything we create
1. Create a user Assigned Identity that can be used to read and write EventHub data
1. Create an EventHubs namespace and three EventHub instances.
1. Create Shared Access signatures on namespace and eventhubs

# Using the AWS CLI
## Assumptions
* You have a default subscription set on the CLI
    * You logged in `az login`
    * Youi saw your available accounts `az account list`
    * You selected an account `az account set --subscription <subscription-id>`
    * You verified the current account `az account show`

## Creating Resources
Run these scripts in order. 

| Command | Purpose |
| - | - |
| 0-install-tools.sh | Install Azure CLI and jq rquired by these scripts |
| 1-login-az.sh | Log in so you have permissions to run the rest of the script operations | 
| 2-create-resources.sh | Create resources required for eventhubs: `ResourceGroup`, etc. via CLI |
| 3-xxx-create-identities.sh | **Obsoleted by ARM template** _replaced by _5-..._ Create `User Assigned Managed Identity` (UAMI) via CLI |
| 4-xxx-create-event-hubs.sh | **Obsolete by ARM template** _replaced by _5-..._ Creates `namespace` ,`event hubs` constructs down to the hubs themselves via CLI |
| 5-create-eventhubs-identities.sh | Creates the UMAI, `namespace`, `eventhubs`, `schema registry group` via _ARM template_.  Does not create UMAI role assignemnts |
| 6-create-namespace-identity-rbac.sh | Creates role assignments between `UMAI` and `namespace` via CLI |

## Deleting resources
Scripts that can delete resources created by this project

| Command | Purpose |
| ------- | ------- |
| 90-destroy-resource-group.sh | Remove this example by removing the resource group |
| 91-destroy-namespace.sh | Remove the namespace and eventhub (topics). Leaves the resource group  |

This project no longer creates dedicated clusters. They are expensive.
FYI...
* Eventhub clusters cannot be deleted until 4 hours after creation. The destroy-namespace script exists so that you can tear down and rebuild namespaces and individual hubs in a shorter iterative cycle.

# Kafka vs Event Hubs
| Kafka          |	Event Hubs |
| -------------- | ----------- |
| n/a            | Cluster |
| Cluster        | Namespace |
| Topic	         | Event Hub |
| Partition      |	Partition |
| Consumer Group |	Consumer Group |
| Offset         |	Offset |

* An EventHub `cluster` is an Azure provisioning and resource concept
* Creating an EventHubs `cluster` creates a dedicated cluster. **Do not do that** while experimenting experimentation

# Authorization
This project configures authorizaton for both Shared Access Signature (SAS) and Azure AD roles.

## Shared Access Signature
A SAS is essentially a shared secret that can be used as identity.  It is simple to use.  It can be used by anyone in posession in of the shared secret.  SAS management comes with all the revocation, renewal issues of a shared certificate.

The sample configures 
1. A Shared Access Signature on the namespace with MANGAGE SEND LISTEN permissions
1. A Shared Access Signature on the namespace with SEND LISTEN permissions _to be used by client that needs access to more than one eventhub_
1. A Shared Access Signature on the eventhubs with SEND permissions _to restrict send privs too individual topics_

## Azure Role Assignments
Authorizaton can be applied at the Namespace or the individual EventHub level.  Azure EventHubs have several built in roles that can be assigned at the _namespace_ or _eventhub_ level.   

Individual Service Principals or Assigned Identities can be assigned roles to a given resource, Namespace or Eventhub level. This program provides _reader_ and _writer_ permission the created _User Assigned Identity_ for to the example _namespace_.  Many organizations would do this with _Service Principals_ instead. We used _User Assigned Identities_ here because the operate well with Virtual Machines.

### Built in Azure Roles for EventHubs
Returned by `az role definition list` [Role Assignements docs](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-cli)
* `Azure Event Hubs Data Receiver`
* `Azure Event Hubs Data Sender`

### Built in Azure Roles for Schema Registry
Returned as part of `az role definition list | grep "Schema Registry"` [Schema Registry RBAC](https://docs.microsoft.com/en-us/azure/event-hubs/schema-registry-overview#azure-role-based-access-control)
* `Schema Registry Reader (Preview)`
* `Schema Registry Writer (Preview)`

**By default your main azure account does not have permission to read and write schemas.**

# Azure Templates
The `resource-template` directory contains an arm template that was exported from a demo environment (built 8/21/2021). It eventhub scripts use it to create a deployment.
1. Create a resource group.
1. Deploy the `template.json` file into that resource group.  
1. Be patient.  It takes a few minutes to deploy all the components.

# References
* Author's blogs and videos
    * [Cloud Native and other Identities in Azure: Blog](http://joe.blog.freemansoft.com/2021/08/cloud-native-and-other-identities-in.html)
    * [Selecting the right Azure Identities : Video](https://youtu.be/-g7ZJLQNaWU)
    * [Managed Identities and Shared Access tokens for Azure EventHubs: Blot](http://joe.blog.freemansoft.com/2021/08/managed-identities-and-shared-access.html)
    * [IAM and Role Assignments in Azure EventHubs: Video](https://youtu.be/NJMf23Sg_JY)
* EventHubs
    * https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-for-kafka-ecosystem-overview
* Security
    * https://docs.microsoft.com/en-us/azure/event-hubs/authenticate-managed-identity?tabs=latest
    * https://docs.microsoft.com/en-us/azure/event-hubs/authorize-access-shared-access-signature
    * https://docs.microsoft.com/en-us/azure/event-hubs/authenticate-shared-access-signature
* Tutorals
    * https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-kafka-connect-tutorial
    * https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-quickstart-kafka-enabled-event-hubs
    * https://docs.microsoft.com/en-us/azure/developer/java/spring-framework/configure-spring-cloud-stream-binder-java-app-azure-event-hub
    * https://itnext.io/azure-event-hubs-role-based-access-control-in-action-2addd2dc31a3
