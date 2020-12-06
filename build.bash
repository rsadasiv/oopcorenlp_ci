#!/bin/bash
MAVEN_VERSION=3.6.3
TOMCAT_VERSION=9.0.36
CLI_VERSION=1.0
OOP_HOME=$PWD/..

set -e

#install wordnet, verbnet from download
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


#build jverbnet from bugfix branch
cd $OOP_HOME
if [ ! -d jverbnet ]
then
	git clone https://github.com/rsadasiv/jverbnet.git --branch bugfix/verbnet33 --single-branch
fi	
cd jverbnet
git pull
mvn install


#build oopcorenlp_parent
cd $OOP_HOME
if [ ! -d oopcorenlp_parent ]
then
	git clone https://github.com/rsadasiv/oopcorenlp_parent.git
fi
cd oopcorenlp_parent
git pull
mvn clean install site

#build oopcorenlp
cd $OOP_HOME
if [ ! -d oopcorenlp ]
then
	git clone https://github.com/rsadasiv/oopcorenlp.git
fi
cd oopcorenlp
git pull
mvn clean install site

#build oopcorenlp_corpus
cd $OOP_HOME
if [ ! -d oopcorenlp_corpus ]
then
	git clone https://github.com/rsadasiv/oopcorenlp_corpus.git
fi
cd oopcorenlp_corpus
git pull
mvn clean install site

#build oopcorenlp_corpus_cli
cd $OOP_HOME
git clone https://github.com/rsadasiv/oopcorenlp_corpus_cli.git
cd oopcorenlp_corpus_cli
mvn install site


#oopcorenlp.properties must exist in ./Sample/
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

#build oopcorenlp_web
cd $OOP_HOME
if [ ! -d oopcorenlp_web ]
then
	git clone https://github.com/rsadasiv/oopcorenlp_web.git
fi
cd oopcorenlp_web
git pull

#deploy Analyze output to tomcat
mkdir oopcorenlp_web/WebContent/Corpora/Chekhov
cp ./Sample/Corpora/Gutenberg/Chekhov/Analyze/* oopcorenlp_web/WebContent/Corpora/Chekhov/
mkdir oopcorenlp_web/WebContent/Corpora/Maupassant
cp ./Sample/Corpora/Gutenberg/Maupassant/Analyze/* oopcorenlp_web/WebContent/Corpora/Maupassant/
mkdir oopcorenlp_web/WebContent/Corpora/Wodehouse
cp ./Sample/Corpora/EBook/Wodehouse/Analyze/* oopcorenlp_web/WebContent/Corpora/Wodehouse/
mkdir oopcorenlp_web/WebContent/Corpora/OHenry
cp ./Sample/Corpora/Wikisource/OHenry/Analyze/* oopcorenlp_web/WebContent/Corpora/OHenry/

#build oopcorenlp
cd $OOP_HOME
cd oopcorenlp_web
mvn clean install site

#corpus cleanup
#rm -Rf oopcorenlp_web/WebContent/Corpora/*

#publish docs
cd $OOP_HOME
if [ ! -d rsadasiv.github.io ]
then
	git clone https://github.com/rsadasiv/rsadasiv.github.io.git
fi
cd rsadasiv.github.io
git pull
