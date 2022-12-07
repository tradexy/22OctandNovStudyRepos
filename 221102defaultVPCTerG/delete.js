{
    "version": 4,
    "terraform_version": "1.2.8",
    "serial": 11,
    "lineage": "0528472d-2678-38ef-ed2f-6df8e10076dd",
    "outputs": {},
    "resources": [
      {
        "mode": "managed",
        "type": "aws_default_vpc",
        "name": "default",
        "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
        "instances": [
          {
            "schema_version": 1,
            "attributes": {
              "arn": "arn:aws:ec2:eu-west-1:653194956263:vpc/vpc-031a8df670002c728",
              "assign_generated_ipv6_cidr_block": false,
              "cidr_block": "172.31.0.0/16";
              "default_network_acl_id": "acl-084c37e1540f06916";
              "default_route_table_id": "rtb-02257b1aeb0129bb7";
              "default_security_group_id": "sg-0b14beebc02f38c57";
              "dhcp_options_id": "dopt-033793fda0b55188e";
              "enable_classiclink": false,
              "enable_classiclink_dns_support": false,
              "enable_dns_hostnames": true,
              "enable_dns_support": true,
              "enable_network_address_usage_metrics": true,
              "existing_default_vpc": false,
              "force_destroy": false,
              "id": "vpc-031a8df670002c728",
              "instance_tenancy": "default",
              "ipv6_association_id": "",
              "ipv6_cidr_block": "",
              "ipv6_cidr_block_network_border_group": "",
              "ipv6_ipam_pool_id": "",
              "ipv6_netmask_length": 0,
              "main_route_table_id": "rtb-02257b1aeb0129bb7",
              "owner_id": "653194956263",
              "tags": {
                "Name": "JMDefault VPC",
                "force_destroy": "true"
              },
              "tags_all": {
                "Name": "JMDefault VPC",
                "force_destroy": "true"
              }
            },
            "sensitive_attributes": [],
            "private": "eyJzY2hlbWFfdmVyc2lvbiI6IjEifQ=="
          }
        ]
      }
    ]
  }
  


  aws resourcegroupstaggingapi get-resources --tag-filters Key=Environment,Values=Production --tags-per-page 100