sudo yum update -y
sudo yum install git -y
sudo yum install java-11-amazon-corretto -y
sudo yum install wget -y
sudo yum install tar -y

MAVEN_VERSION=3.6.3
TOMCAT_VERSION=9.0.36
CLI_VERSION=1.0
OOP_HOME=$PWD

#install maven from download
cd $OOP_HOME
wget https://downloads.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
tar xvfz apache-maven-$MAVEN_VERSION-bin.tar.gz
PATH=$PATH:~/apache-maven-$MAVEN_VERSION/bin

#configure maven with tomcat deployer password
cd $OOP_HOME
cp settings.xml .m2/settings.xml

#install tomcat 9 from download
cd $OOP_HOME
wget https://downloads.apache.org/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
tar xvfz apache-tomcat-$TOMCAT_VERSION.tar.gz

#configure tomcat with deployer password
cd $OOP_HOME
cp tomcat-users.xml apache-tomcat-$TOMCAT_VERSION/conf/tomcat-users.xml

#install wordnet, verbnet from download
cd $OOP_HOME
mkdir data
cd data
wget http://wordnetcode.princeton.edu/wn3.1.dict.tar.gz
tar xvfz wn3.1.dict.tar.gz

wget http://verbs.colorado.edu/verb-index/vn/verbnet-3.3.tar.gz
tar xvfz verbnet-3.3.tar.gz

#build jverbnet from bugfix branch
cd $OOP_HOME
git clone https://github.com/rsadasiv/jverbnet.git --branch bugfix/verbnet33 --single-branch
cd jverbnet
mvn install

#build oopcorenlp_parent
cd $OOP_HOME
git clone https://github.com/rsadasiv/oopcorenlp_parent.git
cd oopcorenlp_parent
mvn install

#build oopcorenlp
cd $OOP_HOME
git clone https://github.com/rsadasiv/oopcorenlp.git
cd oopcorenlp
mvn install

#download oopcorenlp_web
cd $OOP_HOME
git clone https://github.com/rsadasiv/oopcorenlp_web.git


#build oopcorenlp_cli
cd $OOP_HOME
git clone https://github.com/rsadasiv/oopcorenlp_cli.git
cd oopcorenlp_cli
mvn package

#run cli
cd $OOP_HOME
java -Xms8096m -Xmx10120m -jar oopcorenlp_cli/target/oopcorenlp_cli-$CLI_VERSION.jar --action generate
java -Xms8096m -Xmx10120m -jar oopcorenlp_cli/target/oopcorenlp_cli-$CLI_VERSION.jar --action analyze --outputPath oopcorenlp_web/WebContent/Corpora/Sample

#build oopcorenlp_web
cd oopcorenlp_web
mvn install

#start tomcat
cd $OOP_HOME
apache-tomcat-$TOMCAT_VERSION/bin/startup.sh

#deploy oopcorenlp_web
cd oopcorenlp_web
mvn tomcat7:deploy

#stop tomcat
cd $OOP_HOME
apache-tomcat-$TOMCAT_VERSION/bin/shutdown.sh

#build oopcorenlp_corpus
cd $OOP_HOME
git clone https://github.com/rsadasiv/oopcorenlp_corpus.git
cd oopcorenlp_corpus
mvn install


#oopcorenlp.properties must exist in ./Sample/
#run cli
cd $OOP_HOME
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action generate --outputPath ./Sample
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/ChekhovBatch.json
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/MaupassantBatch.json
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/WodehouseBatch.json
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/OHenryBatch.json

#deploy Analyze output to tomcat
mkdir oopcorenlp_web/WebContent/Corpora/Chekhov
cp ./Sample/Corpora/Gutenberg/Chekhov/Analyze/* oopcorenlp_web/WebContent/Corpora/Chekhov/
mkdir oopcorenlp_web/WebContent/Corpora/Maupassant
cp ./Sample/Corpora/Gutenberg/Maupassant/Analyze/* oopcorenlp_web/WebContent/Corpora/Maupassant/
mkdir oopcorenlp_web/WebContent/Corpora/Wodehouse
cp ./Sample/Corpora/EBook/Wodehouse/Analyze/* oopcorenlp_web/WebContent/Corpora/Wodehouse/
mkdir oopcorenlp_web/WebContent/Corpora/OHenry
cp ./Sample/Corpora/Wikisource/OHenry/Analyze/* oopcorenlp_web/WebContent/Corpora/OHenry/


for f in TEXT_*; do mv "$f" "${f/TEXT_/TXT_}";done
