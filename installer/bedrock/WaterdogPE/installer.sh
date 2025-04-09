#!/bin/bash

checkNumber(){
	if ! [[ "$1" =~ ^[0-9]+$ ]]
	then
		echo -e "\nPlease Input Number format!"
		exit 1
	fi
}

echo -e "Checking all Required Package";

echo -e "Checking Package Jq";
if ! command -v jq &> /dev/null
then
    echo -e "Please Install Package Jq";
	exit 0;
fi

echo -e "Jq Installed";

echo -e "Checking Package Curl";
if ! command -v curl &> /dev/null
then
    echo -e "Please Install Package Curl";
    exit 0;
fi

echo -e "Curl Installed";

echo -e "Checking Package Java";
if ! command -v java &> /dev/null
then
    echo -e "Please Install Package Java version above or equal to 11.0.17"
    exit 0;
fi

echo -e "Java Installed";

echo -e "Checking Java Version"
java=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
if [[ "$java" < "11.0.17" ]]
then
   echo -e "Please Install Package Java version above or equal to 11.0.17"
    exit 0;
fi

echo -e "Your java version Have the requirements criteria!"

echo -e "\nInput Path Name [waterdogpe]: \c";
read pathInstall
pathInstall=${pathInstall:-waterdogpe}

echo -e "\nCreating path $pathInstall";
if [ ! -d "$pathInstall" ]
then
	mkdir $pathInstall
fi

cd ./$pathInstall/

waterdogUrl=$(curl -s https://api.github.com/repos/WaterdogPE/WaterdogPE/releases/latest | jq '.assets[0].browser_download_url' | sed 's/\"//g')
waterdogVersion=$(curl -s https://api.github.com/repos/WaterdogPE/WaterdogPE/releases/latest | jq '.tag_name' | sed 's/\"//g')

echo -e "\nStart Installing WaterdogPE '$waterdogVersion' on Path $pathInstall"

curl -L -s -o Waterdog.jar $waterdogUrl
curl -L -s -o lang.ini https://raw.githubusercontent.com/WaterdogPE/WaterdogPE/master/src/main/resources/lang.ini

mkdir logs
mkdir plugins
mkdir packs

echo "#!/bin/bash
java -Xms512M -Xmx4G -jar Waterdog.jar" >> "start.sh"

chmod +x "start.sh"

echo -e "\nWaterdogPE is already installed, do you want to make automatic configuration? [y/n]: \c";
read choice

if ! [ $choice == "y" ]
then
	echo -e "\n\nDone Installed In Path $pathInstall"
	exit 0
fi

echo -e "\nInput WaterdogPE Bind Port [19132]: \c";
read bindPort
bindPort=${bindPort:-19132}

checkNumber $bindPort

echo -e "\nInput WaterdogPE Max Players [50]: \c";
read maxPlayers
maxPlayers=${maxPlayers:-50}

checkNumber $maxPlayers

echo -e "\nInput WaterdogPE MOTD [§bWaterdog§3PE]: \c";
read motdWD
motdWD=${motdWD:-§bWaterdog§3PE}

echo -e "\nInput WaterdogPE Server Name [§bWaterdog§3PE]: \c";
read serverName
serverName=${serverName:-§bWaterdog§3PE}

echo -e "\nInput Your Server Count ( Without WaterdogPE ) [1]: \c";
read serverCount
serverCount=${serverCount:-1}

if [ $serverCount -lt 1 ]
then
	echo -e "\nPlease enter Amount above 0!"
	exit 1
fi

echo -e "\nStart configuring total $serverCount Server!";
server_list=""
for ((i=0; i<$serverCount; i++))
do
	let inum=$i+1
	let startPort=$i+3
	
	echo -e "Input Name Server ($inum) [lobby]: \c";
	read nameServer
	nameServer=${nameServer:-lobby}
	
	echo -e "Input IP Server ($inum) [0.0.0.0]: \c";
	read ipServer
	ipServer=${ipServer:-0.0.0.0}
	
	echo -e "Input Port Server ($inum) [1913$startPort]: \c";
	read portServer
	portServer=${portServer:-1913$startPort}
	
	checkNumber $portServer

	# when i used \t WaterdogPE yamler error
	server_list+="\n    $nameServer:"
	server_list+="\n        address: $ipServer:$portServer"
	server_list+="\n        public_address: $ipServer:$portServer"
	server_list+="\n        server_type: bedrock"
	
	echo ""
done

echo -e "Input Server Priorities [lobby]: \c";
read serverPriorities
serverPriorities=${serverPriorities:-lobby}

# Create Config
echo -e "\nCreating Config"

echo -e "# Waterdog Main Configuration file
# Configure your desired network settings here.

# A list of all downstream servers that are available right after starting
# address field is formatted using ip:port
# publicAddress is optional and can be set to the ip players can directly connect through
servers: $server_list
listener:
  # The Motd which will be displayed in the server tab of a player and returned during ping
  motd: $motdWD

  # The name that is shown up in the player list (pause menu)
  name: $serverName

  # The server priority list. If not changed by plugins, the proxy will connect the player to the first of those servers
  priorities:
  - $serverPriorities

  # The address to bind the server to
  host: 0.0.0.0:$bindPort

  # The maximum amount of players that can connect to this proxy instance
  max_players: $maxPlayers

  # Map the ip a player joined through to a specific server
  # for example skywars.xyz.com => SkyWars-1
  # when a player connects using skywars-xyz.com as the serverIp, he will be connected to SkyWars-1 directly
  forced_hosts: {}

# Case-Sensitive permission list for players (empty using {})
permissions:
  TobiasDev:
  - waterdog.player.transfer
  - waterdog.player.list
  alemiz003:
  - waterdog.player.transfer
  - waterdog.player.list

# List of permissions each player should get by default (empty using [])
permissions_default:
- waterdog.command.help
- waterdog.command.info

# Whether the debug output in the console should be enabled or not
enable_debug: false

# If enabled, encrypted connection between client and proxy will be created
upstream_encryption: true

# If enabled, only players which are authenticated with XBOX Live can join. If disabled, anyone can connect *with any name*
online_mode: true

# If enabled, the proxy will be able to bind to an Ipv6 Address
enable_ipv6: false

# Additional ports to listen to
additional_ports: []

# If enabled, the proxy will pass information like XUID or IP to the downstream server using custom fields in the LoginPacket
use_login_extras: false

# Replaces username spaces with underscores if enabled
replace_username_spaces: false

# Whether server query should be enabled
enable_query: true

# If enabled, when receiving a McpeTransferPacket, the proxy will check if the target server is in the downstream list, and if yes, use the fast transfer mechanism
prefer_fast_transfer: true

# Fast-codec only decodes the packets required by the proxy, everything else will be passed rawly. Disabling this can create a performance hit
use_fast_codec: true

# If enabled, the proxy will inject all the proxy commands in the AvailableCommandsPacket, enabling autocompletion
inject_proxy_commands: true

# Algorithm used for upstream compression. Currently supported: zlib, snappy
# This is only applicable on 1.19.30 and newer versions
compression: zlib

# Upstream server compression ratio(proxy to client), higher = less bandwidth, more cpu, lower vice versa
upstream_compression_level: 6

# Downstream server compression ratio(proxy to downstream server), higher = less bandwidth, more cpu, lower vice versa
downstream_compression_level: 2

# Education features require small adjustments to work correctly. Enable this option if any of downstream servers support education features.
enable_edu_features: true

# Enable/Disable the resource pack system
enable_packs: true

# If this is enabled, the client will not be able to use custom packs
overwrite_client_packs: false

# If enabled, the client will be forced to accept server-sided resource packs
force_server_packs: false

# You can set maximum pack size in MB to be cached.
pack_cache_size: 16

# Creating threads may be in some situations expensive. Specify minimum count of idle threads per internal thread executors. Set to -1 to auto-detect by core count.
default_idle_threads: -1

# Enable anonymous statistics that are sent to bstats. For more information, check out our bstats page at https://bstats.org/plugin/server-implementation/WaterdogPE/15678
enable_statistics: true" >> "config.yml"

echo -e "\nDone Installed In Path $pathInstall"