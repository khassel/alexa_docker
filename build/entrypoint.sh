#!/bin/bash

#-------------------------------------------------------
# Inserts user-provided values into a template file
#-------------------------------------------------------
# Arguments are: template_directory, template_name, target_name
use_template()
{
  Template_Loc=$1
  Template_Name=$2
  Target_Name=$3
  while IFS='' read -r line || [[ -n "$line" ]]; do
    while [[ "$line" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]]; do
      LHS=${BASH_REMATCH[1]}
      RHS="$(eval echo "\"$LHS\"")"
      line=${line//$LHS/$RHS}
    done
    echo "$line" >> "$Template_Loc/$Target_Name"
  done < "$Template_Loc/$Template_Name"
}


#--------------------------------------------------------------------------------------------
# Checking if script has been updated by the user with ProductID, ClientID, and ClientSecret
#--------------------------------------------------------------------------------------------
if [ ! -f $Java_Client_Loc/README.txt ]; then
  mv $Origin/samples_ori/javaclient/* $Origin/samples/javaclient/
fi

if [ ! -f $Companion_Service_Loc/app.js ]; then
  mv $Origin/samples_ori/companionService/* $Origin/samples/companionService/
fi

if [ ! -f $Java_Client_Loc/certs/ca/ca.crt ]; then
	echo "========== Generating ssl.cnf =========="
	if [ -f $Java_Client_Loc/ssl.cnf ]; then
	  rm $Java_Client_Loc/ssl.cnf
	fi
	use_template $Java_Client_Loc template_ssl_cnf ssl.cnf

	echo "========== Generating generate.sh =========="
	if [ -f $Java_Client_Loc/generate.sh ]; then
	  rm $Java_Client_Loc/generate.sh
	fi
	use_template $Java_Client_Loc template_generate_sh generate.sh

	echo "========== Executing generate.sh =========="
	chmod +x $Java_Client_Loc/generate.sh
	cd $Java_Client_Loc && bash ./generate.sh
	cd $Origin

	echo "========== Configuring Companion Service =========="
	if [ -f $Companion_Service_Loc/config.js ]; then
	  rm $Companion_Service_Loc/config.js
	fi
	use_template $Companion_Service_Loc template_config_js config.js

	echo "========== Configuring Java Client =========="
	if [ -f $Java_Client_Loc/config.json ]; then
	  rm $Java_Client_Loc/config.json
	fi
	use_template $Java_Client_Loc template_config_json config.json
fi

# Audio-Output
if [ "$Audio" == "3.5mm" ]; then
  amixer cset numid=3 1
  echo "Audio forced to 3.5mm jack."
else
  amixer cset numid=3 2
  echo "Audio forced to HDMI."
fi

# gehört auf dem Host gesetzt, nicht hier
#if [ "$SetVolumeToMax" == "true" ]; then
#  # Lautstärke 400=Max
#  amixer cset numid=1 400
#fi
#
#if [ "$SetVolumeToMax" == "true" ]; then
#  # Micro Empfindlichkeit 55=Max
#  amixer -c 1 cset numid=3,iface=MIXER,name='Mic Capture Volume' 31,55
#fi  

cd $Companion_Service_Loc && npm start > npm.log 2>&1 &

if [ "$Wake_Word_Detection_Enabled" == "true" ]; then
  cd $Java_Client_Loc && mvn exec:exec 2>&1 &
  sleep 25
  cd $Wake_Word_Agent_Loc/src && ./wakeWordAgent -e $Wake_Word_Detection > wakeWordAgent.log
else  
  cd $Java_Client_Loc && mvn exec:exec
fi


