FROM 137112412989.dkr.ecr.us-east-1.amazonaws.com/amazonlinux:latest

RUN yum update -y
RUN yum install java-11-amazon-corretto
