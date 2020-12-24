sudo yum update -y
sudo yum install git -y
git config --global credential.helper 'cache --timeout=3600'
sudo yum install java-11-amazon-corretto -y
JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto.x86_64
sudo yum install wget -y
sudo yum install tar -y

MAVEN_VERSION=3.6.3
TOMCAT_VERSION=9.0.41
CLI_VERSION=1.0
OOP_HOME=$PWD/..
set -e

#install maven from download
cd $OOP_HOME
if [ ! -d apache-maven-$MAVEN_VERSION ] 
then
	wget https://downloads.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
	tar xvfz apache-maven-$MAVEN_VERSION-bin.tar.gz
fi
PATH=$PATH:~/apache-maven-$MAVEN_VERSION/bin

#configure maven with tomcat deployer password
cd $OOP_HOME
if [ ! -d .m2 ]
then
	mkdir .m2
fi
cp $OOP_HOME/oopcorenlp_ci/settings.xml $OOP_HOME/.m2/settings.xml

#install tomcat 9 from download
cd $OOP_HOME
if [ ! -d apache-tomcat-$TOMCAT_VERSION ] 
then
	wget https://downloads.apache.org/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
	tar xvfz apache-tomcat-$TOMCAT_VERSION.tar.gz
fi
#configure tomcat with deployer password
cd $OOP_HOME
cp $OOP_HOME/oopcorenlp_ci/tomcat-users.xml apache-tomcat-$TOMCAT_VERSION/conf/tomcat-users.xml

cd $OOP_HOME/oopcorenlp_ci
./build.bash

#run cli
cd $OOP_HOME
java -Xms8096m -Xmx10120m -jar oopcorenlp_cli/target/oopcorenlp_cli-$CLI_VERSION.jar --action generate
java -Xms8096m -Xmx10120m -jar oopcorenlp_cli/target/oopcorenlp_cli-$CLI_VERSION.jar --action analyze --outputPath ./AnalyzeIT


#run corpus cli
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
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action aggregate --inputBatchPath ./Sample/Corpora/Gutenberg/Chekhov/ChekhovBatch.json --inputBatchPath ./Sample/Corpora/Gutenberg/Maupassant/MaupassantBatch.json --inputBatchPath ./Sample/Corpora/EBook/Wodehouse/WodehouseBatch.json --inputBatchPath ./Sample/Corpora/Wikisource/OHenry/OHenryBatch.json


#deploy Analyze output to tomcat
cd $OOP_HOME
cd oopcorenlp_web

if [ ! -d WebContent/Corpora ]
then
        mkdir WebContent/Corpora
else
        rm -Rf WebContent/Corpora/*
fi

mkdir WebContent/Corpora/Chekhov
cp -R $OOP_HOME/Sample/Corpora/Gutenberg/Chekhov/* WebContent/Corpora/Chekhov/
mkdir WebContent/Corpora/Maupassant
cp -R $OOP_HOME/Sample/Corpora/Gutenberg/Maupassant/* WebContent/Corpora/Maupassant/
mkdir WebContent/Corpora/Wodehouse
cp -R $OOP_HOME/Sample/Corpora/EBook/Wodehouse/* WebContent/Corpora/Wodehouse/
mkdir WebContent/Corpora/OHenry
cp -R $OOP_HOME/Sample/Corpora/Wikisource/OHenry/* WebContent/Corpora/OHenry/
mkdir WebContent/Corpora/All
cp -R $OOP_HOME/Sample/Corpora/All/All/* WebContent/Corpora/All/

#build oopcorenlp
cd $OOP_HOME
cd oopcorenlp_web
mvn -DSkipITs package

#start tomcat
cd $OOP_HOME
apache-tomcat-$TOMCAT_VERSION/bin/startup.sh

#deploy oopcorenlp_web
cd oopcorenlp_web
mvn tomcat7:deploy

#stop tomcat
cd $OOP_HOME
apache-tomcat-$TOMCAT_VERSION/bin/shutdown.sh
