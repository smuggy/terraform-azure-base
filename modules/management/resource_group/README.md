# Resource group

## Summary
Creates a user group, composing the resource group name from the input
parameters. The _location_ provided must be a valid Azure region.

### Inputs
| name | description | type | default | required |
|------|-------------|:----:|:-------:|:--------:|
| group | group to which the resource group belongs | string | - | Y |
| name | name within the group of the resource group | string | - | Y |
| location | azure region where the resource group is created | string | - | Y|

### Outputs
| name | description |
|------|-------------|
| id | resource group id |
| name | resource group name |
| location | location of the resource group |
