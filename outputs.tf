##############################################################################
# VPC Data
##############################################################################

output "networks" {
  description = "VPC network information"
  value = {
    for vpc in var.vpcs :
    (vpc.prefix) => {
      id               = module.vpcs[vpc.prefix].vpc_id
      crn              = module.vpcs[vpc.prefix].vpc_crn
      name             = module.vpcs[vpc.prefix].vpc_name
      subnet_zone_list = module.vpcs[vpc.prefix].subnet_zone_list
      network_acls     = module.vpcs[vpc.prefix].network_acls
      public_gateways  = module.vpcs[vpc.prefix].public_gateways
      security_groups  = module.vpcs[vpc.prefix].security_groups
      vpn_gateway      = module.vpcs[vpc.prefix].vpn_gateway
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