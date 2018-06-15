# Generate APM Data

## Description

This script deploys the [Spring Pet Clinic](https://github.com/NewRelicUniversity/spring-petclinic) sample application to an AWS EC2 instance that has been configured to run Pet Clinic and MySQL in Docker containers. It uses Apache JMeter to send traffic to the application, which has a memory leak; the traffic will cause the application to use increasingly more memory, resulting in slower transaction response times.

After the initial JMeter script completes (in approximately 30 minutes), the script deploys a second version of the application that omits the [buggy component](https://github.com/dandelion/dandelion-datatables). It then re-reruns the JMeter script to demonstrate that the application's performance problem has been corrected.

## Required Software

1. Ensure that you have the necessary [Java runtime](http://www.java.com/en/download/mac_download.jsp) installed. JMeter 3.x requires Java 7 or higher.

2. Download and install [Apache JMeter](http://jmeter.apache.org/download_jmeter.cgi).

3. Download and install the [JMeter Standard Plugins](http://jmeter-plugins.org/downloads/all/). The JMeter scripts use the Stepping Thread Group plugin.

4. Enable the _Custom Thread Groups_ plugin: 

  a. Select _Plugins Manager_ from JMeter's _Options_ menu. 
  
  ![JMeter Plugins Manager](screenshots/jmeter-plugins-manager.png?raw=true)
  
  b. Tick the box next to _Custom Thread Groups_. Click the button labeled _Apply Changes and Restart JMeter_.
  
  ![JMeter Activate Plugin](screenshots/jmeter-activate-plugin.png?raw=true)

## Configuration

Before running the script, modify the following parameters:

- `HOST_NAME`: Public DNS of your Amazon EC2 instance
- `PORT`: Port number on which your application is running (defaults to 80)
- `AWS_KEY_FILE`: Name and location of the public key file (.pem) for your EC2 instance
- `NR_API_KEY`: [New Relic API key](https://docs.newrelic.com/docs/apis/getting-started/intro-apis/access-rest-api-keys) of desired account
- `NR_APP_ID`: New Relic application ID. Used to set deployment markers
- `NR_DEPLOY_USER`: User name of deployer to appear in New Relic deployment markers

## Usage

1. Clone this repository to your computer.
2. To run the script, open a Terminal window and execute `$ ./generate-apm-data.sh`.
3. There is currently no API to start the thread profiler. Log into the target application in your New Relic account and [start the thread profiler](https://docs.newrelic.com/docs/apm/applications-menu/events/thread-profiler-tool) manually approximately 10 minutes after starting the script.

## Notes

- The script assumes that JMeter is available on your $PATH. If it is not, you must edit line 72 of `generate-apm-data.sh` to include the full path to the JMeter executable.
- If you receive an error that you have an unprotected private key file, execute `chmod 600 nru.pem` to make the key file accessible only to its owner (you).
- Trainees may reset the REST API key on the training account. If you receive a `401 Unauthorized` error while setting deployment markers, ensure that the value of `NR_API_KEY` matches the account's REST API key.
- The JMeter scripts require significant upstream bandwidth in order to generate sufficient traffic to stress the application. Don't count on being able to run it from a hotel room!