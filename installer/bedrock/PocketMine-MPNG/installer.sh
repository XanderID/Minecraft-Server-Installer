#!/bin/bash

echo -e "Checking all Required Package";

echo -e "Checking Package Jq";
if ! command -v jq &> /dev/null
then
    echo -e "Please Install Package Jq";
	exit 0;
fi

echo -e "Jq Installed";

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

echo -e "\nInput Path Name [pmmp]: \c";
read pathInstall
pathInstall=${pathInstall:-pmmp}

echo -e "\nInput PocketMine-MP NetherGames Bind Port [19132]: \c";
read bindPort
bindPort=${bindPort:-19132}

if ! [[ "$bindPort" =~ ^[0-9]+$ ]]
then
	echo -e "\nPlease Input Number format!"
	exit 1
fi

echo -e "\nCreating path $pathInstall";
if [ ! -d "$pathInstall" ]
then
	mkdir $pathInstall
fi

cd ./$pathInstall/

echo -e "\nStart Installing PocketMine-MP NetherGames on Path $pathInstall"

git clone --depth=1 https://github.com/NetherGamesMC/PocketMine-MP PocketMine-MPNG
curl -L -s -o start.sh https://raw.githubusercontent.com/XanderID/Minecraft-Server-Installer/main/installer/bedrock/PocketMine-MPNG/start.sh
curl -L -s -o PHP-8.2-Linux-x86_64-PM5.tar.gz https://github.com/pmmp/PHP-Binaries/releases/download/pm5-latest/PHP-8.2-Linux-x86_64-PM5.tar.gz

tar -xvzf PHP-8.2-Linux-x86_64-PM5.tar.gz
EXTENSION_DIR=$(find "$(pwd)/bin" -name "*debug-zts*")
grep -q '^extension_dir' bin/php7/bin/php.ini && sed -i'bak' "s{^extension_dir=.*{extension_dir=\"$EXTENSION_DIR\"{" bin/php7/bin/php.ini || echo "extension_dir=\"$EXTENSION_DIR\"" >> bin/php7/bin/php.ini
rm -rf PHP-8.2-Linux-x86_64-PM5.tar.gz

mkdir ./bin/composer
curl -L -s -o ./bin/composer/composer.phar https://getcomposer.org/download/latest-stable/composer.phar

mkdir crashdumps
mkdir players
mkdir plugin_data
mkdir plugins
mkdir resource_packs
mkdir worlds

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

chmod +x "start.sh"

echo -e "\nStart Installing PocketMine-MP NetherGames Depencies"

./bin/php7/bin/php ./bin/composer/composer.phar install --working-dir=./PocketMine-MPNG

echo -e "\n\nDone Installed In Path $pathInstall\n"