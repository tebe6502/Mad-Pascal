#!/bin/bash
#project name is the first argument - check if it is set
if [ -z "$1" ] ; then
    echo "No argument supplied"
    echo "Usage: mpinit.sh project_name [nos]"
    exit 1
fi
PROJECT_NAME=$1

#if second argument is 'nos' then select non OS template
#default is OS template
if [ "$2" == "nos" ] ; then
INFILE=start_nos.pas
else
INFILE=start_os.pas
fi

#clone MadStrap git repository into project folder
git clone https://gitlab.com/bocianu/madstrap $PROJECT_NAME
#enter project folder
cd $PROJECT_NAME
# remove old MadStrap .git folder
rm -rf .git
# copy the selected template to project main *.pas 
cp $INFILE ${PROJECT_NAME}.pas
# update build.bat accordingly
sed -i -e 's/NAME=start_os/NAME='${PROJECT_NAME}'/g' -e 's/ADDINTRO=1/ADDINTRO=0/g' build.bat
# replace MadStrap program name with a new project name
sed -i -e 's/program madStrap;/program '${PROJECT_NAME}';/g' ${PROJECT_NAME}.pas
# remove the template files
rm start_*.pas

