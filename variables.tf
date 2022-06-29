##############################################################################
# Template Level Variables
##############################################################################

variable "region" {
  description = "The region to which to deploy the VPC"
  type        = string
}

variable "prefix" {
  description = "The prefix that you would like to append to your resources"
  type        = string
}

variable "tags" {
  description = "List of Tags for the resource created"
  type        = list(string)
  default     = null
}

variable "use_resource_group_ids" {
  description = "OPTIONAL - Use resource group IDs passed in from a parent module."
  type        = string
  default     = false
}

##############################################################################

##############################################################################
# VPC Variables
##############################################################################

variable "vpcs" {
  description = "A map describing VPCs to be created in this repo."
  type = list(
    object({
      prefix                      = string           # VPC prefix
      resource_group              = optional(string) # Name of the group where VPC will be created
      use_manual_address_prefixes = optional(bool)
      classic_access              = optional(bool)
      default_network_acl_name    = optional(string)
      default_security_group_name = optional(string)
      default_security_group_rules = optional(
        list(
          object({
            name      = string
            direction = string
            remote    = string
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
      default_routing_table_name = optional(string)
      flow_logs_bucket_name      = optional(string)
      address_prefixes = optional(
        object({
          zone-1 = optional(list(string))
          zone-2 = optional(list(string))
          zone-3 = optional(list(string))
        })
      )
      network_acls = list(
        object({
          name              = string
          add_cluster_rules = optional(bool)
          rules = list(
            object({
              name        = string
              action      = string
              destination = string
              direction   = string
              source      = string
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
      use_public_gateways = object({
        zone-1 = optional(bool)
        zone-2 = optional(bool)
        zone-3 = optional(bool)
      })
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
  default = []
}


##############################################################################

##############################################################################
# Security Group Variables
##############################################################################

variable "security_groups" {
  description = "Security groups for VPC"
  type = list(
    object({
      name           = string
      vpc_name       = string
      resource_group = optional(string)
      rules = list(
        object({
          name      = string
          direction = string
          remote    = string
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

  default = []

  validation {
    error_message = "Each security group rule must have a unique name."
    condition = length(var.security_groups) == 0 ? true : length([
      for security_group in var.security_groups :
      true if length(distinct(security_group.rules.*.name)) != length(security_group.rules.*.name)
    ]) == 0
  }

  validation {
    error_message = "Security group rules can only use one of the following blocks: `tcp`, `udp`, `icmp`."
    condition = length(var.security_groups) == 0 ? true : length(
      # Ensure length is 0
      [
        # For each group in security groups
        for group in var.security_groups :
        # Return true if length isn't 0
        true if length(
          distinct(
            flatten([
              # For each rule, return true if using more than one `tcp`, `udp`, `icmp block
              for rule in group.rules :
              true if length([for type in ["tcp", "udp", "icmp"] : true if lookup(rule, type, null) != null]) > 1
            ])
          )
        ) != 0
      ]
    ) == 0
  }

  validation {
    error_message = "Security group rule direction can only be `inbound` or `outbound`."
    condition = length(var.security_groups) == 0 ? true : length(
      [
        for group in var.security_groups :
        true if length(
          distinct(
            flatten([
              for rule in group.rules :
              false if !contains(["inbound", "outbound"], rule.direction)
            ])
          )
        ) != 0
      ]
    ) == 0
  }

}

##############################################################################

##############################################################################
# Transit Gateway Variables
##############################################################################

variable "enable_transit_gateway" {
  description = "Create transit gateway"
  type        = bool
  default     = true
}

variable "transit_gateway_resource_group" {
  description = "Name of existing resource group to use"
  type        = string
  default     = "Default"
}

variable "transit_gateway_connections" {
  description = "Transit gateway vpc connections. Will only be used if transit gateway is enabled."
  type        = list(string)
  default     = ["management", "workload"]
}

#############################################################################