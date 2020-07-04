sudo yum update -y
sudo yum install git -y
sudo yum install java-11-amazon-corretto -y
sudo yum install wget -y
sudo yum install tar -y

MAVEN_VERSION=3.6.3
TOMCAT_VERSION=9.0.36
CLI_VERSION=1.0

#install maven from download
cd
wget https://downloads.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
tar xvfz apache-maven-$MAVEN_VERSION-bin.tar.gz
PATH=$PATH:~/apache-maven-$MAVEN_VERSION/bin

#configure maven with tomcat deployer password
cd
cp settings.xml .m2/settings.xml

#install tomcat 9 from download
cd
wget https://downloads.apache.org/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
tar xvfz apache-tomcat-$TOMCAT_VERSION.tar.gz

#configure tomcat with deployer password
cd
cp tomcat-users.xml apache-tomcat-$TOMCAT_VERSION/conf/tomcat-users.xml

#install wordnet, verbnet from download
cd
mkdir data
cd data
wget http://wordnetcode.princeton.edu/wn3.1.dict.tar.gz
tar xvfz wn3.1.dict.tar.gz

wget http://verbs.colorado.edu/verb-index/vn/verbnet-3.3.tar.gz
tar xvfz verbnet-3.3.tar.gz

#build jverbnet from bugfix branch
cd
git clone https://github.com/rsadasiv/jverbnet.git --branch bugfix/verbnet33 --single-branch
cd jverbnet
mvn install

#build oopcorenlp
cd
git clone https://github.com/rsadasiv/oopcorenlp.git
cd oopcorenlp
mvn install

#build oopcorenlp_cli
cd
git clone https://github.com/rsadasiv/oopcorenlp_cli.git
cd oopcorenlp_cli
mvn package

#run cli
cd
java -Xms8096m -Xmx10120m -jar oopcorenlp_cli/target/oopcorenlp_cli-$CLI_VERSION.jar --help
