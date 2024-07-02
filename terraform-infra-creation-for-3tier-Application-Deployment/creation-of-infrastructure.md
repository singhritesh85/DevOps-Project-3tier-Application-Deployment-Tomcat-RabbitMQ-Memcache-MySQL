Follow Below steps to create the Infrastructure
<br><br/>
```
1. Clone Terraform Script from the GitHub repo using the command as shown below
git clone https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy.git
cd DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy
2. change directory to alb-autoscalinggroup-using-packer/alb-asg/
3. Using user_data.sh I am installing codedeploy-agent which is needed for the execuation of AWS Codedeploy. You can login into the ASG's EC2 with the help of Key-Pair.
4. provide execute permission to the shell script test.sh using the command chmod +x test.sh
5. Finally run this script using the command ./test.sh. This script will create the Golden AMI using packer in which Tomcat will be install using Ansible.
6. This Golden AMI will be used to create the EC2 using the Autoscaling Group.
7. Provide the required parameters in terraform.tfvars
8. Now change the directory to Jenkins-Master-Slave-AWS/jenkins/ and provide required parameters in terraform.tfvars and run the command terraform init then terraform apply -auto-approve
9. Provide ssh public key in the file user_data_jenkins_master.sh and user_data_jenkins_slave.sh present at the path Jenkins-Master-Slave-AWS/jenkins/
10. Finally change the directory to SonarQube-Nexus/sonarqube-nexus/ and provide required parameters in terraform.tfvars and run the command terraform init then terraform apply -auto-approve
11. Provide ssh public key in the file user_data_nexus.sh and user_data_sonarqube.sh present at the path SonarQube-Nexus/sonarqube-nexus/
```
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/4117c9d1-b70d-4ebe-9e35-2b60602e6411)
