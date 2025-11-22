
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
 aws ec2 authorize-security-group-ingress --group-id <sg-id> --protocol tcp --port 80 --cidr 0.0.0.0/0
 aws ec2 authorize-security-group-ingress --group-id <sg-id> --protocol tcp --port 443 --cidr 0.0.0.0/0
```

 ### 3.3 Provisioning EC2 Instances
 #### **Launch EC2 Instances:**
```
aws ec2 run-instances --image-id ami-0abcdef1234567890 --count 1 --instance-type t2.micro --key-name MyKeyPair --security-group-ids <sg-id> --subnet-id <subnet-id> --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyNewInstance}]'
```

#### Install Docker, Jenkins, Maven and MySQL on the EC2 instance:
#Docker
```
sudo yum update -y
 sudo yum install docker -y
 sudo service docker start
 sudo usermod -a -G docker ec2-user
```
#Jenkins
```
 sudo dnf install java-17-amazon-corretto -y 
 wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-    stable/jenkins.repo
 rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
 sudo yum install jenkins -y
 sudo systemctl start jenkins
 sudo systemctl enable jenkins
```
#Maven
```
sudo yum update
sudo yum install maven -y
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
 
 ### 3.4 Setting Up an RDS Database
#### Provision an RDS Instance (MySQL):
```

aws rds create-db-instance --db-instance-identifier mydbinstance --db-instance-class db.t2.micro --engine mysql --master-username admin --master-user-password password --allocated-storage 20 --vpc-security-group-ids <sg-id>
```
#### Connect the Application with RDS endpoint:
```

jdbc:mysql://<rds-endpoint>:3306/mydatabase
```
#### Ensure connectivity by testing with MySQL client:
```
 mysql -h <rds-endpoint> -u admin -p
 ```
 ```
 telnet <rds endpoint> 3306 (test connection)
 ```
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
    - Search for **GitHub** and **GitLab** plugins and install it.

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

1. **Define a Jenkinsfile:**
 ``` groovy  
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



 









            
