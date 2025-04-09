#!/bin/bash

echo -e "Checking all Required Package";
sleep 1

echo -e "Checking Package Jq";
sleep 1
if ! command -v jq &> /dev/null
then
    echo -e "Please Install Package Jq";
	exit 1;
fi

echo -e "Jq Installed";
sleep 1

installer_json=$(curl -s https://raw.githubusercontent.com/XanderID/Minecraft-Server-Installer/main/config/installer.json)

categories=$(echo $installer_json | jq -r 'keys[]')
message=""
all_index=0
for categories in $categories
do
	software_count=$(echo $installer_json | jq ".$categories | length")
	message+="$categories:"
	for ((i=0; i<$software_count; i++))
	do
		INSTALLER[$all_index]=$(echo $installer_json | jq ".$categories[$i].url" | sed 's/\"//g')
   	 SOFTWARE[$all_index]=$(echo $installer_json | jq ".$categories[$i].name" | sed 's/\"//g')
   
   	message+="\n [$all_index] ${SOFTWARE[$all_index]}"
   	((all_index++))
	done

	message+="\n\n"
done

message+="Choose what you want to install: \c"
installing=0
echo -e $message
read installing

if ! [[ "$installing" =~ ^[0-9]+$ ]]
then
	echo -e "\nPlease Input Number format!"
	exit 1
fi

if ! [ "${INSTALLER[$installing]+isset}" ]
then
	echo -e "\nThere is no $installing option!"
	exit 1
fi

echo -e "\nStart Installing ${SOFTWARE[$installing]}!\n"
bash <(curl -s "${INSTALLER[$installing]}")