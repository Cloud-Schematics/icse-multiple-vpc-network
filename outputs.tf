##############################################################################
# VPC Data
##############################################################################

output "networks" {
  description = "VPC network information"
  value = {
    for vpc in var.vpcs :
    (vpc.prefix) => {
      id                = module.vpcs[vpc.prefix].vpc_id
      crn               = module.vpcs[vpc.prefix].vpc_crn
      name              = module.vpcs[vpc.prefix].vpc_name
      subnet_zone_list  = module.vpcs[vpc.prefix].subnet_zone_list
      network_acls      = module.vpcs[vpc.prefix].network_acls
      public_gateways   = module.vpcs[vpc.prefix].public_gateways
      security_groups   = module.vpcs[vpc.prefix].security_groups
      vpn_gateway       = module.vpcs[vpc.prefix].vpn_gateway
      resource_group_id = module.vpcs[vpc.prefix].vpc_resource_group_id
    }
  }
}

##############################################################################

##############################################################################
# Transit Gateway Outputs
##############################################################################

output transit_gateway_id {
  description = "ID of the transit gateway instance."
  value       = var.enable_transit_gateway == true ? ibm_tg_gateway.transit_gateway[0].id : null
}

##############################################################################

##############################################################################
# VPC Flow Logs List
##############################################################################

output "vpc_flow_logs_data" {
  description = "Information for Connecting VPC to flow logs using ICSE Flow Logs Module"
  value = [
    for vpc in var.vpcs :
    {
      flow_logs_bucket_name = vpc.flow_logs_bucket_name
      vpc_prefix            = vpc.prefix
      vpc_id                = module.vpcs[vpc.prefix].vpc_id
      resource_group_id     = module.vpcs[vpc.prefix].vpc_resource_group_id
    }
  ]
}

##############################################################################

##############################################################################
# Security Groups
##############################################################################

output "security_groups" {
  description = "List of security group names and ids"
  value = [
    for group in module.security_groups :
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