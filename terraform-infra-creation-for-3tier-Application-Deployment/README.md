# DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/7f1e8c68-f6fc-426b-9a48-24aa6f7a8ac6)
<br><br/>
End-to-end Architecture diagram is as shown in the screenshot attached above. For this demonstration source code is present in GitHub Repository and Jenkins uses this source code. CI/CD pipeline has been created using Jenkins Freestyle Job.
<br><br/>
There are four required plugins for Jenkins to achieve this as listed below.
```
1.	Environment Injector
2.	SonarQube Scanner
3.	Nexus Artifact Upload
4.	AWS CodeDeploy
```
After installation of these four plugin configure SonarQube from Manage Jenkins > Systems as show in the screenshot below.
<br><br/>
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/781905d0-dbed-4979-bb9c-0ccd061cdd9f)
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/1d8b6cc0-b344-416b-81b1-15a5b3f8c2ba)
<br><br/>
Webhook has been created for SonarQube as shown in the screenshot below.
<br><br/>
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/776a2af7-9cbe-475a-b8a9-17f6bb7f17d6)
<br><br/>
Create Application, Deployment Group and an IAM Policy which is required by Jenkins for AWS CodeDeploy.
<br><br/>
**IAM POlicy**
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/b60a37c2-3cf5-4475-a6e4-7a203fb6a07e)
Using this policy you can create a user or IAM Role and using this user/IAM Role you can authorize Jenkins to run the Deployment in AWS CodeDeploy.
**Application for AWS CodeDeploy**
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/ae1f8381-d53a-406f-8a77-b353b7b665c8)
**Deployment Group for AWS CodeDeploy**
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/40471488-8274-4057-be95-a247b63ed02d)
<br><br/>
**Creation of FreeStyle Jenkins Job**
<br><br/>
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/a7d87b83-57de-41f4-ae45-bca5374f80ae)
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/b44c3ed4-7dd5-44e9-94cc-ba6fc68519e3)
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/365377f2-8d5e-4149-9406-a2e800d67fa3)
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/cd7eecf7-a29c-43fb-92d9-ef5321464537)
<br><br/>
The environment variable can be set using Environment Injector plugin during the Build Steps as shown in the screenshot below.
<br><br/>
During Build steps at **Execute Shell** I have used below shell script using which code will be Build using the Maven and it will check S3 bucket with the name of mederma2024 in the region us-east-2. If it exists then it will use that S3 bucket otherwise create it with the bucket policy as mentioned below. This S3 bucket will keep the revision for CodeDeploy which will be finally deployed to EC2 Instances created as a part of AutoScaling Group. SonarQube Quality Gate has been implemented using sonar.qualitygate.wait=true and sonar.qualitygate.timeout=300. If Quality Gate fails then it will fail the Jenkins Job there itself.
```
mvn clean install sonar:sonar -Dsonar.qualitygate.wait=true -Dsonar.qualitygate.timeout=300
BUCKET_EXISTANCE=`aws s3 ls s3://mederma2024 --region=us-east-2 2>&1`
if [ "$BUCKET_EXISTANCE | grep -o NoSuchBucket" == "NoSuchBucket" ]
then
  {
    aws s3 mb s3://mederma2024 --region=us-east-2
    cat > codedeploy-bucket-policy.json <<END_FOR_SCRIPT
{
	"Version": "2012-10-17",
	"Id": "S3PolicyId1",
	"Statement": [
		{
			"Sid": "IPAllow",
			"Effect": "Allow",
			"Principal": "*",
			"Action": "s3:*",
			"Resource": "arn:aws:s3:::mederma2024/*",
			"Condition": {
				"IpAddress": {"aws:SourceIp": "18.XXX.XXX.99/32"}
			} 
		} 
	]
}
END_FOR_SCRIPT
    aws s3api put-bucket-policy --bucket mederma2024 --policy file://codedeploy-bucket-policy.json
  }
else
  echo "Considering the existed bucket"
fi
```
<br><br/>
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/c89dd6a8-0b5c-436e-8006-192c0d6155d9)
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/088bae04-678f-43af-89d5-502aa184fe32)
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/2cc7e787-cf70-4003-a1e2-06d4151b8306)
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/2c9ea988-be2e-4edb-a986-29b4374bc6c2)
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/ebf62259-ff3a-4026-a69d-34968b88f800)
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/29bbb9f3-c291-4559-9e53-7c6a144c6234)
<br><br/>
Endpoint of MySQL RDS has been updated in the file login.jsp and userRegistration.jsp present at the path src/main/webapp/ of the GitHub repository as shown in the screenshot below
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/a08ceeb7-df54-4ce3-942b-762995046373)
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/8e3a682e-4aef-464c-a56a-eee50218469b)
<br><br/>
After Successful execution of Jenkins Job Deployment will be started in AWS Code Deploy and which will be completed successfuly.
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/a8038191-799a-4cd7-b6d1-9a229498df66)
<br><br/>
Finally using the URL you can access the application as shown in the screenshot below.
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/d9f28eac-0c7e-4115-bde1-29315ebbf6b4)
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/3dc66233-9442-4a22-878c-5481aaa7b7b4)
![image](https://github.com/singhritesh85/DevOps-Project-cicd-asgalb-using-jenkins-awscodedeploy/assets/56765895/b1efb612-c394-4b88-bca6-f7069126c886)
<br><br/>
<br><br/>
<br><br/>
**Source Code:**- https://github.com/singhritesh85/aws-rds-java-using-codedeploy.git
<br><br/>
For Monitoring and logging you can use NewRelic/Cloudwatch.
<br><br/>
<br><br/>
<br><br/>
<br><br/>
<br><br/>
#### On Jenkins Slave (When face Complication while pushing Artifacts to Nexus)
```
Vim /etc/resolv.conf

; generated by /usr/sbin/dhclient-script
search  singhritesh85.com          #us-east-2.compute.internal
options timeout:2 attempts:5
nameserver  8.8.8.8            #10.10.0.2
```
Now you will be able to push artifacts to Nexus.
<br><br/>
<br><br/>
<br><br/>
<br><br/>
<br><br/>
```
Reference:- https://ashok198510.hashnode.dev/cloud-native-two-tier-application-deployment-with-eks-tomcat-and-rds-in-aws
            https://github.com/Ashoksana/aws-rds-java.git
```
