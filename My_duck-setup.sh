#!/bin/bash
# Duck DNS setup version 1.1
# by The Fan Club - November 2013
#by Djang0Pepper 2020 for raspbian BUSTER

# Raspbian
#
# For more information about Duck DNS - http://www.duckdns.org/
#
#script updated from https://github.com/aesqe
RED='\033[0;31m'        #RED
ORANGE='\033[0;33m'     #ORANGE
BLACK='\033[0;30m'      # Black
GREEN='\033[0;32m'      # Green
BLUE='\033[0;34m'       # Blue
PURPLE='\033[0;35m'     # Purple
CYAN='\033[0;36m'       # Cyan
WHITE='\033[0;37m'      # White
NC='\033[0m'            # No Color

userHome=$(eval echo ~${USER})
echo -ne "user is : "
echo -e "${RED} $USER${NC}"
duckPath="/home/pi/duckdns"
echo -ne "running path is : "
echo -e "${RED} $duckPath ${NC}"
duckLog="$duckPath/duck.log"
duckScript="$duckPath/duck.sh"
echo " "
echo -e "* Duck DNS setup by The Fan Club, update ${GREEN}Djang0Pepper ${NC}for raspbian duster *"
echo "version 1.1"
echo

# Remove Option
case "$1" in
	remove)
		echo -ne "Un Install Duck DNS (Y/N) [Y] :"
		read confirmCont
		if [ "$confirmCont" != "Y" ] && [ "$confirmCont" != "Yes" ] && [ "$confirmCont" != "" ] && [ "$confirmCont" != "y" ]
		then
		  echo "Setup cancelled. Program will now quit."
		  exit 0
		fi
		# Remove Duck DNS files
		rm -R $duckPath
		# Remove Cron Job
		crontab -l >/tmp/crontab.tmp
		sed -e 's/\(^.*duck.sh$\)//g' /tmp/crontab.tmp  | crontab
		rm /tmp/crontab.tmp
		echo "Duck DNS removed"
		exit 0
		;;
       test)
		echo -ne "Check Duck DNS "
		# Run now
		$duckScript
		# Response
		duckResponse=$( cat $duckLog )
		echo -e "${GREEN} Duck DNS server response : $duckResponse"
		if [ "$duckResponse" != "OK" ]
		then
		  echo -e "${ORANGE}[Error] Duck DNS did not update correctly. Please check your settings or run the setup again.${NC}"
		else
		  echo " "
                  crontab -l
		  echo " "
		  echo -e "${GREEN}Duck DNS check complete.${NC}"
		fi

		exit
esac

# Main Install ***
# Get sub domain
echo -ne "Enter your Duck DNS sub-domain name (e.g mydomain.duckdns.org) : "
read domainName
mySubDomain="${domainName%%.*}"
duckDomain="${domainName#*.}"
if [ "$duckDomain" != "duckdns.org" ] && [ "$duckDomain" != "$mySubDomain" ] || [ "$mySubDomain" = "" ]
then
  echo "${ORANGE}[Error] Invalid domain name. Program will now quit.${NC}"
  exit 0
fi
# Get Token value
echo
echo -ne "Enter your Duck DNS Token value : "
read duckToken
echo
# Display Confirmation
echo -e "Your fully qualified domain name will be : ${BLUE} $mySubDomain.duckdns.org${NC}"
echo -e "Your token value is : ${BLUE}$duckToken${NC}"
echo
echo -ne "Enter Y or Yes to continue [Y] :"
read confirmCont
if [ "$confirmCont" != "Y" ] && [ "$confirmCont" != "Yes" ] && [ "$confirmCont" != "" ] && [ "$confirmCont" != "y" ]
then
  echo -e "${RED}Setup cancelled. Program will now quit.${NC}"
  exit 0
fi
# Create duck dir
if [ ! -d "$duckPath" ]
then
  sudo mkdir $duckPath
else
  echo -en "${GREEN}$duckPath${NC}"
fi
# Create duck script file
echo  "echo url=\"https://www.duckdns.org/update?domains=$mySubDomain&token=$duckToken&ip=\" | curl -k -o $duckLog -K -" > $duckScript
chmod 700 $duckScript
echo -e "${GREEN}Duck Script file created${NC} "
# Create Conjob
# Check if job already exists
checkCron=$( crontab -l | grep -c $duckScript )
if [ "$checkCron" -eq 0 ]
then
  # Add cronjob
  echo " "
  echo -e "${GREEN}Adding Cron job for Duck DNS${NC}"
	  crontab -l | { cat; echo "*/5 * * * * $duckScript"; } | crontab -
else
  echo " "
  echo -en "${ORANGE}Cron job for Duck DNS exist : "
	  crontab -l 
  echo -e "${NC}"
fi
# Test Setup
echo
echo -ne "Update and Test your Duck DNS now ? Y/N [Y]: "
read confirmCont
if [ "$confirmCont" != "Y" ] && [ "$confirmCont" != "Yes" ] && [ "$confirmCont" != "" ] && [ "$confirmCont" != "y" ]
then
  echo "Setup cancelled. Program will now quit."
  exit 0
fi
# Run now
$duckScript
# Response
duckResponse=$( cat $duckLog )
echo -e "${GREEN} Duck DNS server response : $duckResponse ${NC}"
if [ "$duckResponse" != "OK" ]
then
  echo -e "${ORANGE}[Error] Duck DNS did not update correctly. Please check your settings or run the setup again.${NC}"
else
  echo -e "${PURPLE}Script complete.${NC}"
fi
exit
