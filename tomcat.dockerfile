FROM corretto11:latest

RUN yum update -y
RUN yum install wget tar -y
RUN wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.41/bin/apache-tomcat-9.0.41.tar.gz
RUN tar xvfz apache-tomcat-9.0.41.tar.gz
