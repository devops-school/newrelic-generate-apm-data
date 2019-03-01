#!/bin/sh

# Variables
WAR_FILE_V1="petclinic-1.0.war"
WAR_FILE_V2="petclinic-2.0.war"
HOST_NAME="ec2-13-233-92-233.ap-south-1.compute.amazonaws.com"
PORT="80"

AWS_KEY_FILE="./rajesh-mumbai.pem"
AWS_EC2_INSTANCE="ec2-user@${HOST_NAME}"

APP_URL="http://${HOST_NAME}:${PORT}/petclinic/"
NR_API_KEY="92eb026ce30284574b8a72659ef3632a963803c6ed6485a"
NR_APP_ID="145211100"

NR_DEPLOY_CHANGELOG_V1="Initial deploy"
NR_DEPLOY_CHANGELOG_V2="Replaced dandelion datatables with jQuery, removed session state caching"
NR_DEPLOY_DESC_V1="v1.0"
NR_DEPLOY_DESC_V2="Upgrade to v2.0"
NR_DEPLOY_REVISION_V1="2738cbdcca"
NR_DEPLOY_REVISION_V2="3d2d67bbfb"
NR_DEPLOY_USER="Rajesh Kumar"

JMETER_SCRIPT="aws.jmx"

deployApp ()
{
	# Copy WAR file to webapps folder
	echo "\n--- Deploying" $1 "\n"
	scp -i $AWS_KEY_FILE ./$1 $AWS_EC2_INSTANCE:~/webapps/petclinic.war
	
	# Set deployment marker
	deploymentMarker "$2" "$3" "$4"
	
	# Restart Docker container
	echo "\n--- Restarting petclinic container"
	# ssh -i $AWS_KEY_FILE $AWS_EC2_INSTANCE 'docker restart petclinic'
	
	# Wait for app restart
	echo "\n--- Waiting for app restart"
	sleep 30
	while [ $(curl -s -o /dev/null -I -w "%{http_code}" $APP_URL) -ne 200 ] ; do
		printf "."
	done
	echo
	return
}

deploymentMarker ()
{
	echo "\n--- Setting deployment marker\n"

    curl -X POST "https://api.newrelic.com/v2/applications/${NR_APP_ID}/deployments.json" \
         -H "X-Api-Key:${NR_API_KEY}" -i \
         -H 'Content-Type: application/json' \
         -d \
        "{
            \"deployment\": {
                \"revision\": \"${2}\",
                \"changelog\": \"${3}\",
                \"description\": \"${1}\",
                \"user\": \"${NR_DEPLOY_USER}\"
            }
        }"

	return
}

startJmeter ()
{
	# Start JMeter script
	jmeter -n -JHOST=${HOST_NAME} -JPORT=${PORT} -t $1
	return
}

deployApp "$WAR_FILE_V1" "$NR_DEPLOY_DESC_V1" "$NR_DEPLOY_REVISION_V1" "$NR_DEPLOY_CHANGELOG_V1"
echo "\n--- Starting Jmeter. Wait 10-15 minutes, then run thread profiler\n"
startJmeter "$JMETER_SCRIPT"

# After 10-15 minutes, start thread profiler

# When Jmeter script completes, deploy v2 and repeat
deployApp "$WAR_FILE_V2" "$NR_DEPLOY_DESC_V2" "$NR_DEPLOY_REVISION_V2" "$NR_DEPLOY_CHANGELOG_V2"
echo "\n--- Starting Jmeter. \n"
startJmeter "$JMETER_SCRIPT"