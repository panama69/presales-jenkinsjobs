#!/bin/bash

HOST="http://localhost:8085"

clear
echo Utility to Export or Import Jenkins Jobs
PS3='Please enter your choice to install: '
options=("Export jobs" "Import jobs")
select opt in "${options[@]}" "Quit"
do
  case "$REPLY" in
    1)
      #check if location exists to place the exported jobs
      rm -rf jobs
      if [[ ! -d ./jobs ]]
      then
        mkdir jobs
      fi
      #check if jar file exists for use and download if doesnt
      #this is simple in that assumption is the HOST is accessible
      if [[ ! -f ./jenkins-cli.jar ]]
      then
        echo Must download the Jenkins CLI
        curl -O $HOST/jnlpJars/jenkins-cli.jar
        #giving a little time to make sure the writes are completed
        sleep 1
      fi
      #should enhance to check for spaces in the job name as they need to be replaced with %20 for web safe
      for job in `java -jar jenkins-cli.jar -s $HOST list-jobs`
      do
        echo Exporting: $job
        curl $HOST/job/$job/config.xml -o ./jobs/$job.xml &> /dev/null
      done
      break
      ;;
    2)
      for job in `ls jobs/*.xml`
      do
        echo Importing: $job
        jobName=`echo $job|awk -F"/" '{print $2}'|awk -F"." '{print $1}'`
        curl --fail -X POST $HOST/createItem?name=$jobName --header "Content-Type: application/xml" -d "@$job"
      done
      break
      ;;
    3)
      break
      ;;
    *)
      echo invalid option
      ;;
  esac
done
