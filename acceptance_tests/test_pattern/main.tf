##############################################################################
# IBM Cloud API Key
##############################################################################

variable "ibmcloud_api_key" {
  description = "IBM api key"
  type        = string
}

##############################################################################

##############################################################################
# Module
##############################################################################

module "acceptance_tests" {
  source                         = "../.."
  ibmcloud_api_key               = var.ibmcloud_api_key
  region                         = "us-south"
  prefix                         = "icse-multi-vpc"
  tags                           = ["icse", "vpc"]
  enable_transit_gateway         = true
  transit_gateway_resource_group = "Default"
  transit_gateway_connections    = ["management", "workload"]
  vpcs = [
    {
      vpn_gateway = {
        use_vpn_gateway = false
      }
      address_prefixes = {
        zone-1 = [
          "10.5.0.0/16",
          "10.10.10.0/24",
          "10.10.30.0/24",
        ]
        zone-2 = [
          "10.6.0.0/16",
          "10.20.10.0/24",
        ]
        zone-3 = [
          "10.7.0.0/16",
          "10.30.10.0/24",
        ]
      }
      use_manual_address_prefixes  = true
      default_security_group_rules = []
      network_acls = [
        {
          add_cluster_rules = false
          name              = "management-acl"
          rules = [
            {
              action      = "allow"
              destination = "10.0.0.0/8"
              direction   = "inbound"
              name        = "allow-ibm-inbound"
              source      = "161.26.0.0/16"
              tcp = {
                port_max = null
                port_min = null
              }
            },
            {
              action      = "allow"
              destination = "10.0.0.0/8"
              direction   = "inbound"
              name        = "allow-all-network-inbound"
              source      = "10.0.0.0/8"
              tcp = {
                port_max = null
                port_min = null
              }
            },
            {
              action      = "allow"
              destination = "0.0.0.0/0"
              direction   = "outbound"
              name        = "allow-all-outbound"
              source      = "0.0.0.0/0"
              tcp = {
                port_max = null
                port_min = null
              }
            },
          ]
        },
        {
          add_cluster_rules = false
          name              = "bastion-acl"
          rules = [
            {
              action      = "allow"
              destination = "10.0.0.0/8"
              direction   = "inbound"
              name        = "allow-ibm-inbound"
              source      = "161.26.0.0/16"
              tcp = {
                port_max = null
                port_min = null
              }
            },
            {
              action      = "allow"
              destination = "10.0.0.0/8"
              direction   = "inbound"
              name        = "allow-all-network-inbound"
              source      = "10.0.0.0/8"
              tcp = {
                port_max = null
                port_min = null
              }
            },
            {
              action      = "allow"
              destination = "0.0.0.0/0"
              direction   = "outbound"
              name        = "allow-all-outbound"
              source      = "0.0.0.0/0"
              tcp = {
                port_max = null
                port_min = null
              }
            },
            {
              action      = "allow"
              destination = "10.0.0.0/8"
              direction   = "inbound"
              name        = "allow-bastion-443-inbound"
              source      = "0.0.0.0/0"
              tcp = {
                source_port_max = 443
                source_port_min = 443
              }
            },
          ]
        },
        {
          add_cluster_rules = false
          name              = "f5-external-acl"
          rules = [
            {
              action      = "allow"
              destination = "10.0.0.0/8"
              direction   = "inbound"
              name        = "allow-ibm-inbound"
              source      = "161.26.0.0/16"
              tcp = {
                port_max = null
                port_min = null
              }
            },
            {
              action      = "allow"
              destination = "10.0.0.0/8"
              direction   = "inbound"
              name        = "allow-all-network-inbound"
              source      = "10.0.0.0/8"
              tcp = {
                port_max = null
                port_min = null
              }
            },
            {
              action      = "allow"
              destination = "0.0.0.0/0"
              direction   = "outbound"
              name        = "allow-all-outbound"
              source      = "0.0.0.0/0"
              tcp = {
                port_max = null
                port_min = null
              }
            },
            {
              action      = "allow"
              destination = "10.0.0.0/8"
              direction   = "inbound"
              name        = "allow-f5-external-443-inbound"
              source      = "0.0.0.0/0"
              tcp = {
                port_max = 443
                port_min = 443
              }
            },
          ]
        },
      ]
      prefix         = "management"
      resource_group = "Default"
      subnets = {
        zone-1 = [
          {
            acl_name       = "bastion-acl"
            cidr           = "10.5.70.0/24"
            name           = "bastion-zone-1"
            public_gateway = true
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.5.60.0/24"
            name           = "f5-bastion-zone-1"
            public_gateway = null
          },
          {
            acl_name       = "f5-external-acl"
            cidr           = "10.5.40.0/24"
            name           = "f5-external-zone-1"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.5.30.0/24"
            name           = "f5-management-zone-1"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.5.50.0/24"
            name           = "f5-workload-zone-1"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.5.80.0/24"
            name           = "vpe-zone-1"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.10.30.0/24"
            name           = "vpn-zone-1"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.5.10.0/24"
            name           = "vpn-1-zone-1"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.5.20.0/24"
            name           = "vpn-2-zone-1"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.10.10.0/24"
            name           = "vsi-zone-1"
            public_gateway = null
          },
        ]
        zone-2 = [
          {
            acl_name       = "bastion-acl"
            cidr           = "10.6.70.0/24"
            name           = "bastion-zone-2"
            public_gateway = true
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.6.60.0/24"
            name           = "f5-bastion-zone-2"
            public_gateway = null
          },
          {
            acl_name       = "f5-external-acl"
            cidr           = "10.6.40.0/24"
            name           = "f5-external-zone-2"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.6.30.0/24"
            name           = "f5-management-zone-2"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.6.50.0/24"
            name           = "f5-workload-zone-2"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.6.80.0/24"
            name           = "vpe-zone-2"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.6.10.0/24"
            name           = "vpn-1-zone-2"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.6.20.0/24"
            name           = "vpn-2-zone-2"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.20.10.0/24"
            name           = "vsi-zone-2"
            public_gateway = null
          },
        ]
        zone-3 = [
          {
            acl_name       = "bastion-acl"
            cidr           = "10.7.70.0/24"
            name           = "bastion-zone-3"
            public_gateway = true
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.7.60.0/24"
            name           = "f5-bastion-zone-3"
            public_gateway = null
          },
          {
            acl_name       = "f5-external-acl"
            cidr           = "10.7.40.0/24"
            name           = "f5-external-zone-3"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.7.30.0/24"
            name           = "f5-management-zone-3"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.7.50.0/24"
            name           = "f5-workload-zone-3"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.7.80.0/24"
            name           = "vpe-zone-3"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.7.10.0/24"
            name           = "vpn-1-zone-3"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.7.20.0/24"
            name           = "vpn-2-zone-3"
            public_gateway = null
          },
          {
            acl_name       = "management-acl"
            cidr           = "10.30.10.0/24"
            name           = "vsi-zone-3"
            public_gateway = null
          },
        ]
      }
      use_public_gateways = {
        zone-1 = true
        zone-2 = true
        zone-3 = true
      }
    },
    {
      vpn_gateway = {
        use_vpn_gateway = true
        subnet_name     = "vsi-zone-1"
        name            = "gateway"
      }
      address_prefixes = {
        zone-1 = []
        zone-2 = []
        zone-3 = []
      }
      default_security_group_rules = []
      flow_logs_bucket_name        = "workload-bucket"
      network_acls = [
        {
          add_cluster_rules = false
          name              = "workload-acl"
          rules = [
            {
              action      = "allow"
              destination = "10.0.0.0/8"
              direction   = "inbound"
              name        = "allow-ibm-inbound"
              source      = "161.26.0.0/16"
              tcp = {
                port_max = null
                port_min = null
              }
            },
            {
              action      = "allow"
              destination = "10.0.0.0/8"
              direction   = "inbound"
              name        = "allow-all-network-inbound"
              source      = "10.0.0.0/8"
              tcp = {
                port_max = null
                port_min = null
              }
            },
            {
              action      = "allow"
              destination = "0.0.0.0/0"
              direction   = "outbound"
              name        = "allow-all-outbound"
              source      = "0.0.0.0/0"
              tcp = {
                port_max = null
                port_min = null
              }
            },
          ]
        },
      ]
      prefix         = "workload"
      resource_group = "asset-development"
      subnets = {
        zone-1 = [
          {
            acl_name       = "workload-acl"
            cidr           = "10.40.20.0/24"
            name           = "vpe-zone-1"
            public_gateway = null
          },
          {
            acl_name       = "workload-acl"
            cidr           = "10.40.10.0/24"
            name           = "vsi-zone-1"
            public_gateway = null
          },
        ]
        zone-2 = [
          {
            acl_name       = "workload-acl"
            cidr           = "10.50.20.0/24"
            name           = "vpe-zone-2"
            public_gateway = null
          },
          {
            acl_name       = "workload-acl"
            cidr           = "10.50.10.0/24"
            name           = "vsi-zone-2"
            public_gateway = null
          },
        ]
        zone-3 = [
          {
            acl_name       = "workload-acl"
            cidr           = "10.60.20.0/24"
            name           = "vpe-zone-3"
            public_gateway = null
          },
          {
            acl_name       = "workload-acl"
            cidr           = "10.60.10.0/24"
            name           = "vsi-zone-3"
            public_gateway = null
          },
        ]
      }
      use_public_gateways = {
        zone-1 = false
        zone-2 = false
        zone-3 = false
      }
    },
  ]
  security_groups = [
    {
      name           = "f5-management-sg"
      resource_group = "Default"
      rules = [
        {
          direction = "inbound"
          name      = "allow-1-inbound-22"
          remote    = "10.5.70.0/24"
          tcp = {
            port_max = "22"
            port_min = "22"
          }
        },
        {
          direction = "inbound"
          name      = "allow-1-inbound-443"
          remote    = "10.5.70.0/24"
          tcp = {
            port_max = "443"
            port_min = "443"
          }
        },
        {
          direction = "inbound"
          name      = "allow-2-inbound-22"
          remote    = "10.6.70.0/24"
          tcp = {
            port_max = "22"
            port_min = "22"
          }
        },
        {
          direction = "inbound"
          name      = "allow-2-inbound-443"
          remote    = "10.6.70.0/24"
          tcp = {
            port_max = "443"
            port_min = "443"
          }
        },
        {
          direction = "inbound"
          name      = "allow-3-inbound-22"
          remote    = "10.7.70.0/24"
          tcp = {
            port_max = "22"
            port_min = "22"
          }
        },
        {
          direction = "inbound"
          name      = "allow-3-inbound-443"
          remote    = "10.7.70.0/24"
          tcp = {
            port_max = "443"
            port_min = "443"
          }
        },
        {
          direction = "inbound"
          name      = "allow-ibm-inbound"
          remote    = "161.26.0.0/16"
          tcp = {
            port_max = null
            port_min = null
          }
        },
        {
          direction = "inbound"
          name      = "allow-vpc-inbound"
          remote    = "10.0.0.0/8"
          tcp = {
            port_max = null
            port_min = null
          }
        },
        {
          direction = "outbound"
          name      = "allow-vpc-outbound"
          remote    = "10.0.0.0/8"
          tcp = {
            port_max = null
            port_min = null
          }
        },
        {
          direction = "outbound"
          name      = "allow-ibm-tcp-53-outbound"
          remote    = "161.26.0.0/16"
          tcp = {
            port_max = "53"
            port_min = "53"
          }
        },
        {
          direction = "outbound"
          name      = "allow-ibm-tcp-80-outbound"
          remote    = "161.26.0.0/16"
          tcp = {
            port_max = "80"
            port_min = "80"
          }
        },
        {
          direction = "outbound"
          name      = "allow-ibm-tcp-443-outbound"
          remote    = "161.26.0.0/16"
          tcp = {
            port_max = "443"
            port_min = "443"
          }
        },
      ]
      vpc_name = "management"
    },
    {
      name           = "f5-external-sg"
      resource_group = "Default"
      rules = [
        {
          direction = "inbound"
          name      = "allow-inbound-443"
          remote    = "0.0.0.0/0"
          tcp = {
            port_max = "443"
            port_min = "443"
          }
        },
      ]
      vpc_name = "management"
    },
    {
      name           = "f5-workload-sg"
      resource_group = "Default"
      rules = [
        {
          direction = "inbound"
          name      = "allow-workload-subnet-1"
          remote    = "10.10.10.0/24"
          tcp = {
            port_max = "443"
            port_min = "443"
          }
        },
        {
          direction = "inbound"
          name      = "allow-workload-subnet-2"
          remote    = "10.20.10.0/24"
          tcp = {
            port_max = "443"
            port_min = "443"
          }
        },
        {
          direction = "inbound"
          name      = "allow-workload-subnet-3"
          remote    = "10.30.10.0/24"
          tcp = {
            port_max = "443"
            port_min = "443"
          }
        },
        {
          direction = "inbound"
          name      = "allow-workload-subnet-4"
          remote    = "10.40.10.0/24"
          tcp = {
            port_max = "443"
            port_min = "443"
          }
        },
        {
          direction = "inbound"
          name      = "allow-workload-subnet-5"
          remote    = "10.50.10.0/24"
          tcp = {
            port_max = "443"
            port_min = "443"
          }
        },
        {
          direction = "inbound"
          name      = "allow-workload-subnet-6"
          remote    = "10.60.10.0/24"
          tcp = {
            port_max = "443"
            port_min = "443"
          }
        },
        {
          direction = "inbound"
          name      = "allow-ibm-inbound"
          remote    = "161.26.0.0/16"
          tcp = {
            port_max = null
            port_min = null
          }
        },
        {
          name      = "allow-vpc-inbound"
          direction = "inbound"
          remote    = "10.0.0.0/8"
          tcp = {
            port_max = null
            port_min = null
          }
        },
        {
          direction = "outbound"
          name      = "allow-vpc-outbound"
          remote    = "10.0.0.0/8"
          tcp = {
            port_max = null
            port_min = null
          }
        },
        {
          direction = "outbound"
          name      = "allow-ibm-tcp-53-outbound"
          remote    = "161.26.0.0/16"
          tcp = {
            port_max = "53"
            port_min = "53"
          }
        },
        {
          direction = "outbound"
          name      = "allow-ibm-tcp-80-outbound"
          remote    = "161.26.0.0/16"
          tcp = {
            port_max = "80"
            port_min = "80"
          }
        },
        {
          direction = "outbound"
          name      = "allow-ibm-tcp-443-outbound"
          remote    = "161.26.0.0/16"
          tcp = {
            port_max = "443"
            port_min = "443"
          }
        },
      ]
      vpc_name = "management"
    },
    {
      name           = "f5-bastion-sg"
      resource_group = "Default"
      rules = [
        {
          direction = "inbound"
          name      = "allow-1-inbound-3023"
          remote    = "10.5.70.0/24"
          tcp = {
            port_max = "3025"
            port_min = "3023"
          }
        },
        {
          direction = "inbound"
          name      = "allow-1-inbound-3080"
          remote    = "10.5.70.0/24"
          tcp = {
            port_max = "3080"
            port_min = "3080"
          }
        },
        {
          direction = "inbound"
          name      = "allow-2-inbound-3023"
          remote    = "10.6.70.0/24"
          tcp = {
            port_max = "3025"
            port_min = "3023"
          }
        },
        {
          direction = "inbound"
          name      = "allow-2-inbound-3080"
          remote    = "10.6.70.0/24"
          tcp = {
            port_max = "3080"
            port_min = "3080"
          }
        },
        {
          direction = "inbound"
          name      = "allow-3-inbound-3023"
          remote    = "10.7.70.0/24"
          tcp = {
            port_max = "3025"
            port_min = "3023"
          }
        },
        {
          direction = "inbound"
          name      = "allow-3-inbound-3080"
          remote    = "10.7.70.0/24"
          tcp = {
            port_max = "3080"
            port_min = "3080"
          }
        },
      ]
      vpc_name = "management"
    },
    {
      name           = "bastion-vsi-sg"
      resource_group = "Default"
      rules = [
        {
          direction = "inbound"
          name      = "allow-ibm-inbound"
          remote    = "161.26.0.0/16"
          tcp = {
            port_max = null
            port_min = null
          }
        },
        {
          direction = "inbound"
          name      = "allow-vpc-inbound"
          remote    = "10.0.0.0/8"
          tcp = {
            port_max = null
            port_min = null
          }
        },
        {
          direction = "outbound"
          name      = "allow-vpc-outbound"
          remote    = "10.0.0.0/8"
          tcp = {
            port_max = null
            port_min = null
          }
        },
        {
          direction = "outbound"
          name      = "allow-ibm-tcp-53-outbound"
          remote    = "161.26.0.0/16"
          tcp = {
            port_max = "53"
            port_min = "53"
          }
        },
        {
          direction = "outbound"
          name      = "allow-ibm-tcp-80-outbound"
          remote    = "161.26.0.0/16"
          tcp = {
            port_max = "80"
            port_min = "80"
          }
        },
        {
          direction = "outbound"
          name      = "allow-ibm-tcp-443-outbound"
          remote    = "161.26.0.0/16"
          tcp = {
            port_max = "443"
            port_min = "443"
          }
        },
        {
          direction = "inbound"
          name      = "allow-inbound-443"
          remote    = "0.0.0.0/0"
          tcp = {
            port_max = "443"
            port_min = "443"
          }
        },
        {
          direction = "outbound"
          name      = "allow-all-outbound"
          remote    = "0.0.0.0/0"
          tcp = {
            port_max = null
            port_min = null
          }
        },
      ]
      vpc_name = "management"
    },
  ]
}

##############################################################################