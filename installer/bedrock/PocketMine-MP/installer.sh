#!/bin/bash

# Check All Installed Package
echo -e "Checking all Required Package";

# Jq
echo -e "Checking Package Jq";
if ! command -v jq &> /dev/null
then
    echo -e "Please Install Package Jq";
	exit 0;
fi

echo -e "Jq Installed";

# Tar
echo -e "Checking Package Tar";
if ! command -v tar &> /dev/null
then
    echo -e "Please Install Package Tar";
	exit 0;
fi

echo -e "Tar Installed";

echo -e "Checking Package Curl";
if ! command -v curl &> /dev/null
then
    echo -e "Please Install Package Curl";
    exit 0;
fi

echo -e "Curl Installed";

# Get for Path Installing
echo -e "\nInput Path Name [pmmp]: \c";
read pathInstall
pathInstall=${pathInstall:-pmmp}

# Get Bind Port Server
echo -e "\nInput PocketMine-MP Bind Port [19132]: \c";
read bindPort
bindPort=${bindPort:-19132}

if ! [[ "$bindPort" =~ ^[0-9]+$ ]]
then
	echo -e "\nPlease Input Number format!"
	exit 1
fi


# Get PocketMine-MP.phar and start.sh Link
installver=$(echo "pm5" | sed -e "s/pm//g")
echo -e "\nGetting Newest PocketMine-MP Version $installver Url!";
installVersion=5.15.0 # Default If Version is doesn't Found

allVersion=$(curl -s https://api.github.com/repos/pmmp/PocketMine-MP/git/refs/tags)
count_version=$(echo $allVersion | jq 'keys | length')
for ((i=0; i<$count_version; i++))
do
  # Mendapatkan nama phar
  cache_name=$(echo $allVersion | jq "reverse | .[$i].ref" | sed -e "s/refs\/tags\///g")
  index=$(echo $(echo $cache_name | tr "." "\n") | awk '{print $1}')
  if [ $(echo $index | sed 's/\"//g') == $installver ]
  then
  	installVersion=$(echo $cache_name | sed 's/\"//g')
  	break
  fi
done

echo -e "Found! Newest PocketMine-MP $installver, Version is '$installVersion'"

echo -e "\nCreating path $pathInstall";
if [ ! -d "$pathInstall" ]
then
	mkdir $pathInstall
fi

cd ./$pathInstall/

echo -e "\nStart Installing PocketMine-MP '$installVersion' on Path $pathInstall"

# Download
curl -L -s -o PocketMine-MP.phar https://github.com/pmmp/PocketMine-MP/releases/download/$installVersion/PocketMine-MP.phar
curl -L -s -o start.sh https://github.com/pmmp/PocketMine-MP/releases/download/$installVersion/start.sh
curl -L -s -o PHP-Linux-x86_64-PM5.tar.gz https://github.com/pmmp/PHP-Binaries/releases/download/php-8.3-latest/PHP-Linux-x86_64-PM5.tar.gz

# Bin Folder
tar -xvzf PHP-Linux-x86_64-PM5.tar.gz
EXTENSION_DIR=$(find "$(pwd)/bin" -name "*debug-zts*")
grep -q '^extension_dir' bin/php7/bin/php.ini && sed -i'bak' "s{^extension_dir=.*{extension_dir=\"$EXTENSION_DIR\"{" bin/php7/bin/php.ini || echo "extension_dir=\"$EXTENSION_DIR\"" >> bin/php7/bin/php.ini
rm -rf PHP-Linux-x86_64-PM5.tar.gz

# Install
mkdir crashdumps
mkdir players
mkdir plugin_data
mkdir plugins
mkdir resource_packs
mkdir worlds

# Create File
echo "" >> "banned-ips.txt"
echo "" >> "banned-players.txt"
echo "" >> "ops.txt"
curl -s "https://raw.githubusercontent.com/pmmp/PocketMine-MP/stable/resources/plugin_list.yml" >> "plugin_list.yml"
curl -s "https://raw.githubusercontent.com/pmmp/PocketMine-MP/stable/resources/pocketmine.yml" >> "pocketmine.yml"
curl -s "https://raw.githubusercontent.com/pmmp/PocketMine-MP/stable/resources/resource_packs.yml" >> "resource_packs.yml"
echo "#Properties Config file
#Tue Jul 3 19:14:16 UTC 2018
motd=PocketMine-MP Server
server-port=$bindPort
white-list=off
announce-player-achievements=on
spawn-protection=16
max-players=20
allow-flight=off
spawn-animals=on
spawn-mobs=on
gamemode=0
force-gamemode=off
hardcore=off
pvp=on
difficulty=1
generator-settings=
level-name=world
level-seed=
level-type=DEFAULT
enable-query=true
enable-rcon=off
rcon.password=
auto-save=on
view-distance=8
xbox-auth=on
server-ip=0.0.0.0
query.port=25573" >> "server.properties"

# Settings
chmod +x "start.sh"

echo -e "\n\nDone Installed In Path $pathInstall\n"