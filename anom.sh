#!/bin/bash

#Store IP address before running Nipe 
orginIP=$(ifconfig | grep broadcast | awk '{print $2}') 
findNipe=$(find ~ -name nipe.pl)
installTor=$(apt list --installed tor)
installGeoip=$(apt list --installed geoip-bin)
installSSHpass=$(apt list --installed sshpass)

function runNipe()
{
		sudo perl nipe.pl stop
		sleep 5
		sudo perl nipe.pl start
		sleep 5
		sudo perl nipe.pl restart
		sleep 5
		#sudo perl nipe.pl status
}
# check if geoip has been installed
if [ ! -z "$installGeoip" ]
then 
	echo 'geoip-bin is already installed'
	
else
	echo 'installing geoip-bin'
	sudo apt-get install -y geoip-bin
	
fi

# check if tor has been installed
if [ ! -z "$installTor" ]
then 
	echo 'tor is already installed'
	
else
	echo 'installing tor'
	sudo apt-get install tor
	
fi
# check if sshpass has been installed
if [ ! -z "$installSSHpass" ]
then 
	echo 'sshpass is already installed'
	
else
	echo 'installing sshpass'
	sudo apt-get install sshpass
	
fi

# find the Nipe program and run the nipe
if [ ! -z "$findNipe" ]
then 
	echo 'Nipe is already installed'
	cd "$(dirname "$(find ~ -name nipe.pl)")"
	runNipe
else
	echo 'installing Nipe'
	git clone https://github.com/htrgouvea/nipe && cd nipe
	sudo cpan install Try::Tiny Config::simple JSON
	sudo perl nipe.pl install
	runNipe
	
fi

# Checking if you are anonymous
maskIP=$(sudo perl nipe.pl status | grep Ip | awk '{print $3}')
maskCountry=$(geoiplookup $maskIP | awk -F: '{print $2}')

function CheckAnom()
{
	if [ $orginIP == $maskIP ]
	then
		#echo "orgin: $orginIP"
		#echo "mask: $maskIP"
		echo 'Not anom'
		echo 'Goodbye'
		exit
	else
		echo 'You are anonymous...'
		echo "Your spoofed IP address is: $maskIP"
		echo "Your spoofed country is: $maskCountry"
		echo ''
	fi
}
CheckAnom

 
#enter domain to check
 echo 'Please Specify the Domain/IP Address to scan'
 read DomainCheck
 
 echo 'Connecting to Remote Server:'
 #enter the remote server
 SerUptime=$(sshpass -p tc ssh tc@192.168.159.130 uptime)
 SerIpadd=$(sshpass -p tc ssh tc@192.168.159.130 curl ifconfig.me)
 SerCountry=$(geoiplookup $SerIpadd)
 echo "Uptime: $SerUptime"
 echo "IP address: $SerIpadd"
 echo "Country: $SerCountry"
 echo ''

 
 echo "Whoising victem's address"
 sshpass -p tc ssh tc@192.168.159.130 whois $DomainCheck > "whois-$DomainCheck"
 locationWhois=$(find ~ -name "whois-$DomainCheck")
 echo "who is data saved into $locationWhois"
 NOW=$(date)
 echo "$NOW" ' Whois data collected for:' "$DomainCheck" >> NRs.log

 echo "Scanning victim's address"
 sshpass -p tc ssh tc@192.168.159.130 nmap $DomainCheck > "NMap-$DomainCheck"
 locationNmap=$(find ~ -name "NMap-$DomainCheck")
 echo "Nmap scan was saved into $locationNmap"
 NOW2=$(date)
 echo "$NOW2" ' Nmap data collected for:' "$DomainCheck" >> NRs.log
