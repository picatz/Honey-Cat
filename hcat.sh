#!/bin/bash
# Kent 'picat' Gruber
# HONEY CAT
# Netcat honeypot 

help_menu() {
	echo "HONEY CAT ... BASH + NC + LOVE 

-p <PORT(1-65535)>
	Define the port to setup honeypot on.
-o <FILE>
	Output unique IP addrs to file. 
-b <BANNER>
	Set a custom banner for your honeypot.
-s 
	Use default ssh banner. 
-w 
	Use default web server banner.
-l
	Use lolcat if available.
-v
	Display version.
-h
	Display this menu. 
"
}

# Check if root.
#if [ "$(whoami)" != "root" ]; then
#	echo "This script needs to be run as root."
#	exit 1
#fi

if [ $# -eq 0 ]; then
    echo "No arguments supplied!"
    help_menu
    exit 1
fi

# Set variables
NC=$(which netcat)
LOG_DIR="/var/log/honeycat"
LOG_FILE="hcat.log"
LOG="$LOG_DIR/$LOG_FILE"
out_file=''

# default banner
banner="MS-IIS WEB SERVER 5.0\r"

# create holder 
#[[ -f /tmp/honeycat-hpot.hld ]] && echo "Honey Cat is already running!" && exit 1
touch /tmp/running-hcat.hld


# check if tput is on system
if which tput >/dev/null; then
	BOLD=$(tput bold)
	RESET=$(tput sgr0)
	RED=$(tput setaf 1)
	GREEN=$(tput setaf 2)
else
	BOLD='\033[1m'
	RESET='\033[0m'
	RED='\033[1;31m'
	GREEN='\033[1;32m'
fi

usertrap() {
    echo "Interrupted by user: [ $(date) ]"
    echo "Exiting..."
    rm -f /tmp/running-hcat.hld
    exit 0
}
trap usertrap INT HUP

function Port_Check {
	# Checks the user <PORT> input.
	# 1. Check if <PORT> was given or not. 
	# 2. Check if given <PORT> was within range. 
	
	# Check if <PORT> param was empty. 
	if [[ $port == "" ]]; then
		# Let user know that no port was provided. 
		echo "No port was provided. Ports should be between 1-65535."
		# Give help menu.
		help_menu
		exit 1
	# Check if <PORT> was given within range 1-65535 
	elif [[ $port -lt 1 || $port -gt 65535 ]]; then
		# Let user know that port was out of range. 
		echo "Port $port is out of range. Ports should be between 1-65535."
		# Give help menu.
		help_menu
		exit 1
	fi
}

function Log_Check {
	# 3. Check to make sure log dir is there.
	if [[ ! -d $LOG_DIR ]]; then
		# If it isn't, we'll setup that up. 
		mkdir $LOG_DIR
		touch $LOG
	fi
}

function Version_Check {
	# 4. Check the version number. 
	echo "Version 1.1"
}

function parseOpts() {
	# 5. Parse user arguments.
	while getopts :hHsSwWvVlL:o:O:p:P:b:B: opt; do
		case $opt in
			h|H) # Help
				help_menu
				# I need somebody
				# Help, not just anybody
				# Help, you know I need someone
				# The Beatles 
				exit 0
				;;
			v|V) # Version check 
				Version_Check
				exit 0
				;;
			p|P) # Set port 
				port="$OPTARG"
				;;
			o|O) # Log ips to file
				out_file="$OPTARG"
				;;
			b|B) # User provided banner
				banner="$OPTARG"
				;;
			s|S) # Use ssh banner
				# Use a default banner that looks vulnerable.
				banner="SSH-1.0-OpenSSH_2.3\r"
				;;
			w|W) # Use web server banner
				# Use a default web server banner that looks vulnerable.
				banner="MS-IIS WEB SERVER 5.0\r"
				;;
			l|L) # Use web server banner
				# Check that lolcat was there or not. 
				if which lolcat >/dev/null; then
					# Set check as true. 
					lolcatcheck=true
				else
					# Give that cute error message we all need. 
					echo "Oops, looks like lolcat isn't on this system."
					echo ":("
					# Set check as false. 
					lolcatcheck=false
				fi
				;;
			\?) # Invalid arg
				echo "Invalid option: -$OPTARG"
				help_menu
				exit 1
				;;
			:) # Missing arg
				echo "An argument must be specified for -$OPTARG"
				help_menu
				exit 1
				;;
		esac
	done
}

# because this'll probably break things 
lolcatcheck=false

# Parse Arguments
parseOpts "$@"

# set default banner
dis_ban=${banner%\r} 
# make sure log files are properly setup
Log_Check
Port_Check

function Print_Banner {
echo "┌────────────────────────────┐
│ ╦ ╦╔═╗╔╗╔╔═╗╦ ╦  ╔═╗╔═╗╔╦╗ │   ┌───────────────
│ ╠═╣║ ║║║║║╣ ╚╦╝  ║  ╠═╣ ║  ├───┤ Port : $port <= 
│ ╩ ╩╚═╝╝╚╝╚═╝ ╩   ╚═╝╩ ╩ ╩  │   └──────┬────────
└────────────────────────────┘          │
──────────────────────────────────────────────────────────────
All cotents being logged to: $LOG
──────────────────────────────────────────────────────────────"
if [[ ! $out_file = "" ]]; then 
echo "Unique IPs will be logged to: $out_file"
echo "──────────────────────────────────────────────────────────────"
fi 
}

function Lather_Port {
	echo -e $banner | $NC -l -vv -n -p $port 1>> $LOG 2>> $LOG
	echo "==ATTEMPTED CONNECTION TO PORT#: $port AT `date`==" >> $LOG
	echo "" >> $LOG
	echo "============================================================" >> $LOG
}

function Process_Log {
	hits="$(grep "Connection from" -a $LOG | awk -F: '{print $2}' | sort | uniq | wc -l | awk '$1=$1')"
	num_unq_hits=$( grep "Connection from" -a "$LOG" | awk '{print $3}' | cut -d: -f1 | sort | uniq | wc -l | awk '$1=$1')
	if [[ ! $out_file = "" ]]; then 
		echo "$(grep "Connection from" -a "$LOG" | awk '{print $3}' | cut -d: -f1 | sort | uniq )" > $out_file
	fi
}

# Print the banner
if [ $lolcatcheck == true ]; then
	# use lolcat 
	clear
	Print_Banner | lolcat
	echo "STARTING honeypot on port # : $port [ $(date) ] - - [ $dis_ban ]" | lolcat 
	# Run the honeypot
else
	clear
	Print_Banner
	echo "${BOLD}STARTING${RESET} honeypot on port # : $port [ $(date) ] - - [ $dis_ban ]"
fi


# Run the honeypot
if [ $lolcatcheck == true ]; then
	echo "HERE COMES THE RAINBOW!!!!!!!!!!!!!!!!!!!!!" | lolcat -a -s 3
	while [[ -f /tmp/running-hcat.hld ]]; do
		echo "STARTING honeypot on $port [ $(date) ] - - [ $dis_ban ]" >> $LOG
		Lather_Port
		Process_Log
		echo " HONEY POT # of hits [ $hits ] - - # of uniqe hits [ $num_unq_hits ]" | lolcat 
	done
else
	while [[ -f /tmp/running-hcat.hld ]]; do
		echo "STARTING honeypot on $port [ $(date) ] - - [ $dis_ban ]" >> $LOG
		Lather_Port
		Process_Log
		printf " HONEY POT # of hits [ ${BOLD}$hits${RESET} ] - - # of uniqe hits [ ${BOLD}$num_unq_hits${RESET} ] \r "
	done
fi
