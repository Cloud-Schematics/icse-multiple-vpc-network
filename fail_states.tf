
##############################################################################
#                                                                            #
#                         Configuration Fail States                          #
#                                                                            #
##############################################################################


##############################################################################
# Fail if Gateway Subnet not found in VPC
##############################################################################

locals {
  # Match length of subnets found and test if equal to length of vpc with vpn_gateway enabled
  vpc_subnets_contain_vpn_gateway = length(
    flatten([
      # for each network if vpn_gateway is enabled
      for network in var.vpcs :
      [
        # for each zone
        for zone in ["zone-1", "zone-2", "zone-3"] :
        # return true if the subnet is contained within that zone
        true if contains(network.subnets[zone].*.name, network.vpn_gateway.subnet_name)
      ] if network.vpn_gateway.use_vpn_gateway == true
    ])
    ) == length(
    flatten(
      [
        for network in var.vpcs :
        true if network.vpn_gateway.use_vpn_gateway == true
      ]
    )
  )
  fail_if_gateway_subnet_not_found_in_vpc = regex("true", local.vpc_subnets_contain_vpn_gateway)
}

##############################################################################

##############################################################################
# Fail if network ACL not found in VPC
##############################################################################

locals {
  vpc_network_acl_list = {
    for network in var.vpcs :
    (network.prefix) => network.network_acls.*.name
  }
  subnets_contain_valid_acls = length(
    flatten([
      for network in var.vpcs :
      [
        for zone in ["zone-1", "zone-2", "zone-3"] :
        [
          for subnet in network.subnets[zone] :
          false if subnet.acl_name == null ? false : !contains(local.vpc_network_acl_list[network.prefix], subnet.acl_name)
        ]
      ]
    ])
  ) == 0
  fail_if_subnet_acl_name_not_found = regex("true", local.subnets_contain_valid_acls)
}

##############################################################################

##############################################################################
# Fail if Security Group VPC not found in VPC
##############################################################################

locals {
  vpc_network_list = var.vpcs.*.prefix
  security_groups_contains_valid_vpc_names = length(
    [
      for group in var.security_groups :
      true if !contains(local.vpc_network_list, group.vpc_name)
    ]
  ) == 0
  fail_if_security_group_vpc_name_not_found = regex("true", local.security_groups_contains_valid_vpc_names)
}

##############################################################################

##############################################################################
# Fail if Transit Gateway Connection VPC not found in VPC
##############################################################################

locals {
  transit_gateway_valid_vpc_names = length([
    for connection in var.transit_gateway_connections :
    true if !contains(local.vpc_network_list, connection)
  ]) == 0
  fail_if_transit_gateway_vpc_name_not_found = regex("true", local.transit_gateway_valid_vpc_names)
}

##############################################################################