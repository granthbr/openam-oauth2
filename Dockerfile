FROM tomcat:8-jre8

MAINTAINER Brandon Grantham <brandon.grantham@gmail.com> 

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
WORKDIR $CATALINA_HOME

# only exposing the https port. If you need http, uncommment the line below:
# EXPOSE 8080

# https
EXPOSE 8443

ARG OPENAM_VERSION=13.0.0
ENV OPENAM_DOWNLOAD_URL http://maven.forgerock.org/repo/releases/org/forgerock/openam/openam-server/${OPENAM_VERSION}/openam-server-${OPENAM_VERSION}.war
ENV CATALINA_OPTS="-Xmx2048m -server"

RUN curl -#fL "${OPENAM_DOWNLOAD_URL}" -o openam.war \
    && unzip openam.war -d $CATALINA_HOME/webapps/openam \
    && rm -f openam.war 

# Thanks to matosf
# set the password for the keystore. For the purpose of security, change the password before builing for deployment to prod
ARG OPENAM_KEYSTORE_PASSWORD=AP@55word
RUN openssl req -new -newkey rsa:2048 -nodes -out /opt/server.csr -keyout /opt/server.key -subj "/C=US/ST=SanFrancisco/L=SanFrancisco/O=SierraCedar SE/OU=Technology/CN=iam.example.com" \
    && openssl x509 -req -days 365 -in /opt/server.csr -signkey /opt/server.key -out /opt/server.crt \
    && openssl pkcs12 -export -in /opt/server.crt -inkey /opt/server.key -out /opt/server.p12 -name tomcat -password pass:${OPENAM_KEYSTORE_PASSWORD} \
   && keytool -importkeystore -deststorepass ${OPENAM_KEYSTORE_PASSWORD} -destkeypass ${OPENAM_KEYSTORE_PASSWORD} -destkeystore /opt/server.keystore -srckeystore /opt/server.p12 -srcstoretype PKCS12 -srcstorepass ${OPENAM_KEYSTORE_PASSWORD} -alias tomcat

# add SSL to server.xml  and upload to the server
ADD configs/server.xml ${CATALINA_HOME}/conf/
# Add CORS to web.xml
ADD configs/web.xml ${CATALINA_HOME}/conf/
RUN sed -i "s/KEYSTORE_PASSWORD_PLACEHOLDER/${OPENAM_KEYSTORE_PASSWORD}/g" ${CATALINA_HOME}/conf/server.xml

# add the config properties for the configuration
ADD configs/config.properties /root/openam-tools/config/
ADD configs/oauth2-policy.xml /root/openam-tools/admin/
# copy the configurator and run start scripts
ADD tools/SSOConfiguratorTools* /root/openam-tools/config/
ADD tools/SSOAdminTools-13.0.0.zip /root/openam-tools/admin/
# start Tomcat for the configurator
ADD scripts/runConfig.sh /root/openam-tools/
WORKDIR /root/openam-tools
RUN unzip -d config/ config/SSOConfiguratorTools-13.0.0.zip && \
     rm /root/openam-tools/config/SSOConfiguratorTools-13.0.0.zip 
     unzip -d admin/ admin/SSOAdminTools-13.0.0.zip && \
     rm /root/openam-tools/admin/SSOAdminTools-13.0.0.zip && \ 
     sed -i "s/KEYSTORE_PASSWORD_PLACEHOLDER/${OPENAM_KEYSTORE_PASSWORD}/g" ${CATALINA_HOME}/conf/server.xml && \
     /root/openam-tools/runConfig.sh

# add SSO admin tools and setup
# ADD tools/SSOAdminTools-13.0.0.zip /root/openam-admin/
# WORKDIR /root/openam-admin
# RUN unzip SSOAdminTools-13.0.0.zip
# RUN rm /root/openam-admin/SSOAdminTools-13.0.0.zip
# RUN ./setup --acceptLicense --path "/root/openam" --debug "/root/openam-tools/admin/debug" --log "/root/openam-tools/admin/log"
# ADD scripts/adminSetup.sh /root/openam-admin/
# RUN ./adminSetup.sh
# configure oauth2 via ssoAdmin tools

#return to tomcat directory for home
WORKDIR $CATALINA_HOME
# cp start script and set commands
ADD scripts/run.sh /tmp/run.sh
CMD ["/tmp/run.sh"]
