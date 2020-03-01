##########################################
############# Management #################
##########################################

# Deploy CP Management cloudformation template - sk130372
/*
resource "aws_cloudformation_stack" "checkpoint_Management_cloudformation_stack" {
  name = "${var.project_name}-Management"

  parameters {
    VPC                     = "${aws_vpc.management_vpc.id}"
    Subnet                  = "${aws_subnet.management_subnet.id}" 
    Version                 = "${var.cpversion}-BYOL"
    InstanceType            = "${var.management_server_size}"
    Name                    = "${var.project_name}-Management" 
    KeyName                 = "${var.key_name}"
    PasswordHash            = "${var.password_hash}"
    Shell                   = "/bin/bash"
    Permissions             = "Create with read-write permissions"
    BootstrapScript         = <<BOOTSTRAP
echo '
cloudguard on ;
sed -i '/template_name/c\\${var.outbound_configuration_template_name}: autoscale-2-nic-management' /etc/cloud-version ;
/opt/CPcme/bin/config-community ${var.vpn_community_name} ;
mgmt_cli -r true set access-rule layer Network rule-number 1 action "Accept" track "Log" ;
mgmt_cli -r true add access-layer name "Inline" ;
mgmt_cli -r true set access-rule layer Inline rule-number 1 action "Accept" track "Log" ;
mgmt_cli -r true add access-rule layer Network position 1 name "${var.vpn_community_name} VPN Traffic Rule" vpn.directional.1.from ${var.vpn_community_name} vpn.directional.1.to ${var.vpn_community_name} vpn.directional.2.from ${var.vpn_community_name} vpn.directional.2.to External_clear action "Apply Layer" inline-layer "Inline" ;
mgmt_cli -r true add nat-rule package standard position bottom install-on "Policy Targets" original-source All_Internet translated-source All_Internet method hide ;
autoprov-cfg -f init AWS -mn ${var.template_management_server_name} -tn ${var.outbound_configuration_template_name} -cn tgw-controller -po Standard -otp ${var.sic_key} -r ${var.region} -ver ${var.cpversion} -iam -dt TGW ;
autoprov-cfg -f set controller AWS -cn tgw-controller -slb ;
autoprov-cfg -f set controller AWS -cn tgw-controller -sg -sv -com ${var.vpn_community_name} ;
autoprov-cfg -f set template -tn ${var.outbound_configuration_template_name} -vpn -vd "" -con ${var.vpn_community_name} ;
autoprov-cfg -f set template -tn ${var.outbound_configuration_template_name} -ia -ips -appi -av -ab ;
autoprov-cfg -f add template -tn ${var.inbound_configuration_template_name} -otp ${var.sic_key} -ver ${var.cpversion} -po Standard -ia -ips -appi -av -ab ;
' > /etc/cloud-setup.sh ;
chmod +x /etc/cloud-setup.sh ;
/etc/cloud-setup.sh > /var/log/cloud-setup.log ;
BOOTSTRAP
}

  template_url        = "https://s3.amazonaws.com/CloudFormationTemplate/management.json"
  capabilities        = ["CAPABILITY_IAM"]
  disable_rollback    = true
  timeout_in_minutes  = 50
}
*/
##########################################
########### Geo-Outbound HA ################
##########################################

# Deploy CP TGW Geo cloudformation template
resource "aws_cloudformation_stack" "checkpoint_tgw_cloudformation_stack" {
  name = "${var.project_name}-Outbound"

  parameters {
    VpcCidr                                     = "${var.outbound_cidr_vpc}"
    AvailabilityZones                           = "${join(", ", data.aws_availability_zones.azs.names)}"
    # NumberOfAZs                                 = "${length(data.aws_availability_zones.azs.names)}"
    PublicSubnetCidrA                           = "${cidrsubnet(var.outbound_cidr_vpc, 8, 0)}"
    PublicSubnetCidrB                           = "${cidrsubnet(var.outbound_cidr_vpc, 8, 32)}" 
    PrivateSubnetCidrA                          = "${cidrsubnet(var.outbound_cidr_vpc, 8, 64)}" 
    PrivateSubnetCidrB                          = "${cidrsubnet(var.outbound_cidr_vpc, 8, 98)}" 
    TgwHASubnetCidrA                            = "${cidrsubnet(var.outbound_cidr_vpc, 8, 130)}" 
    TgwHASubnetCidrB                            = "${cidrsubnet(var.outbound_cidr_vpc, 8, 162)}" 
    NamePrefix                                  = "Geo-"
    InstanceType                                = "${var.outbound_asg_server_size}"
    KeyName                                     = "${var.key_name}"
    EnableInstanceConnect                       = "true"
    AllocatePublicAddress                       = "true"
    License                                      = "${var.cpversion}-BYOL"
    Shell                                        = "/bin/bash"
    PasswordHash                        = "${var.password_hash}"
    SICKey                                 = "${var.sic_key}"

 }
  template_url        = "https://cloudformationstaging.s3.amazonaws.com/checkpoint-tgw-ha-master.yaml"
#  template_url        = "https://s3.amazonaws.com/CloudFormationTemplate/checkpoint-tgw-asg-master.yaml"
  capabilities        = ["CAPABILITY_IAM"]
  disable_rollback    = true
  timeout_in_minutes  = 50
}
# https://cloudformationstaging.s3.amazonaws.com/geo-cluster-into-vpc.yaml
# https://cloudformationstaging.s3.amazonaws.com/geo-cluster.yaml
# https://cloudformationstaging.s3.amazonaws.com/checkpoint-tgw-ha-master.yaml
# https://cloudformationstaging.s3.amazonaws.com/checkpoint-tgw-ha.yaml
