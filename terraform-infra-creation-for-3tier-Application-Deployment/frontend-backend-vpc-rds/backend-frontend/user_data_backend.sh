#!/bin/bash
/usr/sbin/useradd -s /bin/bash -m ritesh;
mkdir /home/ritesh/.ssh;
chmod -R 700 /home/ritesh;
echo "ssh-rsa AAAAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX ritesh@DESKTOP-0XXXXX" >> /home/ritesh/.ssh/authorized_keys;
chmod 600 /home/ritesh/.ssh/authorized_keys;
chown ritesh:ritesh /home/ritesh/.ssh -R;
echo "ritesh  ALL=(ALL)  NOPASSWD:ALL" > /etc/sudoers.d/ritesh;
chmod 440 /etc/sudoers.d/ritesh;

####################################################### Installation of Tomcat ###################################################################

useradd -s /bin/bash -m tomcat-admin;
echo "Password@#795" | passwd tomcat-admin --stdin;
sed -i '0,/PasswordAuthentication no/s//PasswordAuthentication yes/' /etc/ssh/sshd_config;
systemctl reload sshd;
echo "tomcat-admin  ALL=(ALL)  NOPASSWD:ALL" >> /etc/sudoers
yum install -y java-1.8*
cd /opt && wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.100/bin/apache-tomcat-8.5.100.tar.gz
tar -xvf apache-tomcat-8.5.100.tar.gz
mv /opt/apache-tomcat-8.5.100 /opt/apache-tomcat
chown -R tomcat-admin:tomcat-admin /opt/apache-tomcat

cat > /etc/systemd/system/tomcat.service <<EOT
[Unit]
Description=Tomcat Service
Requires=network.target
After=network.target
[Service]
Type=forking
User=root
Environment="CATALINA_PID=/opt/apache-tomcat/logs/tomcat.pid"
Environment="CATALINA_BASE=/opt/apache-tomcat"
Environment="CATALINA_HOME=/opt/apache-tomcat"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
ExecStart=/opt/apache-tomcat/bin/startup.sh
ExecStop=/opt/apache-tomcat/bin/shutdown.sh
Restart=on-abnormal
[Install]
WantedBy=multi-user.target 
EOT

systemctl daemon-reload
systemctl start tomcat && systemctl enable tomcat && systemctl status tomcat
