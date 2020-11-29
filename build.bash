MAVEN_VERSION=3.6.3
TOMCAT_VERSION=9.0.36
CLI_VERSION=1.0
OOP_HOME=$PWD


#install wordnet, verbnet from download
cd $OOP_HOME
if [! -d data ]
then
	mkdir data
fi

cd data
if [! -f dict ]
	wget http://wordnetcode.princeton.edu/wn3.1.dict.tar.gz
	tar xvfz wn3.1.dict.tar.gz
fi

if [! -f verbnet3.3 ]
	wget http://verbs.colorado.edu/verb-index/vn/verbnet-3.3.tar.gz
	tar xvfz verbnet-3.3.tar.gz
fi


#build jverbnet from bugfix branch
cd $OOP_HOME
if [! -f jverbnet ]
	git clone https://github.com/rsadasiv/jverbnet.git --branch bugfix/verbnet33 --single-branch
	cd jverbnet
else
	cd jverbnet
	git pull
fi
mvn install


#build oopcorenlp_parent
cd $OOP_HOME
if [! -d oopcorenlp_parent ]
then
	git clone https://github.com/rsadasiv/oopcorenlp_parent.git
	cd oopcorenlp_parent
else
	cd oopcorenlp_parent
	git pull
fi
mvn clean install

#build oopcorenlp
cd $OOP_HOME
if [! -d oopcorenlp ]
then
	git clone https://github.com/rsadasiv/oopcorenlp.git
	cd oopcorenlp
else
	cd oopcorenlp
	git pull
fi
mvn clean install site


