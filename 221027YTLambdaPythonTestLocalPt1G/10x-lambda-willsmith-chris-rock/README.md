# High Level steps for Implementation

## Pre-requisites:
    1. Install and configure AWS CLI
    2. Install Docker
    3. Install CDK
## Implementation:
    1. Create a Simple Lambda function that calls Twitter API.
    2. Create a Typescript project for Provisioning Infrastructure in AWS using CDK.
       1. Create a VPC with Private and Public Subnets
       2. Create an EC2 Instance
       3. Create an Event rule, that keep an eye on EC2 Instance for Shutdown and Termination alerts.
       4. Configure Lambda Function to trigger when even rule identifies the events Shutdown and Termination.
## Validation:
    1. First will do the validation in local desktop by runnig docker commands.
    2. Once we get the potential results from python script, we will be provisioning the infrastructure with a simple command called `cdk deploy` 
    3. Once provisioning is complete, then we validate the Lambda function by terminating EC2 Instance and watch for cloudwatch logs.
    4. Finally, the expected results would be coming from Twitter hashtags.


    