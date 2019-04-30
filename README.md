**Maitainer**: MAINTAINER app-dev@ceros.com
  This is the documentation for deploying the ceros-ski app
  The ceros-ski app is a nodejs app and same is ccontainerize using docker for deployment.
  This set up fulfills all the general requirement for the deploy as in the challenge document.
  It also fulfills 2 of the bonus challenge save the last one.
  
  One way to do the last bonus challenge, i.e. update app without downtime, would be to spin up new (green) deployment and                        have DNS (say Route 53) switch traffic from the old (blue) deployment to the new deployment. There should be no downtime for   this method.

The App traffic flow is as below:

<img width="723" alt="Ceros-ski App Traffic Diagram" src="https://user-images.githubusercontent.com/37908685/56900121-0054c800-6a8d-11e9-9e5b-33cb8fb25a3b.png">


The deployment for the app takes place in two parts:
1. Infrastructure build using Terraform
2. App deployment on infrastructure using a bash script.

1. Infrastructure build using Terraform 
The infrastructure for the app is built using the concepts of Infrastructure as code on AWS using Terraform. The files used for this are:
main.tf: This contains the terraform config that builds the infrastructure
variables.tf: This contains a listing of variables, and in many cases, their assignments
output.tf: This contains some important output values, such as the public IP of the instance through which the app would be accessed through the internet.


2. App deployment on infrastructure using a bash script.
After terraforms build the vm, it call the script, bootstrap.sh, to deploy the app.
The bootstrap script does the following:
1. After terraforms build the vm, it call the script, bootstrap.sh, to deploy the app.
2. The bootstrap script does the following:
3. Installs Docker, community edition and other utilities.
4. Starts and enables Docker (if not already started)
5. Installs Docker-compose
6. Builds the nodejs app into a Docker image
7. Creates the docker-compose.yaml file
8. Creates the nginx loadbalancer config file.
9. Deploys multiple app containers frontended and loadbalanced by an nginx container


To deploy the app one need to do the following
1. Have a AWS account
2. Have the app folder copied on a deploy instance
3. Have a valid Access key ID and Secret access key set up with the appropriate permisions on AWS IAM
4. Have the Access key ID and Secret access key securely set to the appropriate variable in the variable.tf file, e.g. using enviroment variables (credentials should not be saved in (publicly acceessible) files)
5. Have Terraform installed and initialised
6. Terraform apply !
