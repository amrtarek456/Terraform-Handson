#!/bin/bash 
sudo yum -y update && sudo yum -y install httpd
sudo systemctl start httpd && sudo systemctl enable httpd 
sudo echo "<h1>Hello from Public instance</h1>" | sudo tee /var/www/html/index.html

sudo yum -y install docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user
sudo docker container run -d -p 8080:80 nginx