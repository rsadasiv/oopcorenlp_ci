FROM 137112412989.dkr.ecr.us-east-1.amazonaws.com/amazonlinux:latest

RUN yum update -y
RUN yum install java-11-amazon-corretto wget tar -y
RUN wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.41/bin/apache-tomcat-9.0.41.tar.gz
RUN tar xvfz apache-tomcat-9.0.41.tar.gz
