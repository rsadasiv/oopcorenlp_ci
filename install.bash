sudo yum update -y
sudo yum install git -y
sudo yum install java-11-amazon-corretto -y
sudo yum install wget -y
sudo yum install tar -y

MAVEN_VERSION=3.6.3
TOMCAT_VERSION=9.0.36
CLI_VERSION=1.0
OOP_HOME=$PWD

set -e

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

#run cli
cd $OOP_HOME
if [ ! -d Sample ]
then
	mkdir Sample
	cd Sample
	mkdir Chekhov
	mkdir Maupassant
	mkdir Wodehouse
	mkdir OHenry
else
	rm -Rf ./Sample/Chekhov/*
	rm -Rf ./Sample/Maupassant/*
	rm -Rf ./Sample/Wodehouse/*
	rm -Rf ./Sample/OHenry/*
fi

cd $OOP_HOME
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action generate --outputPath ./Sample
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/ChekhovBatch.json
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/MaupassantBatch.json
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/WodehouseBatch.json
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/OHenryBatch.json

#deploy Analyze output to tomcat
cd $OOP_HOME
cd oopcorenlp_web
mkdir WebContent/Corpora/Chekhov
cp -R $OOP_HOME/Corpora_IT/Gutenberg/Chekhov/* WebContent/Corpora/Chekhov/
mkdir WebContent/Corpora/Maupassant
cp -R $OOP_HOME/Corpora_IT/Gutenberg/Maupassant/* WebContent/Corpora/Maupassant/
mkdir WebContent/Corpora/Wodehouse
cp -R $OOP_HOME/Corpora_IT/Ebook/Wodehouse/* WebContent/Corpora/Wodehouse/
mkdir WebContent/Corpora/OHenry
cp -R $OOP_HOME/Corpora_IT/Wikisource/OHenry/* WebContent/Corpora/OHenry/

#build oopcorenlp
cd $OOP_HOME
cd oopcorenlp_web
mvn -DSkipITs package

