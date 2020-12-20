#!/bin/bash
MAVEN_VERSION=3.6.3
TOMCAT_VERSION=9.0.36
CLI_VERSION=1.0
OOP_HOME=$PWD/..
MAVEN_SUREFIRE_OPTS="-Xmx12g"
export JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto.x86_64
PATH=$PATH:~/apache-maven-$MAVEN_VERSION/bin

set -e

echo "install wordnet, verbnet from download"
cd $OOP_HOME
if [ ! -d data ]
then
	mkdir data
fi

cd data
if [ ! -d dict ]
then
	curl -O https://wordnetcode.princeton.edu/wn3.1.dict.tar.gz
	tar xvfz wn3.1.dict.tar.gz
fi

if [ ! -d verbnet3.3 ]
then
	curl -O https://verbs.colorado.edu/verb-index/vn/verbnet-3.3.tar.gz
	tar xvfz verbnet-3.3.tar.gz
fi


echo "build jverbnet from bugfix branch"
cd $OOP_HOME
if [ ! -d jverbnet ]
then
	git clone https://github.com/rsadasiv/jverbnet.git --branch bugfix/verbnet33 --single-branch
fi	
cd jverbnet
git pull
mvn install


echo "build oopcorenlp_parent"
cd $OOP_HOME
if [ ! -d oopcorenlp_parent ]
then
	git clone https://github.com/rsadasiv/oopcorenlp_parent.git
fi
cd oopcorenlp_parent
git pull
mvn clean install site

echo "build oopcorenlp"
cd $OOP_HOME
if [ ! -d oopcorenlp ]
then
	git clone https://github.com/rsadasiv/oopcorenlp.git
fi
cd oopcorenlp
git pull
MAVEN_OPTS_OLD=$MVN_OPTS
export MAVEN_OPTS=$MAVEN_SUREFIRE_OPTS
mvn clean install site
export MAVEN_OPTS=$MAVEN_OPTS_OLD 

echo "build oopcorenlp_cli"
cd $OOP_HOME
if [ ! -d oopcorenlp_cli ]
then
	git clone https://github.com/rsadasiv/oopcorenlp_cli.git
fi
cd oopcorenlp_cli
git pull
mvn clean install site


echo "build oopcorenlp_corpus"
cd $OOP_HOME
if [ ! -d oopcorenlp_corpus ]
then
	git clone https://github.com/rsadasiv/oopcorenlp_corpus.git
fi
cd oopcorenlp_corpus
git pull
MAVEN_OPTS_OLD=$MVN_OPTS
export MAVEN_OPTS=$MAVEN_SUREFIRE_OPTS
mvn clean install site
export MAVEN_OPTS=$MAVEN_OPTS_OLD 

echo "build oopcorenlp_corpus_cli"
cd $OOP_HOME
if [ ! -d oopcorenlp_corpus_cli ]
then
	git clone https://github.com/rsadasiv/oopcorenlp_corpus_cli.git
fi
cd oopcorenlp_corpus_cli
git pull
mvn clean install site


echo "build oopcorenlp_web"
cd $OOP_HOME
if [ ! -d oopcorenlp_web ]
then
	git clone https://github.com/rsadasiv/oopcorenlp_web.git
fi
cd oopcorenlp_web
git pull

echo "deploy oopcorenlp_corpus sample output to tomcat"
if [ ! -d WebContent/Corpora ]
then
	mkdir WebContent/Corpora
fi
if [ -d WebContent/Corpora/Sample ]
then
	rm -Rf WebContent/Corpora/*
else
	mkdir WebContent/Corpora/Sample
fi
cp -R $OOP_HOME/Corpora_IT/Sample/Sample/* WebContent/Corpora/Sample/
mvn clean install site
rm -Rf WebContent/Corpora/Sample
