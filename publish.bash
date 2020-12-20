#!/bin/bash
OOP_HOME=$PWD/..
#./build.bash

set -e

#publish docs
cd $OOP_HOME
if [ ! -d rsadasiv.github.io ]
then
	git clone https://github.com/rsadasiv/rsadasiv.github.io.git
fi
cd rsadasiv.github.io
git pull

#publish oopcorenlp_parent
if [ ! -d oopcorenlp_parent ]
then
	mkdir oopcorenlp_parent
fi
cp -R $OOP_HOME/oopcorenlp_parent/target/site/* oopcorenlp_parent

#publish oopcorenlp
if [ ! -d oopcorenlp ]
then
	mkdir oopcorenlp
fi
cp -R $OOP_HOME/oopcorenlp/target/site/* oopcorenlp/

#publish oopcorenlp_cli
if [ ! -d oopcorenlp_cli ]
then
	mkdir oopcorenlp_cli
fi
cp -R $OOP_HOME/oopcorenlp_cli/target/site/* oopcorenlp_cli/

#publish oopcorenlp_corpus
if [ ! -d oopcorenlp_corpus ]
then
	mkdir oopcorenlp_corpus
fi
cp -R $OOP_HOME/oopcorenlp_corpus/target/site/* oopcorenlp_corpus/

#publish oopcorenlp_corpus_cli
if [ ! -d oopcorenlp_corpus_cli ]
then
	mkdir oopcorenlp_corpus_cli
fi
cp -R $OOP_HOME/oopcorenlp_corpus_cli/target/site/* oopcorenlp_corpus_cli/

#publish oopcorenlp_web
if [ ! -d oopcorenlp_web ]
then
	mkdir oopcorenlp_web
fi
cp -R $OOP_HOME/oopcorenlp_web/target/site/* oopcorenlp_web/
