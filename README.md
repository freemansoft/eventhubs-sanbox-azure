

## Createing Resources
| Command | Purpose |
| - | - |
| 0-install-tools.sh | Install Azure CLI and jq rquired by these scripts |
| 1-create-resources.sh | Create resources required for eventhubs: resource groups, etc. |
| 2-create-event-hubs.sh | Creates all the `event hubs` constructs down to the hubs themselves |

## Deleting resources
Eventhub clusters cannot be deleted until 4 hours after creation.
| Command | Purpose |
| - | - |
| 10-destroy-resource-group.sh | Remove this example by removing the resource group |
| 11-destron-namespace.sh | Remove the namespace and eventhub (topics). Leaves the resource group and cluster |

## Kafka vs Event Hubs
| Kafka |	Event Hubs |
| - | - |
| n/a | Cluster |
| Cluster | Namespace |
| Topic	 | Event Hub |
| Partition |	Partition |
| Consumer Group |	Consumer Group |
| Offset |	Offset |

An EventHub `cluster` is an Azure provisioning and resource concept

## Authorization
This project configures authorizaton for both Shared Access Signature (SAS) and Azure AD roles.

### Shared Access Signature
A SAS is essentially a shared secret that can be used as identity.  It is simple to use.  It can be used by anyone in posession in of the shared secret.  SAS management comes with all the revocation, renewal issues of a shared certificate.

### Azure Role Assignments
Authorizaton can be applied at the Namespace or the individual EventHub level.  Azure EventHubs have several built in roles that can be assigned at the _namespace_ or _eventhub_ level.   

Individual Service Principals or Assigned Identities can be assigned roles to a given resource, Namespace or Eventhub level. This program provides _reader_ and _writer_ permission the created _User Assigned Identity_ for to the example _namespace_.  Many organizations would do this with _Service Principals_ instead. We used _User Assigned Identities_ here "just because we could".

#### Built in Azure Roles for EventHubs
Returned by `az role definition list` [Role Assignements docs](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-cli)
* `Azure Event Hubs Data Receiver`
* `Azure Event Hubs Data Sender`

## References
EventHubs 
    * https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-for-kafka-ecosystem-overview
* Security
    * https://docs.microsoft.com/en-us/azure/event-hubs/authenticate-managed-identity?tabs=latest
    * https://docs.microsoft.com/en-us/azure/event-hubs/authorize-access-shared-access-signature
    * https://docs.microsoft.com/en-us/azure/event-hubs/authenticate-shared-access-signature
* Tutoriials
    * https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-kafka-connect-tutorial
    * https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-quickstart-kafka-enabled-event-hubs
    * https://docs.microsoft.com/en-us/azure/developer/java/spring-framework/configure-spring-cloud-stream-binder-java-app-azure-event-hub
    * https://itnext.io/azure-event-hubs-role-based-access-control-in-action-2addd2dc31a3
