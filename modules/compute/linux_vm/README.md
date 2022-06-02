# Linux Virtual Machine
## Summary
Create Linux virtual machine. This will create DNS entries for the instances. The
naming is determined by the following rule:

et r cp app sg st z sn

* **et** - Environment type, one of sandbox, dev, test, prod
* **r** - Region
* **cp** - Cloud provider, literal z for Azure
* **app** - Four letter application code
* **sg** - Server group
* **st** - Server type for the application
* **z** - Availability zone
* **sn** - Server number

So an instance name for a test application may be:`scztst01srv101`

### Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| rg_name | Resource group in which this instance will reside | string | - | Y |
| rg_location | Azure region of the resource group | string | - | Y |
| environment | Environment type for the instance type | string | sandbox | N |
| zone | Availability zone in which the instance will be created | string | - | Y |
| subnet | Subnet to which the nic will attach | string | - | Y |
| app | Application for the instance | string | - | Y|
| volume_size | List of volumes attached to the instance | list | [] | N |
| instance_size | Instance size of the VM | string | Standard_B1s | N |
| server_group | Server group number (environment number) | number | 1 | N |
| server_number | Server number within the group | number | 1 | N |
| ssh_public_key | Public ssh key for access | string | - | Y |
| server_type | Server type | string | srv | N |
| ami_id | AMI ID of the OS for the instance | string | '' | N |
| dns_rg_name | Resource group that DNS is in | string | - | Y |
| identity | Service principal attached to instances | list | [] | N |

### Outputs
| Name | Description |
|------|-------------|
| name | Instance name |
| nic_id | Network interface identifier |
| private_ip | Private IP address |
| public_ip | Public IP address |
