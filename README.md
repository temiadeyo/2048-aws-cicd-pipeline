# 2048 Game DevOps on AWS

## Overview


When developing and deploying modern applications, containerization and CI/CD pipelines play an important role in making software delivery more consistent, repeatable, and automated. Containerizing an application provides a consistent environment for running workloads, while CI/CD pipelines automate the process of building, packaging, and deploying application changes or new versions.

AWS provides a range of services that can be combined to create an automated deployment workflow for containerized applications. In this project, I use Amazon ECS and AWS Fargate to run the application, Amazon ECR to store the Docker image, and AWS CodeBuild and CodePipeline to automate the build and deployment process.

This project focuses on deploying a Dockerized version of the 2048 game to AWS through an automated CI/CD pipeline. Terraform is used to provision the underlying AWS infrastructure, while the pipeline handles the application build and deployment process.

The goal is to build a repeatable deployment workflow where application changes can be retrieved from GitHub, built into a Docker image, pushed to Amazon ECR, and deployed to ECS Fargate without manually configuring the application infrastructure for each deployment.

This project demonstrates core AWS DevOps concepts including:

-   Infrastructure as Code using Terraform
    
-   Containerization using Docker
    
-   Container image management using Amazon ECR
    
-   Container deployment using Amazon ECS and AWS Fargate
    
-   Application traffic distribution using an Application Load Balancer
    
-   CI/CD automation using AWS CodePipeline and CodeBuild
    
-   Network segmentation using public and private subnets
    
-   Access control using security groups and IAM
    
-   Application and build logging using Amazon CloudWatch

----------

## Architecture

![2048 AWS DevOps Architecture Diagram](/images/2048-architecture.png)

The application is deployed within a custom Amazon VPC across two Availability Zones. The architecture separates the public-facing infrastructure from the application workloads by placing the Application Load Balancer in public subnets and the ECS tasks in private subnets.

The Application Load Balancer receives traffic from users and forwards HTTP requests to healthy ECS tasks. The CI/CD pipeline is connected to the GitHub repository and is responsible for retrieving the application source code, building the Docker image, pushing the image to Amazon ECR, and deploying application changes or updates to Amazon ECS.

The Application Load Balancer is deployed in the public subnets, while the ECS tasks run in the private subnets without public IP addresses.

----------

## Key AWS Services

-   **Amazon VPC:** Provides the isolated network environment for the application.
    
-   **Application Load Balancer:** Provides the public entry point and distributes traffic to ECS tasks.
    
-   **Amazon ECS:** Manages the containerized application.
    
-   **AWS Fargate:** Runs the ECS containers without requiring EC2 instance management.
    
-   **Amazon ECR:** Stores the Docker image.
    
-   **AWS CodePipeline:** Automates the source, build, and deployment stages.
    
-   **AWS CodeBuild:** Builds the Docker image and pushes it to ECR.
    
-   **Amazon S3:** Stores artifacts used by CodePipeline.
    
-   **Amazon CloudWatch:** Stores ECS and CodeBuild logs.
    
-   **AWS IAM:** Controls permissions between AWS services.    

----------

## Pipeline Workflow

The CI/CD pipeline automates the process of taking application changes from the GitHub repository, building a new Docker image, storing the image in Amazon ECR, and deploying the application to Amazon ECS.

The pipeline consists of three stages:

```
Source -> Build -> Deploy
```

### 1. Application Preparation

The initial 2048 application source code was provided as part of the [Zero to Cloud](https://learn.zerotocloud.co/) project by Tech With Lucy.

I cloned the 2048 application source code using the following commands:

```bash
git clone https://github.com/techwithlucy/ztc-projects.git
cd ztc-projects/projects/advanced-aws-projects/project-1
```

The project contains the application source code, Dockerfile, and build configuration used as the starting point for containerization and deployment to AWS.

The `Dockerfile` provides the instructions required to create the Docker image that will eventually run on ECS Fargate. The `buildspec.yml` defines the commands AWS CodeBuild will execute during the build stage.

----------

### 2. GitHub Repository Update

Once the Dockerfile and application files are ready, they are committed and pushed to a GitHub repository.

The repository contains the application source code together with the files required to build and deploy the container.

```bash
git add .
git commit -m "Initial commit"
git push origin main
```
The GitHub repository serves as the source for the CI/CD pipeline, with AWS CodeConnections configured to monitor the `main` branch for new changes.

----------

### 3. CodePipeline Source Stage

Once the change is pushed to the `main` branch in GitHub, CodePipeline detects the update through the configured GitHub connection.

The source stage takes the application files from the GitHub repository and packages them into a source artifact.

This artifact is then passed to the CodeBuild stage, where the application is built into a Docker image.

The source artifact ensures that CodeBuild uses the exact application version associated with that pipeline execution.

----------

### 4. CodeBuild Stage

Once the source stage completes successfully, CodePipeline starts the AWS CodeBuild project.

CodeBuild receives the source artifact from CodePipeline and executes the commands defined in the `buildspec.yml` file to build the application.

Build logs are sent to Amazon CloudWatch.

----------

### 5. Docker Image Creation

During the CodeBuild stage, the `Dockerfile` is used to create a Docker image containing the 2048 application.

The build process packages the application and its required files into the Docker image.

Once the image is built successfully, it is tagged for the Amazon ECR repository.

----------

### 6. Docker Image Push to ECR

After the Docker image has been built and tagged, CodeBuild authenticates with Amazon ECR and pushes the image to the project's ECR repository.

Amazon ECR stores the Docker image that will be used by the ECS deployment stage.

Once the image has been pushed successfully, the pipeline continues to the deployment artifact and ECS deployment stages.

----------

### 7. Deployment Artifact

After building and pushing the Docker image, the build process creates the deployment artifact `imagedefinitions.json` required by the ECS deployment stage.

The file identifies the ECS container and the Docker image that should be deployed.

The deployment artifact is returned to CodePipeline and passed to the Deploy stage.

----------

### 8. ECS Deployment

Once the CodeBuild stage completes successfully, CodePipeline starts the ECS deployment stage.

CodePipeline uses the `imagedefinitions.json` file to update the ECS service with the newly built Docker image.

The ECS deployment action updates the service so that the new application image can be launched.

----------

### 9. ECS Starts the Updated Application

The ECS service launches the updated Fargate tasks using the Docker image stored in Amazon ECR.

The service is configured to maintain two running tasks across the private subnets in two Availability Zones.

The ECS tasks run without public IP addresses. Instead, outbound traffic from the private subnets uses the NAT Gateways.

The tasks are registered with the Application Load Balancer target group so that the ALB can route traffic to them.

----------

### 10. Application Health Check

The Application Load Balancer performs a health check against the ECS tasks.

The configured health check uses:

```
Path: /
Protocol: HTTP
Expected response: 200
```

The target group uses the health check to determine whether the ECS tasks are healthy. Once the application responds successfully to the health check, the task is available to receive traffic from the Application Load Balancer.

----------

### 11. Application Becomes Available

Once the ECS tasks are running and pass the ALB health checks, the 2048 application becomes available through the Application Load Balancer. The application can be accessed using the DNS name provided by the Application Load Balancer.

![2048 Game Initial Deployment](/images/initial-deployment.png)

A successful response from the application confirms that the application has been deployed and is being served through the Application Load Balancer.

----------

### 12. Subsequent Application Update

After the initial deployment, I made a small change to the application to demonstrate how subsequent releases are handled by the CI/CD pipeline.

For this update, I changed the application name in `index.html` from:

```text
2048
```
to:

```text
2048 by Temi
```

The updated file was then committed and pushed to the `main` branch in GitHub.

```bash
git add index.html
git commit -m "Update game name to 2048 by Temi"
git push origin main

```

The new commit triggered CodePipeline, which retrieved the updated source code and passed it to CodeBuild.

The subsequent CodePipeline execution completed successfully across the Source, Build, and Deploy stages.

![CodePipeline Execution](/images/codepipeline-execution.png)

CodeBuild built a new Docker image containing the updated `index.html` file and pushed the image to Amazon ECR.

![CodeBuild Logs](/images/codebuild-logs.png)

CodePipeline used the deployment artifact to update the ECS service with the new Docker image. ECS then launched the updated tasks, and the Application Load Balancer performed its health check before sending traffic to the tasks.

![ECS Tasks](/images/ecs-tasks.png)

After the deployment completed, the application was accessed through the Application Load Balancer and the updated application name was displayed.

![Updated 2048 Game](/images/subsequent-deployment.png)

This demonstrates that subsequent application changes can be deployed by making a change in the source code and pushing it to GitHub, without manually rebuilding the Docker image or updating the ECS service.

----------

## Infrastructure as Code (Terraform)

The AWS infrastructure was defined using Terraform.

The Terraform configuration provisions:

-   VPC
    
-   Public and private subnets
    
-   Internet Gateway
    
-   NAT Gateways
    
-   Route tables
    
-   Security groups
    
-   Application Load Balancer
    
-   Target group and health checks
    
-   ECR repository
    
-   ECS cluster
    
-   ECS task definition
    
-   ECS service
    
-   CloudWatch log groups
    
-   IAM roles and policies
    
-   S3 artifact bucket
    
-   CodeBuild project
    
-   CodePipeline
    

This allows the complete environment to be recreated without manually configuring the AWS Management Console.

### Terraform Structure

```
terraform/
├── provider.tf
├── variables.tf
├── terraform.tfvars.example
├── main.tf
├── outputs.tf
└── datasources.tf
```

| File | Purpose |
|---|---|
| `provider.tf` | Configures the AWS provider |
| `variables.tf` | Defines reusable Terraform variables |
| `terraform.tfvars.example` | Example environment-specific values |
| `main.tf` | Creates the AWS infrastructure and CI/CD resources |
| `outputs.tf` | Outputs useful resource information such as the ALB's URL |
| `datasources.tf` | Retrieves Availability Zones and AWS account information |




### Deployment Workflow

The infrastructure can be deployed using the standard Terraform workflow:

```bash
terraform init
terraform plan
terraform apply
```

Once the infrastructure has been created, changes pushed to the GitHub repository can be deployed through the CodePipeline workflow.

After testing is complete, the infrastructure can be removed:

```bash
terraform destroy
```
This allows the AWS environment to be created and removed without manually configuring each resource. It can also help avoid unnecessary AWS costs when the project is not being used.

----------

## Key Technical Decisions

- **Multi-AZ Deployment**: The infrastructure was deployed across two Availability Zones, with public and private subnets in each AZ. Running two ECS tasks across the Availability Zones provides redundancy if a task or Availability Zone becomes unavailable.

- **Private ECS Tasks**: The ECS tasks were placed in private subnets and configured without public IP addresses because they only need to receive traffic through the Application Load Balancer. This keeps the application containers isolated from direct internet access.

- **Application Load Balancer**: The ALB was placed in the public subnets because the application needs a public entry point for users. It distributes traffic across the ECS tasks and performs health checks so traffic is only sent to healthy tasks.

- **AWS Fargate**: AWS Fargate was used to run the ECS containers because the project does not require managing the underlying EC2 instances. This allows the deployment to focus on the application containers and their required compute resources.

- **Amazon ECR**: ECR was used as the container registry because it integrates directly with ECS and provides a central location for CodeBuild to store the Docker images that are used during deployment.

- **CodePipeline and CodeBuild**: CodePipeline was used to manage the overall CI/CD workflow, while CodeBuild was used to build the Docker image and publish it to ECR. This provides an automated path from a GitHub commit to an updated ECS deployment without manually running each step.

- **CloudWatch**: CloudWatch was used for centralized logging because the ECS application and CodeBuild process need a place to store and review their logs. This makes it easier to troubleshoot application and deployment issues.

- **Terraform**: Terraform was used to provision the AWS infrastructure and CI/CD resources using infrastructure as code. This makes the environment reproducible and allows the infrastructure configuration to be version-controlled alongside the project.
----------

## Conclusion

This project demonstrated how a containerized web application can be automatically built and deployed to AWS using a CI/CD pipeline.

The 2048 application was containerized using Docker and stored in Amazon ECR. AWS CodePipeline connects GitHub to CodeBuild and ECS, while CodeBuild handles the Docker image build and pushes the image to ECR.

The application is deployed to Amazon ECS using Fargate and runs in private subnets behind an Application Load Balancer deployed across public subnets.

The supporting AWS infrastructure and CI/CD resources were provisioned using Terraform.

The completed workflow demonstrates how source control, automated builds, container image management, and ECS deployments can be connected into a repeatable AWS deployment process.
