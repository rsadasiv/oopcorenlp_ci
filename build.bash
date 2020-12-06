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

echo "build jverbnet"
#build jverbnet from bugfix branch
cd $OOP_HOME
if [ ! -d jverbnet ]
then
	git clone https://github.com/rsadasiv/jverbnet.git --branch bugfix/verbnet33 --single-branch
fi
cd jverbnet
git pull
#mvn install

echo "build oopcorenlp_parent"
#build oopcorenlp_parent
cd $OOP_HOME
if [ ! -d oopcorenlp_parent ]
then
	git clone https://github.com/rsadasiv/oopcorenlp_parent.git
fi
cd oopcorenlp_parent
git pull
#mvn clean install site

echo "build oopcorenlp"
#build oopcorenlp
cd $OOP_HOME
if [ ! -d oopcorenlp ]
then
	git clone https://github.com/rsadasiv/oopcorenlp.git
fi
cd oopcorenlp
git pull
#mvn clean install site

echo "build oopcorenlp_corpus"
#build oopcorenlp_corpus
cd $OOP_HOME
if [ ! -d oopcorenlp_corpus ]
then
	git clone https://github.com/rsadasiv/oopcorenlp_corpus.git
fi
cd oopcorenlp_corpus
git pull
#mvn clean install site

echo "build oopcorenlp_corpus_cli"
#build oopcorenlp_corpus_cli
cd $OOP_HOME
if [ ! -d oopcorenlp_corpus_cli ]
then
	git clone https://github.com/rsadasiv/oopcorenlp_corpus_cli.git
fi
cd oopcorenlp_corpus_cli
git pull
#mvn install site

echo "run oopcorenlp_corpus_cli"
#run cli
cd $OOP_HOME
# java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action generate --outputPath ./Sample
# java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/ChekhovBatch.json
# java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/MaupassantBatch.json
# java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/WodehouseBatch.json
# java -Xms8096m -Xmx10120m -jar oopcorenlp_corpus_cli/target/oopcorenlp_corpus_cli-$CLI_VERSION.jar --action analyze --inputPath ./Sample/OHenryBatch.json


echo "download oopcorenlp_web"
#download oopcorenlp_web
cd $OOP_HOME
if [ ! -d oopcorenlp_web ]
then
	git clone https://github.com/rsadasiv/oopcorenlp_web.git
fi
cd oopcorenlp_web
git pull

echo "deploy oopcorenlp_corpus output to ooopcorenlp_web"
#deploy Analyze output to tomcat
# cd $OOP_HOME
# #Chekhov
# mkdir -p oopcorenlp_web/WebContent/Corpora/Chekhov
# cp ./Sample/Corpora/Gutenberg/Chekhov/Analyze/* oopcorenlp_web/WebContent/Corpora/Chekhov/
# cp ./Sample/Corpora/Gutenberg/Chekhov/CorpusAggregate/* oopcorenlp_web/WebContent/Corpora/Chekhov/
# cp ./Sample/Corpora/Gutenberg/Chekhov/ChekhovBatch.json oopcorenlp_web/WebContent/Corpora/Chekhov/
#
# mkdir -p oopcorenlp_web/WebContent/Corpora/Chekhov/CoreNLPTfidf
# cp -r ./Sample/Corpora/Gutenberg/Chekhov/CoreNLPTfidf oopcorenlp_web/WebContent/Corpora/Chekhov/CoreNLPTfidf
# mkdir -p oopcorenlp_web/WebContent/Corpora/Chekhov/CoreNLPZ
# cp -r ./Sample/Corpora/Gutenberg/Chekhov/CoreNLPZ oopcorenlp_web/WebContent/Corpora/Chekhov/CoreNLPZ
# mkdir -p oopcorenlp_web/WebContent/Corpora/Chekhov/Word2Vec
# cp -r ./Sample/Corpora/Gutenberg/Chekhov/Word2Vec oopcorenlp_web/WebContent/Corpora/Chekhov/Word2Vec
#
# #Maupassant
# mkdir -p oopcorenlp_web/WebContent/Corpora/Maupassant
# cp ./Sample/Corpora/Gutenberg/Maupassant/Analyze/* oopcorenlp_web/WebContent/Corpora/Maupassant/
# cp ./Sample/Corpora/Gutenberg/Maupassant/CorpusAggregate/* oopcorenlp_web/WebContent/Corpora/Maupassant/
# cp ./Sample/Corpora/Gutenberg/Maupassant/MaupassantBatch.json oopcorenlp_web/WebContent/Corpora/Maupassant/
#
# mkdir -p oopcorenlp_web/WebContent/Corpora/Maupassant/CoreNLPTfidf
# cp -r ./Sample/Corpora/Gutenberg/Maupassant/CoreNLPTfidf oopcorenlp_web/WebContent/Corpora/Maupassant/CoreNLPTfidf
# mkdir -p oopcorenlp_web/WebContent/Corpora/Maupassant/CoreNLPZ
# cp -r ./Sample/Corpora/Gutenberg/Maupassant/CoreNLPZ oopcorenlp_web/WebContent/Corpora/Maupassant/CoreNLPZ
# mkdir -p oopcorenlp_web/WebContent/Corpora/Maupassant/Word2Vec
# cp -r ./Sample/Corpora/Gutenberg/Maupassant/Word2Vec oopcorenlp_web/WebContent/Corpora/Maupassant/Word2Vec
#
# #Wodehouse
# mkdir -p oopcorenlp_web/WebContent/Corpora/Wodehouse
# cp ./Sample/Corpora/EBook/Wodehouse/Analyze/* oopcorenlp_web/WebContent/Corpora/Wodehouse/
# cp ./Sample/Corpora/EBook/Wodehouse/CorpusAggregate/* oopcorenlp_web/WebContent/Corpora/Wodehouse/
# cp ./Sample/Corpora/EBook/Wodehouse/WodehouseBatch.json oopcorenlp_web/WebContent/Corpora/Wodehouse/
#
# mkdir -p oopcorenlp_web/WebContent/Corpora/Wodehouse/CoreNLPTfidf
# cp -r ./Sample/Corpora/EBook/Wodehouse/CoreNLPTfidf oopcorenlp_web/WebContent/Corpora/Wodehouse/CoreNLPTfidf
# mkdir -p oopcorenlp_web/WebContent/Corpora/Wodehouse/CoreNLPZ
# cp -r ./Sample/Corpora/EBook/Wodehouse/CoreNLPZ oopcorenlp_web/WebContent/Corpora/Wodehouse/CoreNLPZ
# mkdir -p oopcorenlp_web/WebContent/Corpora/Wodehouse/Word2Vec
# cp -r ./Sample/Corpora/EBook/Wodehouse/Word2Vec oopcorenlp_web/WebContent/Corpora/Wodehouse/Word2Vec
#
# #OHenry
# mkdir -p oopcorenlp_web/WebContent/Corpora/OHenry
# cp ./Sample/Corpora/Wikisource/OHenry/Analyze/* oopcorenlp_web/WebContent/Corpora/OHenry/
# cp ./Sample/Corpora/Wikisource/OHenry/CorpusAggregate/* oopcorenlp_web/WebContent/Corpora/OHenry/
# cp ./Sample/Corpora/Wikisource/OHenry/OHenryBatch.json oopcorenlp_web/WebContent/Corpora/OHenry/
#
# mkdir -p oopcorenlp_web/WebContent/Corpora/OHenry/CoreNLPTfidf
# cp -r ./Sample/Corpora/Wikisource/OHenry/CoreNLPTfidf oopcorenlp_web/WebContent/Corpora/OHenry/CoreNLPTfidf
# mkdir -p oopcorenlp_web/WebContent/Corpora/OHenry/CoreNLPZ
# cp -r ./Sample/Corpora/Wikisource/OHenry/CoreNLPZ oopcorenlp_web/WebContent/Corpora/OHenry/CoreNLPZ
# mkdir -p oopcorenlp_web/WebContent/Corpora/OHenry/Word2Vec
# cp -r ./Sample/Corpora/Wikisource/OHenry/Word2Vec oopcorenlp_web/WebContent/Corpora/OHenry/Word2Vec


echo "build ooopcorenlp_web"
#build oopcorenlp
cd $OOP_HOME
cd oopcorenlp_web
mvn -DskipITs clean install site

#corpus cleanup
#rm -Rf oopcorenlp_web/WebContent/Corpora/*

echo "publish docs"
#publish docs
cd $OOP_HOME
if [ ! -d rsadasiv.github.io ]
then
	git clone https://github.com/rsadasiv/rsadasiv.github.io.git
fi
cd rsadasiv.github.io
git pull
