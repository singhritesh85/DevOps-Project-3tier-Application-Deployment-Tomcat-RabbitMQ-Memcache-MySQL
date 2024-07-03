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
