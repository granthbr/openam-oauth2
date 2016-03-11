#!/bin/sh
# script to add prompts to startup sso admin setup

cd /usr/local/tomcat
bin/catalina.sh start

cd /root/openam-admin

sleep 10;./setup --acceptLicense --path "/root/openam" --debug "/root/admin/debug" --log "/root/admin/log"

# cd /usr/local/tomcat
# bin/catalina.sh stop