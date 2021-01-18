FROM tomcat:latest

COPY oopcorenlp_web.war ./apache-tomcat-9.0.41/webapps/
RUN cd ./apache-tomcat-9.0.41/webapps && jar -x -f oopcorenlp_web.war
CMD ["./apache-tomcat-9.0.41/bin/catalina.sh", "run"]
