this tutorial steps below, first chartsd..
to see in Flowchart use gitbash / bash use commands:
terraform plan -out=plan.out
terraform show -json plan.out > plan.json
then upload here: https://hieven.github.io/terraform-visual/

https://github.com/hieven/terraform-visual

----------------
To create FLOWCHART using terraform:
see https://developer.hashicorp.com/terraform/cli/commands/graph
followed yt https://www.youtube.com/watch?v=JVFn1IgZLY0

1. install graphviz as admin
    choco install graphviz
2. on command use: 
terraform graph | dot -Tsvg > graph.svg
terraform graph -type=plan-destroy | dot -Tsvg > graph1.svg


TO LIST RESOURCES USING AWS CLI:
aws resourcegroupstaggingapi get-resources --region=us-east-1 --tags-per-page 100
aws resourcegroupstaggingapi get-resources --tags-per-page 100
aws resourcegroupstaggingapi get-resources --tag-filters Key=Environment,Values=Production --tags-per-page 100
aws resourcegroupstaggingapi get-resources --region eu-west-1 --output json

use this to inspect - carefully -- aws resourcegroupstaggingapi get-resources --region eu-west-1 --output json

To NUKE:
steps taken in mini pc - personal
in home/tradexy
using ubuntu wsl2
follow steps https://github.com/gruntwork-io/cloud-nuke
after nuking all, everything is destroyed, log back into console using root account.
prodivde admin access to previously created user account (i.e. tradexydev), provide console access and re-set password (note, can use previous password).
On cli, will need to do:
aws configure
then create and provide new AWS Access Key and AWS Secret Key (and i.e. us-east-1 and json as per usual)
p.s. Installation git cloned in this folder no needed as part of the steps - as just needed the 1 file.


_____________________________________________________________________

STEPS FOR THIS PROJECT
region ap-south-1 - REMEMBER TO EDIT ORIGINAL FOLDER AND DELETE KEY IF NEED BE IN US-EAST-1
create/use region key .pem, use to create https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html 
save key in this folder and run terraform init, plan and apply


# AWS_3tier_architecture_terraform

Infrastructure Automation | Deploying a 3-Tier Architecture in AWS Using Terraform

The three-tier architecture is the most popular implementation of a multi-tier architecture and consists of a single presentation tier, logic tier, and data tier.

It is a viable choice for software projects to be started quickly.
aws_3tier_architecture_terraform

### Video Tutorial:

Part1 - https://youtu.be/B3BtmyBetQo

Part2 - https://youtu.be/kpoUeBkHoSc

Part3 - https://youtu.be/Nz6pKARM5W0

### Resources need to be created / installed :

* Custom VPC

* 2 Subnets (Public)

* 1 Subnet (Private)

* 2 EC2 Instances

* Security Group

* Elastic IP

* NAT Gateway

* Internet Gateway

* Route Table

* Application Load Balancer

* Apache Webserver

* MySQL DB

![Screenshot 2022-06-28 at 9 44 37 AM](https://user-images.githubusercontent.com/58227542/176114794-94145c12-982d-4fab-9b14-64f9c0faf6ac.png)

![Screenshot 2022-06-28 at 7 57 51 AM](https://user-images.githubusercontent.com/58227542/176078468-3847bab0-e70e-4360-b077-181315ee007c.png)
