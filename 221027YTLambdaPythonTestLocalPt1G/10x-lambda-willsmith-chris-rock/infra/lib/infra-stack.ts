import * as lambda from 'aws-cdk-lib/aws-lambda';
import { Construct } from "constructs";
import { Duration, Stack, StackProps, PhysicalName } from 'aws-cdk-lib';
import * as autoscaling from 'aws-cdk-lib/aws-autoscaling';
import * as ssm from 'aws-cdk-lib/aws-ssm';
import * as events from 'aws-cdk-lib/aws-events'
import * as targets from 'aws-cdk-lib/aws-events-targets';
import * as asg from 'aws-cdk-lib/aws-autoscaling';
import { Role, PolicyStatement, ServicePrincipal, ManagedPolicy } from 'aws-cdk-lib/aws-iam';
import { Instance, InstanceClass, InstanceSize, InstanceType, MachineImage, SubnetType, Vpc } from 'aws-cdk-lib/aws-ec2';

export interface InfraStackProps extends StackProps {
  appName: string,
  attribute: string;
  envType: string;
  region: string;
  orgName: string;
};
export class InfraStack extends Stack {

  constructor(scope: Construct, id: string, props: InfraStackProps) {
    super(scope, id, props);
    var orgName = (props.orgName).toLowerCase();
    var envType = (props.envType).toLowerCase();
    var attribute = (props.attribute).toLowerCase();
    var appName = (props.appName).toLowerCase();
    var general = `${orgName}-${appName}-infra-${envType}-${attribute}`;
    const ec2role = new Role(this, `${general}-InstanceRole`, {
      roleName: PhysicalName.GENERATE_IF_NEEDED,
      assumedBy: new ServicePrincipal('ec2.amazonaws.com'),
    }); 

    const vpc = new Vpc(this, `${general}-vpc`, {
      cidr: '192.168.0.0/16',
      maxAzs: 1,
      subnetConfiguration: [
        {
          name: `${general}-public-subnet`,
          subnetType: SubnetType.PUBLIC,
          cidrMask: 24
        },
        {
          name: `${general}-private-subnet`,
          subnetType: SubnetType.PRIVATE_WITH_NAT,
          cidrMask: 24
        }
      ]
    });

    const ec2instance = new Instance(this, `${general}-instance`, {
      vpc: vpc,
      instanceType: InstanceType.of(InstanceClass.T3, InstanceSize.MICRO),
      machineImage: MachineImage.latestAmazonLinux(),
      vpcSubnets: {
        subnets: vpc.privateSubnets
      }
    });

    ec2instance.role.addManagedPolicy(ManagedPolicy.fromAwsManagedPolicyName('AmazonSSMManagedInstanceCore'))

    const lambdarole = new Role(this, `${general}-LambdaRole`, {
      assumedBy: new ServicePrincipal('lambda.amazonaws.com'),
      path: '/service-role/'
    });
    const lambdafunction = new lambda.DockerImageFunction(this, `${general}-lambdafunction`, {
      code: lambda.DockerImageCode.fromImageAsset("../resources/lambda"),
      timeout: Duration.seconds(20),
      environment: {
        twitter_bearer_token: "AAAAAAAAAAAAAAAAAAAAANaMigEAAAAAcMk3m5sLSX2lokFSkint4tjfe18%3DurPtJl8ET1FurRzD6Fr6zkVsqiC7CN7YglEaNMPzC0i1wsnpA4",
        hashtag_query: "#willsmithoscars"

      },
      role: lambdarole
    });

    lambdarole.addToPolicy(new PolicyStatement({
      resources: ["*"],
      actions: [
        "ec2:AssignPrivateIpAddresses",
        "ec2:UnassignPrivateIpAddresses",
        "ec2:DescribeInstances",
        "ec2:DescribeRouteTables",
        "ec2:ReplaceRoute",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeTags",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "autoscaling:*"
      ]
    }));
    lambdarole.addToPolicy(new PolicyStatement({
      resources: [`arn:aws:logs:${this.region}:${this.account}:log-group:/aws/lambda/*:*`],
      actions: [
        "logs:CreateLogGroup",
        "logs:CreateLogStream"
      ]
    }));
    lambdarole.addToPolicy(new PolicyStatement({
      resources: [`arn:aws:logs:${this.region}:${this.account}:log-group:/aws/lambda/*:log-stream:*`],
      actions: [
        "logs:PutLogEvents",
        "logs:GetLogEvents"
      ]
    }));
    new events.Rule(this, `${general}-instance-state-rule`, {
      eventPattern: {
        source: ["aws.ec2"],
        detailType: ["EC2 Instance State-change Notification"],
        detail: {
          state: ["stopping", "shutting-down"]
        },
      },
      targets: [
        new targets.LambdaFunction(lambdafunction)
      ]
    });
  }
}
