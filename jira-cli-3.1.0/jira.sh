#!/bin/bash

# Comments
# - Customize for your installation, for instance you might want to add default parameters like the following:
# java -jar `dirname $0`/lib/jira-cli-3.1.0.jar --server http://my-server --user automation --password automation "$@"

java -Djavax.net.ssl.trustStore=`dirname $0`/../scm_keystore -Djavax.net.ssl.trustStorePassword=changeit -jar `dirname $0`/lib/jira-cli-3.1.0.jar "$@" 
