# AWS CloudGuard IaaS Transit Gateway Demonstration 
*routes not fully working yet*
Terraform scripts for transit gateway demonstration of CloudGuard in AWS 
Uses R80.40 HA Geo Gateway cluster (EA)
Requires an external manager R80.40 

Builds the complete environment with web and application servers, northbound and southbound e-w hubs 

---------------------------------------------------------------
One time preparation of the AWS account 
1.	Create or choose a ssh key-pair in the account for the DC you are using
2.	Subscribe to the ELUAs for R80.30 BYOL gateway and management 
    R80.20 R80.30 R80.40 management 
    https://aws.amazon.com/marketplace/pp/B07KSBV1MM?qid=1558349960795&sr=0-4&ref_=srh_res_product_title

    R80.20 R80.30 Gateway
    https://aws.amazon.com/marketplace/pp/B07LB3YN9P?qid=1558349960795&sr=0-5&ref_=srh_res_product_title

3.	Create IAM access keys for the API login (for terraform) and save into credentials 
    #  shared_credentials_file = "~/.aws/credentials"  (linux)
    #  shared_credentials_file = "%USERPROFILE%\.aws\credentials"  (windows)
4.  Ensure you have enough resources in the account, this script creates 6 VPC, 1 transit gateway and 12 instances, the cost for this will be a few dollars per hour, so it is recommended to destroy the resources when not using them  

----------------------------------------------------------------

One time preparation of the Terraform scripts\
Works with terraform v0.11.13 not 0.12.x https://github.com/hashicorp/terraform/issues/21170
1. Modify the variables.tf to suite your needs   
2. Run terraform init  

------------------------------------------------------------------

Solution Documentation   TBA

The terraform script deploys these 3 CloudFormation templates with all the glue to configure them  
  template_url        =   

TGW documentation (Outbound cluster)  


Modules  
  checkpoint.tf   - Contains the CFT for the gateways and manager\
  tgw.tf\
  instances.tf\
  subnets.tf\
  vpc.tf\
  routes.tf\
  external_nlb.tf\
  external_alb.tf\
  internal_lb.tf        - app1\
  internal_lb_app2.tf   - app2\
  variables.tf\
  route53.tf        - Optional, delete if R53 is not used  

-------------------------------------------------------------------

To run the script  
    terraform init  
    terraform apply  

You can Logon after about 30 mins to the manager via the windows based Check Point SmartDashboard

To remove the environment  
    terraform destroy 

