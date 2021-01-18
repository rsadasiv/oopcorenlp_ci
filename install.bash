sudo yum update -y
sudo yum install git -y
git config --global credential.helper 'cache --timeout=3600'
sudo yum install java-11-amazon-corretto -y
JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto.x86_64
sudo yum install wget -y
sudo yum install tar -y

MAVEN_VERSION=3.6.3
TOMCAT_VERSION=9.0.36
CLI_VERSION=1.0
OOP_HOME=$PWD/..
MAVEN_SUREFIRE_OPTS="-Xmx12g"
export JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto.x86_64
PATH=$PATH:~/apache-maven-$MAVEN_VERSION/bin
set -e

echo "install maven from download"
cd $OOP_HOME
if [ ! -d apache-maven-$MAVEN_VERSION ] 
then
	wget https://downloads.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
	tar xvfz apache-maven-$MAVEN_VERSION-bin.tar.gz
fi
PATH=$PATH:~/apache-maven-$MAVEN_VERSION/bin

echo "configure maven with tomcat deployer password"
cd $OOP_HOME
if [ ! -d .m2 ]
then
	mkdir .m2
fi
cp $OOP_HOME/oopcorenlp_ci/settings.xml $OOP_HOME/.m2/settings.xml

echo "install tomcat 9 from download"
cd $OOP_HOME
if [ ! -d apache-tomcat-$TOMCAT_VERSION ] 
then
	wget https://downloads.apache.org/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
	tar xvfz apache-tomcat-$TOMCAT_VERSION.tar.gz
fi

echo "configure tomcat with deployer password"
cd $OOP_HOME
cp $OOP_HOME/oopcorenlp_ci/tomcat-users.xml apache-tomcat-$TOMCAT_VERSION/conf/tomcat-users.xml

cd $OOP_HOME/oopcorenlp_ci
./build.bash

echo "run oopcorenlp_cli"
cd $OOP_HOME
java -Xms8096m -Xmx10120m -jar oopcorenlp_cli/target/oopcorenlp_cli-$CLI_VERSION.jar --action generate
java -Xms8096m -Xmx10120m -jar oopcorenlp_cli/target/oopcorenlp_cli-$CLI_VERSION.jar --action analyze --outputPath ./AnalyzeIT


echo "run oopcorenlp_corpus_cli"
cd $OOP_HOME
#ensure directory structure exists and is empty
if [ ! -d Sample ]
then
	mkdir Sample
fi
cd Sample
if [ ! -d Corpora ]
then
	mkdir Corpora
fi
cd Corpora
if [ ! -d Gutenberg ]
then
	mkdir Gutenberg
else
	cd Gutenberg
	rm -Rf ./Gutenberg/*
fi
if [ ! -d EBook ]
then
	mkdir EBook
else
	rm -Rf ./EBook/*
fi
if [ ! -d Wikisource ]
then
	mkdir Wikisource
else
	rm -Rf ./Wikisource/*
fi
if [ ! -d All ]
then
	mkdir All
else
	rm -Rf ./All/*
fi

cd $OOP_HOME
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action generate --outputPath ./Sample
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/ChekhovBatch.json
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/MaupassantBatch.json
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/WodehouseBatch.json
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/OHenryBatch.json
java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action aggregate --outputPath ./Sample --inputBatch ./Sample/Corpora/Gutenberg/Chekhov/ChekhovBatch.json --inputBatch ./Sample/Corpora/Gutenberg/Maupassant/MaupassantBatch.json --inputBatch ./Sample/Corpora/EBook/Wodehouse/WodehouseBatch.json --inputBatch ./Sample/Corpora/Wikisource/OHenry/OHenryBatch.json


echo "copy oopcorenlp_corpus_cli output to oopcorenlp_web"
cd $OOP_HOME
cd oopcorenlp_web

#ensure directory structure exists and is empty
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

echo "build oopcorenlp_web"
cd $OOP_HOME
cd oopcorenlp_web
mvn -DSkipITs package

echo "start tomcat"
cd $OOP_HOME
apache-tomcat-$TOMCAT_VERSION/bin/startup.sh

echo "deploy oopcorenlp_web to tomcat"
cd oopcorenlp_web
mvn tomcat7:deploy

echo "stop tomcat"
cd $OOP_HOME
apache-tomcat-$TOMCAT_VERSION/bin/shutdown.sh
