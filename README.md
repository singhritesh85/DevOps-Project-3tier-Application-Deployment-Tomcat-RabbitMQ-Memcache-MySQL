### DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL

Architecture Diagram for three tier Application Deployment
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/bcccdffc-61d6-4072-bc5c-643b263cc529)
Using the Terraform Script present in this repository create the end-to-end Infrastructure. 
<br><br/>
For RabbitMQ installation do as shown in screenshot below.
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/95e97ddd-a0ad-4765-a287-86d2d2c4e974)
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/92b73038-b99e-4f70-af64-ffa4fea315aa)
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/edc0dae0-1c47-46ac-a0b0-f481f5401ea9)
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/2f3d9712-2473-494a-b4ff-a969ef6833f7)
<br><br/>
Run the below command to create RDS MySQL database entry. To do so first of all create a file db.sql using the content as shown in the screenshot below.
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/1d41e645-aebb-495d-907b-8c4a3c9ff657)
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/676aef44-47c6-4827-b132-32b6695d1479)
<br><br/>
Establish the passwordless authentication between Jenkins Slave Node and Tomcat Server as shown in the screenshot below.
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/a1258cc0-f4c7-4733-ae18-c7bb97a1d0a9)
```
pipeline{
    agent{
        node{
            label "Slave-1"
            customWorkspace "/home/jenkins/3tierapp/"
        }
    }
    environment {
        JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64"
        PATH="$PATH:$JAVA_HOME/bin:/opt/apache-maven/bin:/opt/node-v16.0.0/bin:/usr/local/bin"
    }
    parameters { 
        string(name: 'COMMIT_ID', defaultValue: '', description: 'Provide the Commit ID') 
    }
    stages{
        stage("Clone-code"){
            steps{
                cleanWs()
                checkout scmGit(branches: [[name: '${COMMIT_ID}']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-cred', url: 'https://github.com/singhritesh85/Three-tier-WebApplication.git']])
            }
        }
        stage("SonarQubeAnalysis-and-Build"){
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh 'mvn clean package sonar:sonar'
                }
            }
        }
        //stage("Quality Gate") {
        //    steps {
        //        timeout(time: 1, unit: 'HOURS') {
                    //waitForQualityGate abortPipeline: true
        //            waitForQualityGate abortPipeline: false, credentialsId: 'sonarqube'
        //        }
        //    }
        //}
        stage("Nexus-Artifact Upload"){
            steps{
                script{
                    def mavenPom = readMavenPom file: 'pom.xml'
                    def nexusRepoName = mavenPom.version.endsWith("SNAPSHOT") ? "maven-snapshot" : "maven-release"
                    nexusArtifactUploader artifacts: [[artifactId: 'vprofile', classifier: '', file: 'target/vprofile-v2.war', type: 'war']], credentialsId: 'nexus', groupId: 'com.visualpathit', nexusUrl: 'nexus.singhritesh85.com', nexusVersion: 'nexus3', protocol: 'https', repository: "${nexusRepoName}", version: "${mavenPom.version}"
                }    
            }
        }
        stage("Deployment"){
            steps{
                      sh 'scp -rv target/vprofile-v2.war tomcat-admin@10.10.4.225:/opt/apache-tomcat/webapps/ROOT.war'
            }
        }
    }
}
```
Before running the Jenkins Job change the **application.properties** file present at the path Three-tier-WebApplication/src/main/resources in the Repository https://github.com/singhritesh85/Three-tier-WebApplication.git as shown in the screenshot below.
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/34ea8ee5-da11-48eb-a7c5-f3638488b7b6)
<br><br/>
The Screenshot for SonarQube Analysis and Nexus Artifacts Upload is as shown below.
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/e06ed6e5-7494-4e55-8847-8cd78ad3c5e5)
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/84082051-b591-4b51-acf2-f61a3df49d46)
<br><br/>
Do the entry in Route53 hosted zone and create the record set as shown in the screenshot below.
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/7f842890-a71e-41e8-9dae-43692bf24b04)
<br><br/>
Finally screenshot shown below Access of the Application.
<br><br/>
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/8cbe74bf-bba9-4d1d-937a-51e35ae5b1f0)

use the username **admin_vp** and password **admin_vp** to login.

![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/14392183-3138-48b4-a449-898c47ad55d1)
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/c0a7c45e-3325-4d6f-8e62-afb16f7d9841)

When first time you click on User Id the user information will get from MySQL Database and this information will be inserted in memcache. So next time when you click on User Id the user information will get from the memcache.

![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/1fa1f23e-6e39-4c06-9eed-12baeeab33f0)
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/24bb5b28-78a7-4337-a7a1-c799f6e58bd9)
![image](https://github.com/singhritesh85/DevOps-Project-3tier-Application-Deployment-Tomcat-RabbitMQ-Memcache-MySQL/assets/56765895/c6c0dccf-3a3f-4b07-a51d-0f42876a74c1)

<br><br/>
<br><br/>
```
Source Code:-  https://github.com/singhritesh85/Three-tier-WebApplication.git
```
<br><br/>
<br><br/>
<br><br/>
<br><br/>
<br><br/>
<br><br/>
```
Reference:-  https://github.com/logicopslab/vprofile-project.git
```
