import os # For environmental variables when running in CodeBuild, Fargate, Lambda, etc.
import boto3 # Because you need it lol
import botocore # For Error Handling
import json # To parse "stringified" JSON Policy documents
import time # to create Unix timestamps for DynamoDB TTL
import multiprocessing
import hashlib # To create unique IDs for places where AWS doesn't have them
from botocore.config import Config

# Boto3 Client Configuration for retries. AWS Defaults to 4 Max Attempts in "Normal Mode"
# Adaptive is a beta feature that will attempt exponential backoffs and different headers
# to avoid being throttled
config = Config(
   retries = {
      'max_attempts': 10,
      'mode': 'adaptive'
   }
)

# Boto3 Clients
dynamodb = boto3.client('dynamodb')
ec2 = boto3.client('ec2')
sts = boto3.client('sts',config=config)
#sqs = boto3.client('sqs',config=config) # Adding SQS in global space if you will send payloads to SQS

# Global env vars
epochDay = 86400
awsRegion = os.environ['AWS_REGION'] # This is a "baked in" env var for Lambda and CodeBuild
accountTable = os.environ['AWS_ACCOUNT_TABLE'] # This points to a DDB table with all of your AWS Accounts in it, from Organizations
'''
One of the better ways to assume cross account roles with STS in various accounts is to ensure the Name of the Role is consistent in every account.
In the later functions you will see how to loop through Accounts and Regions and pass those variables to STS and create Boto3 Sessions and Clients.
If you do not have consistency, you will need to maintain another table or file that maintains the Account and IAM Role ARN pairs, which is more
work than it is worth...IMHO
'''
crossAccountRoleName = os.environ['CROSS_ACCOUNT_ASSET_ROLE_NAME'] 

'''
If you do not want to store your Accounts in DDB, or do not have a way to do so you can use the following
script to assume a Role in the AWS Organizations Master account to write them to memory or insert them into 
a DynamoDB table.
orgsRoleArn = 'YOUR_IAM_ROLE_ARN_HERE'
print('Assuming the AWS Organizations Role!')
try:
    memberAcct = sts.assume_role(RoleArn=orgsRoleArn,RoleSessionName='ACCOUNT_SESSION')
    xAcctAccessKey = memberAcct['Credentials']['AccessKeyId']
    xAcctSecretKey = memberAcct['Credentials']['SecretAccessKey']
    xAcctSeshToken = memberAcct['Credentials']['SessionToken']
    organizations = boto3.client('organizations',aws_access_key_id=xAcctAccessKey,aws_secret_access_key=xAcctSecretKey,aws_session_token=xAcctSeshToken)
    print('Assumed the AWS Organizations Role!')
except Exception as e:
    raise e
dynamodbResource = boto3.resource('dynamodb', region_name=awsRegion)
orgsTable = dynamodbResource.Table(accountTable)
print('Writing AWS Organizations Accounts into DynamoDB')
paginator = organizations.get_paginator('list_accounts')
iterator = paginator.paginate()
for page in iterator:
    for a in page['Accounts']:
        try:
            orgsTable.put_item(
                Item={
                    'awsAccountId': str(a['Id']),
                    'accountName': str(a['Name']),
                    'organizationsAcctArn': str(a['Arn']),
                    'accountEmail': str(a['Email']),
                    'accountStatus': str(a['Status']),
                    'joinedDate': str(a['JoinedTimestamp'])
                }
            )
        except Exception as e:
            print(e)
print('AWS Organiztions Accounts written to DynamoDB')
'''

print('Getting all AWS Accounts')

# create empty list for all member Accounts
accountList = []
# create a Scan paginator for DynamoDB
paginator = dynamodb.get_paginator('scan')
try:
    # Get all AWS Accounts as reported by AWS Organizations from DDB
    iterator = paginator.paginate(TableName=accountTable)
    for page in iterator:
        for item in page['Items']:
            # Change this schema if you have a different one in DDB
            memberAcctId = str(item['awsAccountId']['S'])
            acctStatus = str(item['accountStatus']['S'])
            if acctStatus == 'ACTIVE':
                accountList.append(memberAcctId)
            else:
                print('Account ' + memberAcctId + ' is not Active, skipping!')
                pass
    print('All Accounts retrieved from DynamoDB')
except Exception as e:
    raise e
    
print('Got all AWS Accounts')

print('Getting all AWS Regions')
            
# create empty list for all opted-in Regions
regionList = []
try:
    # Get all Regions we are opted in for
    for r in ec2.describe_regions()['Regions']:
        regionName = str(r['RegionName'])
        optInStatus = str(r['OptInStatus'])
        if optInStatus == 'not-opted-in':
            pass
        else:
            regionList.append(regionName)
    
    print('All Regions retrieved from EC2 service')
except Exception as e:
    raise e
    
print('Got all AWS Regions')

def cross_account_cross_region_inventory():
    # You have to create a Boto3 Resource for DynamoDB if you were going to directly publish payloads to DDB.
    dynamodbResource = boto3.resource('dynamodb', region_name=awsRegion) 
    # Parse through accounts one at a time to dynamically create a Role ARN 
    # that we will assume using STS
    for account in accountList:
        invRoleArn = 'arn:aws:iam::' + account + ':role/' + crossAccountRoleName
        try:
            memberAcct = sts.assume_role(RoleArn=invRoleArn,RoleSessionName='X-ACCT-INVENTORY')
            # retrieve creds from member account
            xAcctAccessKey = memberAcct['Credentials']['AccessKeyId']
            xAcctSecretKey = memberAcct['Credentials']['SecretAccessKey']
            xAcctSeshToken = memberAcct['Credentials']['SessionToken']
            # Parse through each region to create a region-aware Boto3 session
            # we can pass this Session (with the STS Credentials) to create
            # temporary Region-bound keys to interact with AWS APIs
            for region in regionList:
                # We will pass in the Temporary Keys and the Region to a Boto3 Session which will create an Authentication Object
                # In the specific Account and Region so you can create additional Clients which are thread/process safe
                session = boto3.Session(region_name=region,aws_access_key_id=xAcctAccessKey,aws_secret_access_key=xAcctSecretKey,aws_session_token=xAcctSeshToken)
                # Create a Client from the Session, passing the Config item to apply retry policies
                ecra = session.client('ecr',config=config)
                paginator = ecra.get_paginator('describe_repositories')
                iterator = paginator.paginate()
                for page in iterator:
                    for r in page['repositories']:
                        repoArn = str(r['repositoryArn'])
                        ###---do more parsing here---###
                        print('We have ' + repoArn + ' for AWS Account: ' + account + ' in Region: ' + region)
                        '''
                        From here you can continue to parse your Boto3 response payloads and send them to SQS
                        or directly to S3, DynamoDB, etc. from wherever you are running this script.
                        You'll need to ensure your IAM Role / User has permissions to interact with these
                        downstream targets (e.g., you'll need dynamodb:PutItem or s3:PutObject options)
                        '''
        
        except botocore.exceptions.ClientError as error:
            # If we get an Assume Role Error either the role doesn't exist or something is wrong
            # print to stdout so we can record it and move on
            if error.response['Error']['Code'] == 'AccessDenied':
                print('Cannot assume the role for Account ' + account)
            else:
                print('We found another error!')
                print(error)
                #raise error
            
    print('Finished')

def cross_account_cross_region_inventory_two():
    # You have to create a Boto3 Resource for DynamoDB if you were going to directly publish payloads to DDB.
    dynamodbResource = boto3.resource('dynamodb', region_name=awsRegion) 
    # Parse through accounts one at a time to dynamically create a Role ARN 
    # that we will assume using STS
    for account in accountList:
        invRoleArn = 'arn:aws:iam::' + account + ':role/' + crossAccountRoleName
        try:
            memberAcct = sts.assume_role(RoleArn=invRoleArn,RoleSessionName='X-ACCT-INVENTORY')
            # retrieve creds from member account
            xAcctAccessKey = memberAcct['Credentials']['AccessKeyId']
            xAcctSecretKey = memberAcct['Credentials']['SecretAccessKey']
            xAcctSeshToken = memberAcct['Credentials']['SessionToken']
            # Parse through each region to create a region-aware Boto3 session
            # we can pass this Session (with the STS Credentials) to create
            # temporary Region-bound keys to interact with AWS APIs
            for region in regionList:
                # We will pass in the Temporary Keys and the Region to a Boto3 Session which will create an Authentication Object
                # In the specific Account and Region so you can create additional Clients which are thread/process safe
                session = boto3.Session(region_name=region,aws_access_key_id=xAcctAccessKey,aws_secret_access_key=xAcctSecretKey,aws_session_token=xAcctSeshToken)
                # Create a Client from the Session, passing the Config item to apply retry policies
                tempds = session.client('ds',config=config)
                response = tempds.describe_directories()
                if str(response['DirectoryDescriptions']) == '[]':
                    pass
                else:
                    for d in response['DirectoryDescriptions']:
                        directoryId = str(d['DirectoryId'])
                        print('We have ' + directoryId + ' for AWS Account: ' + account + ' in Region: ' + region)
                        '''
                        From here you can continue to parse your Boto3 response payloads and send them to SQS
                        or directly to S3, DynamoDB, etc. from wherever you are running this script.
                        You'll need to ensure your IAM Role / User has permissions to interact with these
                        downstream targets (e.g., you'll need dynamodb:PutItem or s3:PutObject options)
                        '''
        
        except botocore.exceptions.ClientError as error:
            # If we get an Assume Role Error either the role doesn't exist or something is wrong
            # print to stdout so we can record it and move on
            if error.response['Error']['Code'] == 'AccessDenied':
                print('Cannot assume the role for Account ' + account)
            else:
                print('We found another error!')
                print(error)
                #raise error
            
    print('Finished')

'''
This section is how we use the Python Multiprocessing module. Since Boto3 Clients
are thread safe, we can parallelize the collection of various resources/assets across
our AWS Accounts and Regions. Ensure that you are rightsizing your compute resources -
the more Processes you run the more CPU intensive it will be. If you are not passing the
payloads directly to DDB, SQS, SNS, etc. you will need to make sure you have ample memory
as well especially if you will be storing the payloads in memory to write them to a CSV or JSON
file or similar.
'''

def main():
    p1 = multiprocessing.Process(target = cross_account_cross_region_inventory)
    p2 = multiprocessing.Process(target = cross_account_cross_region_inventory_two)
    
    p1.start()
    p2.start()
    
    p1.join()
    p2.join()
    
    p1.terminate()
    p2.terminate()

main()