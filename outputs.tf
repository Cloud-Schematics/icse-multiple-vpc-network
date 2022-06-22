##############################################################################
# VPC Data
##############################################################################

output "networks" {
  description = "VPC network information"
  value = {
    for vpc in module.vpcs :
    (vpc.vpc_name) => {
      id               = vpc.vpc_id
      crn              = vpc.vpc_crn
      name             = vpc.vpc_name
      subnet_zone_list = vpc.subnet_zone_list
      network_acls     = vpc.network_acls
      public_gateways  = vpc.public_gateways
      security_groups  = vpc.security_groups
      vpn_gateway      = vpc.vpn_gateway
    }
  }
}

##############################################################################

##############################################################################
# Security Groups
##############################################################################

output "security_groups" {
  description = "List of security group names and ids"
  value       = [
    for group in module.security_groups:
    group.groups
  ]
}

##############################################################################

##############################################################################
# JSON Config
##############################################################################

output "json" {
  description = "JSON formatted environment configuration"
  value       = data.external.format_output.result
}

##############################################################################