# AWS Labs

This is a sample boilerplate for [sam](https://github.com/awslabs/serverless-application-model)


## Getting Started

### Requirements

- AWS CLI already configured with Administrator permission

- [NodeJS 10.10+ installed](https://nodejs.org/en/download/releases/)

- [Docker installed](https://www.docker.com/community-edition)

### Organization

File structure `three`:

```
.
├── .dockerignore
├── .gitignore
├── Dockerfile
├── event.json
├── hello-world
│   └── app.js
│   └── package.json
│   └── test
│       └── test-handler.js
├── README.md
├── template.yaml
```

- `.dockerignore` To increase Docker build performance, exclude files and directories. this file is similar to `.gitignore` file, used by  the `Git` tool.

- `.gitignore` File containing untracked files,`Git`.

- `Dockerfile` The application must run in an isolated container for delivery of `CI` and continuous deployment of `CD`.

- `event.json` API Gateway Proxy Integration event payload.

- `hello-world` Source code for a lambda function.

- `hello-world/app.js` AWS lambda function code.

- `README.md` Is the software Project Documentation File. It contains information that is usually required to understand the essence of the project. It is is the easiest way to answer questions that a team may have about how to install and use the application. The most common formatting method is  [Markdown](https://guides.github.com/features/mastering-markdown/)

- `template.yaml` SAM template.

## Table of Contents

- [Setup process](#setup-process)
  - [Local development](#local-development)
- [Packaging and deployment](#packaging-and-deployment)
- [Fetch, tail, and filter Lambda function logs](#fetch-tail-and-filter-lambda-function-logs)
- [Testing](#testing)
- [Cleanup](#cleanup)
- [Bringing to the next level](#bringing-to-the-next-level)
  - [Learn how SAM Build can help you with dependencies](#learn-how-sam-build-can-help-you-with-dependencies)
  - [Create an additional API resource](#create-an-additional-api-resource)
  - [Step-through debugging](#stepthrough-debugging)
- [Building](#building)
  - [Building the project](#building-the-project)

### Setup process

#### Local development

**Invoking function locally using a local sample payload**

```bash
sam local invoke HelloWorldFunction --event event.json
```

**Invoking function locally through local API Gateway**

```bash
sam local start-api
```

If the previous command ran successfully you should now be able to hit the following local endpoint to invoke your function `http://localhost:3000/hello`

`SAM CLI` is used to emulate both Lambda and API Gateway locally and uses our `template.yaml` to understand how to bootstrap this environment (runtime, where the source code is, etc.) - The following excerpt is what the CLI will read in order to initialize an API and its routes:

**template.yaml**

```yaml
...
Events:
  HelloWorld:
    Type: Api
    Properties:
      Path: /hello
      Method: get
```


![Uml](http://yuml.me/woodger/diagram/scruffy/class/%2F%2F Cool Class Diagram, [Customer|-forname:string;surname:string|doShiz()]<>-orders*>[Order],[Order]++-0..*>[LineItem],[Order]-[note:Aggregate root{bg:wheat}].svg)

More info about API Event Source: https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#api

### Packaging and deployment

AWS Lambda NodeJS runtime requires a flat folder with all dependencies including the application. SAM will use `CodeUri` property to know where to look up for both application and dependencies:

**template.yaml**

```yaml
...
    HelloWorldFunction:
        Type: AWS::Serverless::Function
        Properties:
            CodeUri: hello-world/
            ...
```

Firstly, we need a `S3 bucket` where we can upload our Lambda functions packaged as ZIP before we deploy anything - If you don't have a S3 bucket to store code artifacts then this is a good time to create one:

```bash
aws s3 mb s3://BUCKET_NAME
```

Next, run the following command to package our Lambda function to S3:

```bash
sam package \
    --output-template-file packaged.yaml \
    --s3-bucket REPLACE_THIS_WITH_YOUR_S3_BUCKET_NAME
```

Next, the following command will create a Cloudformation Stack and deploy your SAM resources.

```bash
sam deploy \
    --template-file packaged.yaml \
    --stack-name sam-app \
    --capabilities CAPABILITY_IAM
```

> **See [Serverless Application Model (SAM) HOWTO Guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-quick-start.html) for more details in how to get started.**

After deployment is complete you can run the following command to retrieve the API Gateway Endpoint URL:

```bash
aws cloudformation describe-stacks \
    --stack-name sam-app \
    --query 'Stacks[].Outputs[?OutputKey==`HelloWorldApi`]' \
    --output table
```

### Fetch, tail, and filter Lambda function logs

To simplify troubleshooting, SAM CLI has a command called sam logs. sam logs lets you fetch logs generated by your Lambda function from the command line. In addition to printing the logs on the terminal, this command has several nifty features to help you quickly find the bug.

`NOTE`: This command works for all AWS Lambda functions; not just the ones you deploy using SAM.

```bash
sam logs -n HelloWorldFunction --stack-name sam-app --tail
```

You can find more information and examples about filtering Lambda function logs in the [SAM CLI Documentation](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-logging.html).

### Testing

We use [mocha](https://mochajs.org/) for testing our code and it is already added in `package.json` under `scripts`, so that we can simply run the following command to run our tests:

```bash
cd hello-world
npm install
npm run test
```

### Cleanup

In order to delete our Serverless Application recently deployed you can use the following AWS CLI Command:

```bash
aws cloudformation delete-stack --stack-name sam-app
```

### Bringing to the next level

Here are a few things you can try to get more acquainted with building serverless applications using SAM:

#### Learn how SAM Build can help you with dependencies

* Uncomment lines on `app.js`
* Build the project with ``sam build --use-container``
* Invoke with ``sam local invoke HelloWorldFunction --event event.json``
* Update tests

#### Create an additional API resource

* Create a catch all resource (e.g. /hello/{proxy+}) and return the name requested through this new path
* Update tests

#### Step-through debugging

* **[Enable step-through debugging docs for supported runtimes]((https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-using-debugging.html))**

Next, you can use AWS Serverless Application Repository to deploy ready to use Apps that go beyond hello world samples and learn how authors developed their applications: [AWS Serverless Application Repository main page](https://aws.amazon.com/serverless/serverlessrepo/)

### Building

#### Building the project

[AWS Lambda requires a flat folder](https://docs.aws.amazon.com/lambda/latest/dg/nodejs-create-deployment-pkg.html) with the application as well as its dependencies in a node_modules folder. When you make changes to your source code or dependency manifest,
run the following command to build your project local testing and deployment:

```bash
sam build
```

If your dependencies contain native modules that need to be compiled specifically for the operating system running on AWS Lambda, use this command to build inside a Lambda-like Docker container instead:
```bash
sam build --use-container
```

By default, this command writes built artifacts to `.aws-sam/build` folder.

> NOTE Alternatively all commands could be part of `package.json` scripts section
