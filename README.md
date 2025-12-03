# End-to-End DevOps Project: Building, Deploying, and Monitoring a Full-Stack Application

## Step 1: Download and install AWS cli using home-brew (Mac)

## Step 2: Configure AWS using access key and secret key

## Step 3: Infrastructure setup on AWS

### 3.1 Setting Up the VPC and Networking
 #### **Create a VPC**: 
 ```
aws ec2 create-vpc --cidr-block 10.0.0.0/16 'ResourceType=vpc gateway,Tags=[{Key=Name,Value=My_VPC}]'

aws ec2 create-tags --resources <YOUR_VPC_ID> --tags Key=Name,Value=Existing-VPC-Name (for existing vpc)
```
#### Configure subnets: 
```
aws ec2 create-subnet --vpc-id <vpc-id> --cidr-block 10.0.1.0/24 --availability-zone us-east-1a --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=My_Subnet}]'
```
#### Set up an Internet Gateway:
```
aws ec2 create-internet-gateway
 aws ec2 attach-internet-gateway --vpc-id <vpc-id> --internet-gateway-id <igw-id> --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=My_IGW}]'
```
#### Create route tables and associate with subnets:
```
aws ec2 create-route-table --vpc-id <vpc-id>
 aws ec2 create-route --route-table-id <rtb-id> --destination-cidr-block 0.0.0.0/0 --gateway-id <igw-id> aws ec2 create-route-table --vpc-id vpc-12345678 --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=My_RouteTable}]'

 aws ec2 associate-route-table --subnet-id <subnet-id> --route-table-id <rtb-id>
```
### 3.2  Set Up Security groups

#### Create a security group:
```
aws ec2 create-security-group --group-name MySecurityGroup --description "Security group for my app" --vpc-id <vpc-id> 
```
#### Allow SSH, HTTP, and HTTPS:
```
aws ec2 authorize-security-group-ingress --group-id <sg-id> --protocol tcp --port 22 --cidr 0.0.0.0/0
```
```
aws ec2 authorize-security-group-ingress --group-id <sg-id> --protocol tcp --port 80 --cidr 0.0.0.0/0
```
```

aws ec2 authorize-security-group-ingress --group-id <sg-id> --protocol tcp --port 3360 --cidr 0.0.0.0/0
```
```
 aws ec2 authorize-security-group-ingress --group-id <sg-id> --protocol tcp --port 8080 --cidr 0.0.0.0/0
```

 ### 3.3 Provisioning EC2 Instances
 #### **Launch EC2 Instances:**
```
aws ec2 run-instances --image-id ami-0abcdef1234567890 --count 1 --instance-type t2.micro --key-name MyKeyPair --security-group-ids <sg-id> --subnet-id <subnet-id> --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyNewInstance}]'
```

#### Install Docker, Docker compose, Jenkins, Maven and MySQL on the EC2 instance:
#Docker
```
 sudo yum update -y
 sudo yum install docker -y
 sudo service docker start
 sudo usermod -a -G docker ec2-user
```
#Docker-compose
```
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)

```
```
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

```
```
sudo chmod +x /usr/local/bin/docker-compose

```
```
docker-compose --version

```
#Jenkins
```
sudo dnf install java-17-amazon-corretto -y 
```
 ```
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-    stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
 ```
```
sudo yum install jenkins -y
```
```
sudo systemctl start jenkins
```
 ```
sudo systemctl enable jenkins
 ```

#Maven
```
sudo yum update
```
```
sudo yum install maven -y
```
```
mvn -v
```

#MySQL
```
sudo wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
```
```
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
```
```
sudo yum install mysql-community-client -y
```
### 3.3 Setup Load Balancer for  Ec2

#### **Create a ALB**: 

1. **Create ALB security group.**
```
aws ec2 create-security-group --group-name ALB_SG --description "Security group for my ALB" --vpc-id <vpc-id> 
```
```
aws ec2 authorize-security-group-ingress --group-id sg-010b48b401abbb34a --protocol tcp --port 80 --cidr 0.0.0.0/0
```
2. **Create ALB.**
 ```
aws elbv2 create-load-balancer --name my-alb --subnets subnet-04c6e3cd2af776231 subnet-0a1b81b816054ce53 --security-groups sg-010b48b401abbb34a --scheme internet-facing --type application --ip-address-type ipv4
```
3. **Create Target Group**.
```
aws elbv2 create-target-group \--name my-tg \--protocol HTTP \--port 8081 \--vpc-id vpc-099387ac261ad03f4 \--target-type instance \--health-check-path /
```
4. **Create a Listener.**
```
aws elbv2 create-listener \--load-balancer-arn <alb arn> \--protocol HTTP \--port 80 \--default-actions Type=forward,TargetGroupArn=<target group arn>
```
5. **Register EC2 Instances.**
```
aws elbv2 register-targets \--target-group-arn <target group arn> \--targets Id=i-038becbdc8d744d56
``` 
#### Test ALB:
1. **Open the DNS name in your browser.**
```
my-alb-143008138.us-east-2.elb.amazonaws.com //It should route traffic to your EC2 app
```
##### ✨ Outcome: A robust, scalable AWS environment ready for CI/CD and deployments.

##### 📊 This diagram represents the infrastructure I built as part of my Cloud & DevOps Learning Curve series 👇

![Architecture Diagram](src/main/resources/images/AWS_Infra_Setup.svg) 


## Step 4: Installing and Configuring Jenkins
### 4.1 Jenkins Installation

1. **Install Jenkins:** 
    
    - Already covered under EC2 provisioning. Access Jenkins via `<ec2-public-ip>:8080`.

2. **Unlock Jenkins:**
    
    - Retrieve the initial admin password:
```
       sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
### 4.2 Configuring Jenkins for GitHub Integration

1. **Install Plugins:**
    - Navigate to `Manage Jenkins -> Manage Plugins`.
    - Search for **Docker, GitHub*** and **GitLab** plugins and install it.

2. **Add Maven in Jenkins:**
    - Go to **Manage Jenkins →Tool Configuration**.
    - Scroll down to **Maven installations**.
    - Click **Add Maven**
        - Give it a name (e.g., Maven-3.9.11).
        - Either check **Install automatically** (Jenkins will download Maven), or point to a manually installed Maven directory (e.g., /opt/maven).
    - Apply and save

3. **Generate a GitHub Token:**
    - Click your GitHub profile picture → **Settings** 
    - In the left sidebar, go to **Developer settings → Personal access tokens → Tokens (classic)**. (Or “Fine-grained tokens” if you want more granular control.)
    - Click **Generate new token**.
    - Give it a **name** (e.g., `Jenkins-Access`).
    - Set an **expiration date**.
    - Select the **scopes/permissions**.
    - Click **Generate token**.

4. **Add the generated GitHub Token to Jenkins:**
     - Go to **Manage Jenkins → Credentials → System → Global credentials (unrestricted)**.
     - Add Credentials
         - **Kind**: Username with password.
         - **Username**: your GitHub username.
         - **Password**: paste the Personal Access Token you generated in GitHub.
         - **ID**: give it a recognizable name (e.g., `github-token`).
         - **Description**: optional.
         - Click create

5. **Configure Webhooks in GitHub:** 
     - Configuring a GitHub webhook with the Jenkins server URL triggers an automatic build on every push.
        - **Go to your repository on GitHub.**
        - Click **Settings → Webhooks → Add Webhooks**.
        - In **Payload URL** add your Jenkins webhooks URL (e.g.`http://ip:8080/github-webhook/`).
        - **Content type**: `application/json`.
        - Select **“Just the push event”**.
        - Click **Add Webhooks**. 

6. 8. **Set up a new pipeline job:**
     - **Create a New Pipeline Job**
	    - From the Jenkins dashboard, click New Item
	    - Enter a name for your job (e.g., `MyJavaAppPipeline`).
	    - Select **Pipeline** and click OK.

7. **Enable GitHub hook trigger in Jenkins:** 
     - Verify Jenkins is accessible to GitHub in order to trigger builds automatically.
        - In Jenkins, open your job → **Configure**.
        - Under **Triggers**, check:
            - GitHub hook trigger for GITScm polling.
            - Build when a change is pushed to GitLab.
            - Apply and save 

 8. **Configure GitHub Repository:** 
     - **In the Jenkins job configuration:**
         - Scroll to **Pipeline → Definition**.
         - Choose **Pipeline script from SCM**.
         - Select **Git** as the SCM.
         - Paste your GitHub repository URL (https://github.com/username/my-java-app.git).
         - Add credentials if your repo is private (GitHub personal access token or SSH)
         - Specify the branch (e.g., `main`).
         - Apply and save

9. **Write and commit a source code , Jenkinsfile and push it to GitHub:**
    - git commands 
         - git init
         - git add .
         - git commit -m "Initial commit: Java app with Jenkins pipeline"
         - git remote add origin 
         - git push -u origin main

## Step:5 Setting Up Jenkins Pipelines
### 5.1 Jenkinsfile 

1. **Define a Jenkinsfile:**
 ```
 pipeline {

   agent any

   tools {

         maven 'Maven 3.9.11'

   }

   stages {

     stage('Build') {

       steps {

         sh 'mvn clean install'

       }

     }

     stage('Test') {

       steps {

         sh 'mvn test'

       }

     }

     stage('Deploy') {

       steps {

          sh 'docker build -t myapp .'

        sh 'docker push myrepo/myapp'

       }

     }

   } 
  ```
  2. **Trigger the Pipeline:**
    - Create a repository in GitHub.
    - Commit and push the Jenkinsfile to your repository.
    - Jenkins looks for a file named `Jenkinsfile` at the root of your  repository and automatically triggers the build.

 3. **Build the Pipeline (For manual build):** 
    - Click **Build Now**.
    - Jenkins will pull the code and  run the pipeline. 

## Step 6: Containerizing the Application with Docker 

### 6.1 Dockerfile

1. **Create a Dockerfile In your application directory.**
```
   FROM eclipse-temurin:17-jre
   COPY target/*.jar /app/app.jar
   ENTRYPOINT ["java", "-jar", "/app/app.jar"]
``` 
2. **Build the Docker Image.**
```
docker build -t myapp .
```
3. **Verify if the image exists.**	   
```
docker images
```
4. **Run the container.**
```
docker run myapp
```
5. **docker login**.
```
docker login //Copy the URL shown in the terminal (if provided) and paste it    into your browser manually. Log in and approve access.
```
6. **Push the Image to Docker hub.**
```
docker tag my-app <dockerhub-username>/my-java-new-app:latest
```
```
docker push <dockerhub-username>/my-java-new-app:latest
```
7. **Verify.**
```
docker pull <dockerhub-username>/my-java-new-app:latest
``` 
### 6.2 Docker Compose for Local Development: (For multi-container appl)

1. **Create a `docker-compose.yml` File:**
```
    version: '3'

 services:

   app:

     image: myrepo/myapp:latest

     ports:

       - "8080:8080"

   db:

     image: mysql:8.0

     environment:

       MYSQL_ROOT_PASSWORD: qwerty123

       MYSQL_DATABASE: mydb

     ports:

       - "3306:3306"
   ```
2. **Run docker compose to run the application locally.**
```
docker-compose up -d   //Run in detached mode.
```
3. Check container status
``` 
docker ps     // lists all ACTIVE docker processes 

```
```
docker ps -a  // lists all docker processes 
```
4. **Push the Docker image.**
```
docker tag <image-name> <dockerhub-username>/<dockerhub-repo>:<tag-name>
```
```
docker login //Provide credentails
```
```    
docker push <image-name> <dockerhub-username>/<dockerhub-repo>:<tag-name>
```

5. **View logs separately.**
```
docker logs <CONAINER_ID> 
  
// Shows logs of the container. Ex: docker logs 676fbd5e2503
```
6. **Connect to MySQL.**
```
docker exec -it mysql:8.0 mysql -u root -p // enter Password to connect
```  
7. **Stop containers when done.**
```
docker-compose down
```
8. **Restart with changes.**
```
docker-compose up -d --build
```
## Step:7 Deploy Application on EC2 Instance.

### 7 .1 Manual Deployment

1. **Connect to EC2.**
    - SSH to you Ec2 instance.

2. **Pull Your Application Image.**
```
docker pull <dockerhub_username>/my-java-new-app:latest
```
3. **Run the Container.**
```
docker run -d -p 8081:8080 <dockerhub_username>/my-java-new-app:latest

//Make sure the port is open in security group
``` 
4. **Check container status.**
  ```
docker ps
  ```
### 7.2Verify Application

1. **Open in browser.** 
```
http://<ec2-public-ip>:8081/hello  //Mention the endpoint
```
### 7.3 Automated Deployment Via Jenkins Pipeline

1. **Deploy the Dockerized Java application onto EC2 directly from the Jenkins pipeline.**
   -  Commit and push the below Jenkinsfile to GitHub
```
stage('Docker Build & Push') {
    steps {
        echo 'Starting Docker login and image push'

        withCredentials([usernamePassword(credentialsId: 'docker-token',
                                         usernameVariable: 'DOCKER_USER',
                                         passwordVariable: 'DOCKER_PASS')]) {
            sh '''
            mkdir -p $HOME/.docker
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
            '''
        }

        sh 'docker build -t arpithaoncloud9/my-java-new-app:latest .'
        sh 'docker push arpithaoncloud9/my-java-new-app:latest'

        echo 'Docker image pushed successfully'
    }
}

 // Make sure you give the correct ID name e.g: credentialsId: 'docker-token'
```
2. **Docker Hub Authentication via Jenkins Credentials.**
     - In Docker go to **Account Settings → Personal Access Tokens → New Access Token**.
     - Generate a take and give it a name (e.g., `jenkins-deploy-token`).
     - Select Read, Write, Delete scopes from the dropdown.
     - Copy the token
	 - In Jenkins, go to **Manage Jenkins → Credentials → Add Credentials**.
     - Type: Username with password
     - Username: Your Docker Hub username
     - Password: The token

### 7.4 Verify deployment by accessing the app via EC2 public DNS/IP.

1. By accessing the app via EC2 public DNS/IP.
```
http://my-alb-143008138.us-east-2.elb.amazonaws.com/hello
```
## Step:8 Connect to RDS from EC2 (Applicable only for Production)

### 8.1 Setting Up RDS Database

1. **Create MySQL DB instance.**
```
aws rds create-db-instance --db-instance-identifier mydbinstance --db-instance-class db.t2.micro --engine mysql --master-username admin --master-user-password password --allocated-storage 20 --vpc-security-group-ids <sg-id>
```
2. **Connect the Application with RDS endpoint.**
  ```
  mysql://<rds-endpoint>:3306/mydbinstance
  ```
### 8.2 Connect

1. Ensure EC2 and RDS are in the same VPC.
2. Add EC2’s security group to RDS inbound rules (port 3306).
3. Get RDS Endpoint //Your DB instance endpoint from the RDS console 
4. SSH to EC2 instance.
5. Connect using: 
 ```
mysql -h <RDS-endpoint> -u <user> -p //Provide username and PW
```
6. Verify Connection
```
SHOW DATABASES;
```



  

