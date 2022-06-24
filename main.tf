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
  for_each = toset(
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
  resource_group_id            = data.ibm_resource_group.resource_group[each.value.resource_group].id
  use_manual_address_prefixes  = each.value.use_manual_address_prefixes == null ? false : each.value.use_manual_address_prefixes
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