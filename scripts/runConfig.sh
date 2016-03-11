#!/bin/sh
# configure the runnning instance of OpenAM

OPENAM_ADMIN=amadmin
CLIENT_SECRET=secret01
REDIRECT_URI=http://iam.example.com:8080/api/teams
OPENAM_REALM=/
AGENT_TYPE=OAuth2Client
PWDFILE=pwd.file


cd /usr/local/tomcat
bin/catalina.sh start

# add the host first
echo "127.0.0.1 iam.example.com" >> /etc/hosts
cd /root/openam-tools/config/
# start the configuration of the running instance
sleep 5;java -Djavax.net.ssl.trustStore=/opt/server.keystore \
      -jar openam-configurator-tool-13.0.0.jar \
      --file config.properties -acceptLicense

cd /root/openam-tools/admin/

mkdir debug;mkdir log;./setup --acceptLicense --path "/root/openam" --debug "/root/openam-tools/admin/debug" --log "/root/openam-tools/admin/log"

echo "OAPassW0rd" > pwd.file
echo "password" > pwd2.file
echo "AQICypKNmlMn7lEoqnyxDMmwBV3B0pvIxmbP" > pwdenc1.file
echo "AQICypKNmlMn7lGc7tpGRZY7HSOmLETOgBpm" > pwdenc2.file
chmod 0400 *.file
# echo "pwd file 1"
# ./openam/bin/ssoadm create-realm -d -u amadmin -f pwd.file -e $OPENAM_REALM
# echo "pwd file 2"
# ./openam/bin/ssoadm create-realm  -d -u amadmin -f pwd2.file -e $OPENAM_REALM
echo "pwd file 3"
# ./openam/bin/ssoadm create-realm -d -u amadmin -f pwdenc1.file -e $OPENAM_REALM
echo "pwd file 4"
# ./openam/bin/ssoadm create-realm -d -u amadmin -f pwdenc2.file -e $OPENAM_REALM
#
# ./openam/bin/ssoadm add-svc-realm \
# 	--verbose \
# 	--realm $OPENAM_REALM \
# 	--servicename OAuth2Provider \
#     --adminid $OPENAM_ADMIN \
#     --password-file $PWDFILE \
#     --attributevalues \
# 	"forgerock-oauth2-provider-authorization-code-lifetime=60" \
# 	"forgerock-oauth2-provider-issue-refresh-token=false" \
# 	"forgerock-oauth2-provider-scope-implementation-class=org.forgerock.openam.oauth2.provider.impl.ScopeImpl" \
# 	"forgerock-oauth2-provider-refresh-token-lifetime=60000000" \
# 	"forgerock-oauth2-provider-refresh-token-lifetime=60000000"
#
# # Create the OIDC/OAuth2 Agent
# ./openam/bin/ssoadm create-agent \
# 	--verbose \
# 	--agentname $CLIENT_ID \
# 	--agenttype $AGENT_TYPE \
# 	--realm $OPENAM_REALM \
#   	--adminid $OPENAM_ADMIN \
#   	--password-file $PWDFILE \
#   	--attributevalues \
#   	"com.forgerock.openam.oauth2provider.responseTypes[0]=code" \
# 	"com.forgerock.openam.oauth2provider.responseTypes[1]=token" \
# 	"com.forgerock.openam.oauth2provider.responseTypes[2]=id_token" \
# 	"com.forgerock.openam.oauth2provider.responseTypes[3]=code token" \
# 	"com.forgerock.openam.oauth2provider.responseTypes[4]=token id_token" \
# 	"com.forgerock.openam.oauth2provider.responseTypes[5]=code id_token" \
# 	"com.forgerock.openam.oauth2provider.responseTypes[6]=code token id_token" \
# 	"com.forgerock.openam.oauth2provider.description[0]=" \
# 	"com.forgerock.openam.oauth2provider.contacts[0]=" \
#   	"com.forgerock.openam.oauth2provider.redirectionURIs[0]=$REDIRECT_URI" \
# 	"sunIdentityServerDeviceStatus=Active" \
# 	"userpassword=$CLIENT_SECRET" \
# 	"com.forgerock.openam.oauth2provider.defaultScopes[0]=" \
# 	"com.forgerock.openam.oauth2provider.scopes[0]=openid|OIDC" \
# 	"com.forgerock.openam.oauth2provider.scopes[1]=email|Email" \
# 	"com.forgerock.openam.oauth2provider.scopes[2]=profile|Profile" \
# 	"com.forgerock.openam.oauth2provider.clientType=Confidential" \
# 	"com.forgerock.openam.oauth2provider.idTokenSignedResponseAlg=HS256" \
# 	"com.forgerock.openam.oauth2provider.name[0]=OIDC Apache module"
#
# ./openam/bin/ssoadm create-policies --realm / --adminid ${OPENAM_ADMIN} --password-file ${PWDFILE} --xmlfile oauth2-policy.xml