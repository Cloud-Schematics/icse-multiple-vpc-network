##############################################################################
# Create VPC Map
##############################################################################

module "vpc_map" {
  source         = "./config_modules/list_to_map"
  list           = var.vpcs
  key_name_field = "prefix"
}

##############################################################################


##############################################################################
# Resource Group where VPC Resources Will Be Created
##############################################################################

data "ibm_resource_group" "resource_group" {
  for_each = var.use_resource_group_ids ? toset([]) : toset(
    distinct(
      concat(var.vpcs.*.resource_group, [var.transit_gateway_resource_group])
    )
  )
  name = each.key
}

##############################################################################

##############################################################################
# VPCs
##############################################################################

module "vpcs" {
  source                       = "./vpc"
  for_each                     = module.vpc_map.value
  prefix                       = "${var.prefix}-${each.value.prefix}"
  region                       = var.region
  tags                         = var.tags
  resource_group_id            = var.use_resource_group_ids == true ? each.value.resource_group : data.ibm_resource_group.resource_group[each.value.resource_group].id
  classic_access               = each.value.classic_access
  default_network_acl_name     = each.value.default_network_acl_name
  default_security_group_name  = each.value.default_security_group_name
  default_security_group_rules = each.value.default_security_group_rules
  default_routing_table_name   = each.value.default_routing_table_name
  address_prefixes             = each.value.address_prefixes
  network_acls                 = each.value.network_acls
  use_public_gateways          = each.value.use_public_gateways
  subnets                      = each.value.subnets
  vpn_gateway                  = each.value.vpn_gateway
  use_manual_address_prefixes = each.value.use_manual_address_prefixes == true ? true : length([
    # If use manual address prefixes is not set check each zone
    for zone in ["zone-1", "zone-2", "zone-3"] :
    true if(
      each.value.address_prefixes[zone] == null        # if prefix is null
      ? false                                          # false
      : length(each.value.address_prefixes[zone]) == 0 # if the length of prefixes is 0
      ? false                                          # false
      : true                                           # if zone has more than one prefix set to true
    )                                                  # return true
  ]) != 0                                              # true if prefixes are being used, false if not
}

##############################################################################


##############################################################################
# Create Security Group Map
##############################################################################

module "security_group_map" {
  source = "./config_modules/list_to_map"
  list   = var.security_groups
}

##############################################################################

##############################################################################
# Security Groups
##############################################################################

module "security_groups" {
  source            = "github.com/Cloud-Schematics/vpc-security-group-module"
  for_each          = module.security_group_map.value
  prefix            = var.prefix
  tags              = var.tags
  security_groups   = [each.value]
  vpc_id            = module.vpcs[each.value.vpc_name].vpc_id
  resource_group_id = data.ibm_resource_group.resource_group[each.value.resource_group].id
}

##############################################################################

##############################################################################
# Config
##############################################################################

locals {
  env = {
    region                         = var.region
    prefix                         = var.prefix
    tags                           = var.tags
    vpcs                           = var.vpcs
    security_groups                = var.security_groups
    enable_transit_gateway         = var.enable_transit_gateway
    transit_gateway_resource_group = var.transit_gateway_resource_group
    transit_gateway_connections    = var.transit_gateway_connections
  }
  string = "\"${jsonencode(local.env)}\""
}

data "external" "format_output" {
  program = ["python3", "${path.module}/scripts/output.py", local.string]
}

##############################################################################