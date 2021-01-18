aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 137112412989.dkr.ecr.us-east-1.amazonaws.com
docker pull 137112412989.dkr.ecr.us-east-1.amazonaws.com/amazonlinux:latest

docker build -t tomcat:latest -f tomcat.dockerfile .
cp ../oopcorenlp_web/target/oopcorenlp_web.war .
docker build -t oopcorenlp_web:latest -f oopcorenlp_web.dockerfile .
docker run -p 8080:8080 oopcorenlp_web:latest