# IBM Cloud Solution Engineering Multiple VPC Network

Create multiple VPC networks in a single region connected with a transit gateway.

---

## Table of Contents

1. [Template Level Variables](#template-level-variables)
2. [VPC](#vpc)
    - [VPC Variable](#vpc-variable)
3. [Security Groups](#security-groups)
4. [Transit Gateway](#transit-gateway)
5. [Fail States](#fail-states)
6. [Outputs](#outputs)

---

## Template Level Variables

The following variables are used for all components created by this template:

Name             | Type         | Description                                                            | Sensitive | Default
---------------- | ------------ | ---------------------------------------------------------------------- | --------- | -------
ibmcloud_api_key | string       | The IBM Cloud platform API key needed to deploy IAM enabled resources. | true      | 
region           | string       | The region to which to deploy the VPC                                  |           | 
prefix           | string       | The prefix that you would like to append to your resources             |           | 
tags             | list(string) | List of Tags for the resource created                                  |           | null

---

## VPCs

This template can create one or more VPCs in a single region. This module uses the [vpc_module](./vpc) to create VPC network components. VPC Configurations are created using the [vpcs variable](./variables.tf#L35).

### VPC Variable

```terraform
  type = list(
    object({
      prefix                      = string           # VPC prefix
      resource_group              = optional(string) # Name of the resource group where VPC will be created
      use_manual_address_prefixes = optional(bool)   # Assign CIDR prefixes manually
      classic_access              = optional(bool)   # Allow classic access
      default_network_acl_name    = optional(string) # Rename default network ACL
      default_security_group_name = optional(string) # Rename default security group
      default_security_group_rules = optional(       # Add rules to default VPC security group
        list(
          object({
            name      = string # Name of security group rule
            direction = string # Can be `inbound` or `outbound`
            remote    = string # CIDR Block or IP for traffic to allow
            ##############################################################################
            # One or none of these optional blocks can be added
            # > if none are added, rule will be for any type of traffic
            ##############################################################################
            tcp = optional(
              object({
                port_max = optional(number)
                port_min = optional(number)
              })
            )
            udp = optional(
              object({
                port_max = optional(number)
                port_min = optional(number)
              })
            )
            icmp = optional(
              object({
                type = optional(number)
                code = optional(number)
              })
            )
          })
        )
      )
      default_routing_table_name = optional(string) # Default Routing Table Name
      address_prefixes = optional(                  # Address prefix CIDR subnets by zone 
        object({
          zone-1 = optional(list(string))
          zone-2 = optional(list(string))
          zone-3 = optional(list(string))
        })
      )
      network_acls = list(
        object({
          name              = string                 # Name of the ACL. The value of `var.prefix` will be prepended to this name
          add_cluster_rules = optional(bool)         # Dynamically create cluster allow rules
          resource_group_id = optional(string)       # ID of the resource group where the ACL will be created
          tags              = optional(list(string)) # List of tags for the ACL
          rules = list(
            object({
              name        = string # Rule Name
              action      = string # Can be `allow` or `deny`
              destination = string # CIDR for traffic destination
              direction   = string # Can be `inbound` or `outbound`
              source      = string # CIDR for traffic source
              # Any one of the following blocks can be used to create a TCP, UDP, or ICMP rule
              # to allow all kinds of traffic, use no blocks
              tcp = optional(
                object({
                  port_max        = optional(number)
                  port_min        = optional(number)
                  source_port_max = optional(number)
                  source_port_min = optional(number)
                })
              )
              udp = optional(
                object({
                  port_max        = optional(number)
                  port_min        = optional(number)
                  source_port_max = optional(number)
                  source_port_min = optional(number)
                })
              )
              icmp = optional(
                object({
                  type = optional(number)
                  code = optional(number)
                })
              )
            })
          )
        })
      )
      # Use public gateways in VPC by zone
      use_public_gateways = object({
        zone-1 = optional(bool)
        zone-2 = optional(bool)
        zone-3 = optional(bool)
      })
      # Subnets by zone
      subnets = object({
        zone-1 = list(object({
          name           = string
          cidr           = string
          public_gateway = optional(bool)
          acl_name       = string
        }))
        zone-2 = list(object({
          name           = string
          cidr           = string
          public_gateway = optional(bool)
          acl_name       = string
        }))
        zone-3 = list(object({
          name           = string
          cidr           = string
          public_gateway = optional(bool)
          acl_name       = string
        }))
      })
      vpn_gateway = object({
        use_vpn_gateway = bool             # create vpn gateway
        name            = optional(string) # gateway name
        subnet_name     = optional(string) # Do not include prefix, use same name as in `var.subnets`
        mode            = optional(string) # Can be `route` or `policy`. Default is `route`
        connections = optional(list(
          object({
            peer_address   = string
            preshared_key  = string
            local_cidrs    = optional(list(string))
            peer_cidrs     = optional(list(string))
            admin_state_up = optional(bool)
          })
        ))
      })
    })
  )
```

### Additional Resources

- [Getting started with VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-getting-started)

---

## Security Groups

Any number of additional security groups and rules can be created using the [security_groups variable](./variables.tf#L168). These security groups will be created in the VPC resource group.

```terraform
variable "security_groups" {
  description = "Security groups for VPC"
  type = list(
    object({
      name           = string           # Name
      resource_group = optional(string) # Name of existing resource group to use for security groups
      vpc_name       = string           # Name of VPC where security groups will be added.
      rules = list(                     # List of rules
        object({
          name      = string # name of rule
          direction = string # can be inbound or outbound
          remote    = string # ip address to allow traffic from
          ##############################################################################
          # One or none of these optional blocks can be added
          # > if none are added, rule will be for any type of traffic
          ##############################################################################
          tcp = optional(
            object({
              port_max = number
              port_min = number
            })
          )
          udp = optional(
            object({
              port_max = number
              port_min = number
            })
          )
          icmp = optional(
            object({
              type = number
              code = number
            })
          )
        })
      )
    })
  )
  ...
}
```

This template uses the [VPC Security Group Module](https://github.com/Cloud-Schematics/vpc-security-group-module) to create security groups and security group rules.

### Additional Resources

- [Using VPC Security Groups](https://cloud.ibm.com/docs/vpc?topic=vpc-using-security-groups)

--- 

## Transit Gateway

This template can optionally be used to create a transit gateway and use it to connect VPCs created in this template. The following variables are used in the creation of a transit gateway:

Name                           | Type         | Description                                                                       | Sensitive | Default
------------------------------ | ------------ | --------------------------------------------------------------------------------- | --------- | --------------------------
enable_transit_gateway         | bool         | Create transit gateway                                                            |           | true
transit_gateway_resource_group | string       | Name of existing resource group to use                                            |           | Default
transit_gateway_connections    | list(string) | Transit gateway vpc connections. Will only be used if transit gateway is enabled. |           | ["management", "workload"]

---

## Fail States

This template uses local values and the terraform `regex` function to force the template to fail if the environment cannot correctly be compiled. The template will fail under the following circumstances:

- The subnet defined within a VPN gateway is not defined within the VPC where it will be provisoned
- The name of a subnet ACL is not found withing the VPC where it will be provisioned
- Additional security groups will fail if the VPC name provided is not found with `var.vpcs`
- The name of any network to be attached to to the Transit Gateway is not found within `var.vpcs`

---

## Outputs

The following are outputs of the template.

### `networks` Output

For each network an object is created in the `networks` output that contains the following data:
  - VPC ID
  - VPC CRN
  - VPC Name
  - Subnet Zone List
  - Network ACLs
  - Public Gateways
  - Security Groups
  - VPN Gateways

### `security_groups` Output

Contains a list of security groups and IDs for those groups

### JSON Config

Show a list of resources created by this template in JSON format.