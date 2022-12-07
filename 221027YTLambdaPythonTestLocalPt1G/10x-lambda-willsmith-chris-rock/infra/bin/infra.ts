#!/usr/bin/env node
import 'source-map-support/register';
import { App } from 'aws-cdk-lib';
import { InfraStack } from '../lib/infra-stack';
import * as config from '../config/config.json';

const app = new App();
const env = { account: process.env.CDK_DEFAULT_ACCOUNT, region: config.region };
const stackName = `${config.orgName}-${config.appName}-infra-stack-${config.attribute}`.toLowerCase();

const stack = new InfraStack(app, stackName, {
  env: env,
  orgName: config.orgName,
  attribute: config.attribute,
  appName: config.appName,
  envType: config.envType,
  region: config.region,
});
console.log("Stack name: " + stack.stackName);
app.synth()