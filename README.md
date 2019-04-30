# Deploying The Dockerize Ceros ski nodejs App Unto AWS EC2 Using Terraform

**Maintainer**: app-dev@ceros.com
    
This is the documentation for deploying the ceros-ski app. The ceros-ski app is a nodejs app and same is ccontainerize using docker for deployment on EC2 on AWS. This set up fulfills all the general requirement for the deploy as in the challenge document. It also fulfills 2 of the bonus challenge save the last one.

One way to do the last bonus challenge, i.e. update app without downtime, would be to spin up new (green) deployment and                                                have DNS (say Route 53) switch traffic from the old (blue) deployment to the new deployment. There should be no downtime for   this method.

The App traffic flow is as below:

<img width="723" alt="Ceros-ski App Traffic Diagram" src="https://user-images.githubusercontent.com/37908685/56900121-0054c800-6a8d-11e9-9e5b-33cb8fb25a3b.png">


**The deployment for the app takes place in two parts:**
1. Infrastructure build using Terraform
2. App deployment on infrastructure using a bash script.


**1. Infrastructure build using Terraform** 
  
  The infrastructure for the app is built using the concepts of Infrastructure as code on AWS using Terraform. The files used for this are:
  - **main.tf:** This contains the terraform config that builds the AWS infrastructure such as VPC, SG, IGW, subnet and the EC2 instance
  - **variables.tf:** This contains a listing of variables their default values
  - **output.tf:** This contains some important output values, such as the public IP of the instance through which the app would  be accessed through the internet.


**2. App deployment on infrastructure using a bash script**
  
  After terraforms builds the EC2 Instance, it calls the script, bootstrap.sh, to deploy the app.
  The bootstrap script does the following:
  
  - Installs Docker community edition and other utilities
  - Starts and enables Docker (if not already started)
  - Installs Docker-compose used for deploying multiple containers which are  linked together
  - Builds the nodejs app into a Docker image
  - Creates the docker-compose.yaml file
  - Creates the nginx loadbalancer config file
  - Deploys multiple app containers frontended and loadbalanced by the nginx container


**To deploy the app, do the following:**
  - Have or create an AWS account
  - Have the app folder copied onto a deploy EC2 instance
  - Have a valid Access key ID and Secret access key set up with the appropriate permisions on AWS IAM
  - Have the Access key ID and Secret access key securely set to the appropriate variable in the variable.tf file, e.g. using enviroment variables (credentials should not be saved in (publicly acceessible) files)
  - Have Terraform installed and initialised
  - finally, enter 'terraform apply' in your console!
