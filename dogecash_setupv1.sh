#!/bin/bash

RED='\033[1;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
BROWN='\033[0;34m'
NC='\033[0m' # No Color

# CONFIGURATION
NAME="dogecash"
WALLETVERSION="5.4.4"

# ADDITINAL CONFIGURATION
WALLETDLFOLDER="${NAME}-${WALLETVERSION}"
WALLETDL="${WALLETDLFOLDER}-x86_64-linux-gnu.tar.gz"
URL="https://github.com/dogecash/dogecash/releases/download/${WALLETVERSION}/${WALLETDL}"
CONF_FILE="${NAME}.conf"
CONF_DIR_TMP=~/"${NAME}_tmp"
BOOTSTRAPURL="https://www.dropbox.com/s/s4vy92sczk9c10s/blocks_n_chains.tar.gz"
#ADDNODESURL="https://www.dropbox.com/s/s0pdil1rehsy4fu/peers.txt?dl=1"
ADDNODESURL="https://api.dogecash.org/api/v1/network/peers"
PORT=56740
RPCPORT=57740

cd ~
echo "******************************************************************************"
echo "* Ubuntu 18.04 or newer operating system is recommended for this install.    *"
echo "*                                                                            *"
echo "* This script will install and configure your ${NAME} Coin masternodes (v${WALLETVERSION}).*"
echo "******************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

#if [[ $(lsb_release -d) != *16.04* ]]; then
#   echo -e "${RED}The operating system is not Ubuntu 16.04. You must be running on Ubuntu 16.04! Do you really want to continue? [y/n]${NC}"
#   read OS_QUESTION
#   if [[ ${OS_QUESTION,,} =~ "y" ]] ; then
#      echo -e "${RED}You are on your own now!${NC}"
#   else
#      exit -1
#   fi
#fi

function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(ip addr show dev $ips | grep inet | awk -F '[ \t]+|/' '{print $3}' | grep -v ^fe80 | grep -v ^::1 | grep -v ^1.2.3 | sort -V))
    #NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
    #NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s6 icanhazip.com))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]; then
    echo -e "${GREEN}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
    INDEX=0
    for ip in "${NODE_IPS[@]}"
    do
      echo ${INDEX} $ip
      let INDEX=${INDEX}+1
    done
    read -e choose_ip
    NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}

apt-get install -y net-tools > /dev/null

get_ip
#IP="[${NODEIP}]"
PUBIPv4=$( timeout --signal=SIGKILL 10s wget -4qO- -T 10 -t 2 -o- "--bind-address=${NODEIP}" http://ipinfo.io/ip )
PUBIPv6=$( timeout --signal=SIGKILL 10s wget -6qO- -T 10 -t 2 -o- "--bind-address=${NODEIP}" http://v6.ident.me )
if [[ $NODEIP =~ .*:.* ]]; then
  #INTIP=$(ip -4 addr show dev $ips | grep inet | awk -F '[ \t]+|/' '{print $3}' | head -1)
  #IP=${INTIP}
  IP="[${NODEIP}]"
  EXTERNALIP="[${PUBIPv6}]"
  else
  IP=${NODEIP}
  EXTERNALIP=${PUBIPv4}
fi

echo -e "${YELLOW}Do you want to install all needed dependencies (no if you did it before, yes if you are installing your first node)? [y/n]${NC}"
read DOSETUP

if [[ ${DOSETUP,,} =~ "y" ]]; then
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get install -y nano htop git
  sudo apt-get install -y software-properties-common
  sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev
  sudo apt-get install -y libboost-all-dev
  sudo apt-get install -y libevent-dev
  sudo apt-get install -y libminiupnpc-dev
  sudo apt-get install -y autoconf
  sudo apt-get install -y automake unzip
  sudo add-apt-repository -y ppa:luke-jr/bitcoincore
  sudo apt-get update
  sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
  sudo apt-get install -y dos2unix
  sudo apt-get install -y jq curl

   if [ $(free | awk '/^Swap:/ {exit !$2}') ] || [ ! -f "/var/swap.img" ]; then
     echo "No proper swap, creating it"
     sudo touch /var/swap.img
     sudo chmod 600 /var/swap.img
     sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
     sudo mkswap /var/swap.img
     sudo swapon /var/swap.img
     sudo free
     sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
   else
     echo "All good, we have a swap"
   fi

   ## COMPILE AND INSTALL
   if [ -d "$CONF_DIR_TMP" ]; then
      rm -rfd $CONF_DIR_TMP
   fi

   mkdir -p $CONF_DIR_TMP
   mkdir -p ~/.dogecash-params

   cd $CONF_DIR_TMP
   wget ${URL}
   chmod 775 ${WALLETDL}
   tar -xvzf ${WALLETDL}
   #unzip ${WALLETDL} -d ${WALLETDLFOLDER}

   #cd ./${WALLETDLFOLDER}/bin
   cd ./${WALLETDLFOLDER}
   sudo chmod 775 *
   sudo mv ./bin/${NAME}* /usr/bin
   #sudo mv ./bin/${NAME}* /usr/local/bin # previous /usr/bin should be /usr/local/bin
   sudo mv ./share/dogecash/*.params ~/.dogecash-params

   #read
   cd ~
   rm -rfd $CONF_DIR_TMP

   sudo apt-get install -y ufw
   sudo ufw allow ssh/tcp
   sudo ufw limit ssh/tcp
   sudo ufw logging on
   echo "y" | sudo ufw enable
   sudo ufw status

   mkdir -p ~/bin
   echo 'export PATH=~/bin:$PATH' >> ~/.bash_aliases
   source ~/.bashrc
fi

## Setup conf
mkdir -p ~/bin
rm ~/bin/masternode_config.txt &>/dev/null &
COUNTER=1

MNCOUNT="1"
#REBOOTRESTART=""
re='^[0-9]+$'
while ! [[ $MNCOUNT =~ $re ]]; do
  echo -e "${YELLOW}How many nodes do you want to create on this server?, followed by [ENTER]:${NC}"
  read MNCOUNT
  #echo -e "${YELLOW}Do you want to use TOR, additional dependencies needed (no if you dont know what this does)? [y/n]${NC}"
  #read TOR
  #echo -e "${YELLOW}Do you want the wallet to restart on reboot? [y/n]${NC}"
  #read REBOOTRESTART
done

if [[ ${TOR,,} =~ "y" ]]; then
  if (service --status-all | grep -w "tor" &>/dev/null); then
    echo ""
  else
    sudo apt install -y tor
    echo -e 'ControlPort 9051\nLongLivedPorts 56740' >> /etc/tor/torrc
    systemctl stop tor
    systemctl start tor
  fi
fi

REBOOTRESTART="y"
#echo -e "${YELLOW}Do you want the wallet to restart on reboot? [y/n]${NC}"
#read REBOOTRESTART

for (( ; ; ))
do
  #echo "************************************************************"
  #echo ""
  #echo "Enter alias for new node. Name must be unique! (Don't use same names as for previous nodes on old chain if you didn't delete old chain folders!)"
  echo -e "${YELLOW}Enter alphanumeric alias for new nodes.[default: mn]${NC}"
  read ALIAS1

  if [ -z "$ALIAS1" ]; then
    ALIAS1="mn"
  fi

  ALIAS1=${ALIAS1,,}

  if [[ "$ALIAS1" =~ [^0-9A-Za-z]+ ]]; then
    echo -e "${RED}$ALIAS1 has characters which are not alphanumeric. Please use only alphanumeric characters.${NC}"
  elif [ -z "$ALIAS1" ]; then
    echo -e "${RED}$ALIAS1 in empty!${NC}"
  else
    CONF_DIR=~/.${NAME}_$ALIAS1
    if [ -d "$CONF_DIR" ]; then
         echo -e "${RED}$ALIAS1 is already used. $CONF_DIR already exists!${NC}"
    else
      # OK !!!
      break
    fi
  fi
done

if [ -d "$CONF_DIR_TMP" ]; then
  rm -rfd $CONF_DIR_TMP
fi

mkdir -p $CONF_DIR_TMP

for STARTNUMBER in `seq 1 1 $MNCOUNT`; do
   for (( ; ; ))
   do
      echo "************************************************************"
      echo ""
      EXIT='NO'
      ALIAS="$ALIAS1$STARTNUMBER"
      ALIAS0="${ALIAS1}0${STARTNUMBER}"
      ALIAS=${ALIAS,,}
      echo $ALIAS
      echo ""

      # check ALIAS
      if [[ "$ALIAS" =~ [^0-9A-Za-z]+ ]]; then
        echo -e "${RED}$ALIAS has characters which are not alphanumeric. Please use only alphanumeric characters.${NC}"
        EXIT='YES'
	    elif [ -z "$ALIAS" ]; then
	      echo -e "${RED}$ALIAS in empty!${NC}"
        EXIT='YES'
      else
	      CONF_DIR=~/.${NAME}_${ALIAS}
        CONF_DIR0=~/.${NAME}_${ALIAS0}

        if [ -d "$CONF_DIR" ]; then
          echo -e "${RED}$ALIAS is already used. $CONF_DIR already exists!${NC}"
          STARTNUMBER=$[STARTNUMBER + 1]
        elif [ -d "$CONF_DIR0" ]; then
          echo -e "${RED}$ALIAS is already used. $CONF_DIR0 already exists!${NC}"
          STARTNUMBER=$[STARTNUMBER + 1]
        else
          # OK !!!
          break
        fi
      fi
   done

   if [ $EXIT == 'YES' ]
   then
      exit 1
   fi

   IP1=""
   for (( ; ; ))
   do
     IP1=$(netstat -peanut -W | grep -i listen | grep -i $NODEIP)

     if [ -z "$IP1" ]; then
       break
     else
       echo -e "${RED}IP: $NODEIP is already used.${NC}"
       if [[ ${TOR,,} =~ "y" ]] ; then
         echo "Using TOR"
         #NODEIP="127.0.0.1"
         break
       fi
       exit
       echo "Creating fake IP."
       BASEIP="1.2.3."
       IP=$BASEIP$STARTNUMBER
       cat > /etc/netplan/${NAME}_$ALIAS.yaml <<-EOF
       # This is the network config written by 'subiquity'
       network:
         ethernets:
           ens160:
             addresses:
             - $BASEIP$STARTNUMBER/24
         version: 2
		EOF
    fi
    netplan apply
    break
  done
  echo "IP "$IP
  echo "PORT "$PORT

  if [[ ${TOR,,} =~ "y" ]]; then
    TORPORT=$PORT
    PORT1=""
    for (( ; ; ))
    do
      PORT1=$(netstat -peanut | grep -i listen | grep -i $TORPORT)

      if [ -z "$PORT1" ]; then
        break
      else
        TORPORT=$[TORPORT + 1]
      fi
    done
    echo "TORPORT "$TORPORT
  fi

  RPCPORT1=""
  for (( ; ; ))
  do
    RPCPORT1=$(netstat -peanut | grep -i listen | grep -i $RPCPORT)
    if [ -z "$RPCPORT1" ]; then
      echo "RPCPORT "$RPCPORT
      break
    else

      RPCPORT=$[RPCPORT + 1]
    fi
  done

  PRIVKEY=""
  echo ""

  echo "ALIAS="$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/${NAME}d_$ALIAS.sh
  echo "${NAME}d -daemon -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR "'$*' >> ~/bin/${NAME}d_$ALIAS.sh
  echo "${NAME}-cli -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR "'$*' > ~/bin/${NAME}-cli_$ALIAS.sh
  chmod 755 ~/bin/${NAME}*.sh

  # Create config file
  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> ${NAME}.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> ${NAME}.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> ${NAME}.conf_TEMP
  echo "rpcport=$RPCPORT" >> ${NAME}.conf_TEMP
  echo "listen=1" >> ${NAME}.conf_TEMP
  echo "server=1" >> ${NAME}.conf_TEMP
  echo "daemon=1" >> ${NAME}.conf_TEMP
  echo "logtimestamps=1" >> ${NAME}.conf_TEMP
  echo "maxconnections=256" >> ${NAME}.conf_TEMP

  echo "" >> ${NAME}.conf_TEMP
  #echo "port=$PORT" >> ${NAME}.conf_TEMP
  echo "masternodeaddr=$EXTERNALIP:$PORT" >> ${NAME}.conf_TEMP
  #echo "bind=$IP:$PORT" >> ${NAME}.conf_TEMP
  if ! [[ ${TOR,,} =~ "y" ]] ; then
    echo "bind=$IP:$PORT" >> ${NAME}.conf_TEMP
  else
    echo "bind=$IP:$TORPORT" >> ${NAME}.conf_TEMP
    echo "proxy=127.0.0.1:9050" >> ${NAME}.conf_TEMP
    echo "torcontrol=127.0.0.1:9051" >> ${NAME}.conf_TEMP
  fi
  if [ -z "$PRIVKEY" ]; then
    echo ""
  else
    echo "masternode=1" >> ${NAME}.conf_TEMP
    echo "masternodeprivkey=$PRIVKEY" >> ${NAME}.conf_TEMP
  fi

  sudo ufw allow $PORT/tcp
  mv ${NAME}.conf_TEMP $CONF_DIR/${NAME}.conf

  if [[ ${TOR,,} =~ "y" ]]; then
    union=$(grep "tor: Got service ID" ~/.${NAME}_${ALIAS}/debug.log | sed -e 's/\(^.*advertising service \)\(.*\)\(:.*$\)/\2/' | head -n 1)
    sudo sed -i "s/masternodeaddr=$EXTERNALIP/masternodeaddr=$union/g" $CONF_DIR/${NAME}.conf
  fi

  if [[ ${REBOOTRESTART,,} =~ "y" ]] ; then
    (crontab -l 2>/dev/null; echo "@reboot sh ~/bin/${NAME}d_$ALIAS.sh") | crontab -
    (crontab -l 2>/dev/null; echo "@reboot sh /root/bin/${NAME}d_$ALIAS.sh") | crontab -
    sudo service cron reload
    : <<'END'
    #DAEMONSYSTEMDFILE="/etc/systemd/system/${NAME}d_$ALIAS.service"
    #if [[ ! -f "${DAEMONSYSTEMDFILE}" ]]; then
    #fi
    echo "Creating systemd service for ${NAME}d_$ALIAS"
    function configure_systemd {
  cat << EOF > /etc/systemd/system/${NAME}d_$ALIAS.service
[Unit]
Description=DogeCash Service for $ALIAS
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart=${NAME}d -daemon -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR
ExecStop=-${NAME}-cli -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  sleep 2
  systemctl enable ${NAME}d_$ALIAS.service
  systemctl start ${NAME}d_$ALIAS.service
}
END
  fi

  PID=`ps -ef | grep -i ${NAME} | grep -i -w ${NAME}_${ALIAS} | grep -v grep | awk '{print $2}'`
  if [ -z "$PID" ]; then
    # start wallet
    echo "Starting $ALIAS."
    sh ~/bin/${NAME}d_$ALIAS.sh
    sleep 2 # wait 2 second
  fi

  if [ -z "$PRIVKEY" ]; then
    echo "Generating masternode key on $ALIAS"
	  for (( ; ; ))
	  do
      PRIVKEY=$(~/bin/${NAME}-cli_${ALIAS}.sh createmasternodekey)
      if [ -z "$PRIVKEY" ]; then
        echo "PRIVKEY is null"
      else
        echo "PRIVKEY=$PRIVKEY"
        break
      fi
      echo "Please wait ..."
      sleep 2 # wait 2 seconds
    done
  fi

  for (( ; ; ))
	do
		PID=`ps -ef | grep -i ${NAME} | grep -i -w ${NAME}_${ALIAS} | grep -v grep | awk '{print $2}'`
		if [ -z "$PID" ]; then
		  echo ""
      break
    else
		  #STOP
      echo "Stopping $ALIAS. Please wait ..."
	    ~/bin/${NAME}-cli_$ALIAS.sh stop
    fi
	  #echo "Please wait ..."
	  sleep 2 # wait 2 seconds
  done

	#PID=`ps -ef | grep -i ${NAME} | grep -i -w ${NAME}_${ALIAS} | grep -v grep | awk '{print $2}'`
	#echo "PID="$PID

	if [ -z "$PID" ]; then
    echo "masternode=1" >> $CONF_DIR/${NAME}.conf
    echo "masternodeprivkey=$PRIVKEY" >> $CONF_DIR/${NAME}.conf
  fi

  if [ -z "$PID" ]; then
    #ADDNODES=$( wget -4qO- -o- ${ADDNODESURL} | grep 'addnode=' | shuf ) # If using Dropbox link
    ADDNODES=$( curl -s4 ${ADDNODESURL} | jq -r ".result" | jq -r '.[]' )
    sed -i '/addnode\=/d' $CONF_DIR/${NAME}.conf
    sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' $CONF_DIR/${NAME}.conf # Remove empty lines at the end
    #echo "${ADDNODES}" | tr " " "\\n" >> $CONF_DIR/${NAME}.conf # If using Dropbox link
    echo "${ADDNODES}" | sed "s/^/addnode=/g" >> ~/.${NAME}_$ALIAS/${NAME}.conf
    sed -i '/addnode=localhost:56740/d' ~/.${NAME}_$ALIAS/${NAME}.conf # Remove addnode=localhost:56740 line from config, api is giving localhost back as a peer
  fi

  if [ -z "$PID" ]; then
    PARAM1="*"
    for FILE in $(ls ~/bin/${NAME}-cli_$PARAM1.sh | sort -V); do
      SYNCNODEALIAS=$(echo $FILE | awk -F'[_.]' '{print $2}')
      SYNCNODECONFPATH=$(echo "$HOME/.${NAME}_$SYNCNODEALIAS")
      if [ "$SYNCNODEALIAS" != "$ALIAS" ]; then
        echo "Checking ${SYNCNODEALIAS}."
        #BLOCKHASHEXPLORER=$(curl -s4 https://api2.dogecash.org/height/$BLOCK | jq -r ".result.hash")
        #BLOCKHASHEXPLORER=$(curl -s4 https://api2.dogecash.org/info | jq -r ".result.bestblockhash")
        #BLOCKHASHEXPLORER=$(curl -s4 https://dogec.flitswallet.app/api/block/$BLOCK | jq -r ".hash")
        BLOCKHASHEXPLORER=$(curl -s4 https://dogec.flitswallet.app/api/blocks | jq -r ".backend.bestBlockHash")
        LASTBLOCK=$($FILE getblockcount)
        BLOCKHASHWALLET=$($FILE getblockhash $LASTBLOCK)
      fi
      if [ "$BLOCKHASHEXPLORER" == "$BLOCKHASHWALLET" ]; then
        echo "*******************************************"
        echo "Using the following node to sync faster."
        echo "NODE ALIAS: "$SYNCNODEALIAS
        echo "CONF FOLDER: "$SYNCNODECONFPATH
        break
      else
        SYNCNODEALIAS=""
      fi
    done

    for (( ; ; ))
    do
      SYNCNODEPID=`ps -ef | grep -i -w ${NAME}_$SYNCNODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
      if [ -z "$SYNCNODEPID" ]; then
        echo ""
        break
      else
        #STOP
        echo "Stopping $SYNCNODEALIAS. Please wait ..."
        ~/bin/${NAME}-cli_$SYNCNODEALIAS.sh stop
      fi
      #echo "Please wait ..."
      sleep 2 # wait 2 seconds
    done

    if [ -z "$PID" ] && [ "$SYNCNODEALIAS" ]; then
      # Copy this Daemon.
      echo "Copy BLOCKCHAIN from ~/.${NAME}_${SYNCNODEALIAS} to ~/.${NAME}_${ALIAS}."
      rm -R $CONF_DIR/database &> /dev/null
      rm -R $CONF_DIR/blocks	&> /dev/null
      rm -R $CONF_DIR/sporks &> /dev/null
      rm -R $CONF_DIR/chainstate &> /dev/null
      cp -r $SYNCNODECONFPATH/database $CONF_DIR &> /dev/null
      cp -r $SYNCNODECONFPATH/blocks $CONF_DIR &> /dev/null
      cp -r $SYNCNODECONFPATH/sporks $CONF_DIR &> /dev/null
      cp -r $SYNCNODECONFPATH/chainstate $CONF_DIR &> /dev/null
    elif [ -z "$PID" ]; then
      cd $CONF_DIR_TMP
      echo "Downloading bootstrap"
      wget ${BOOTSTRAPURL} -O blocks_n_chains.tar.gz
      cd ~
      cd $CONF_DIR
      echo "Copy BLOCKCHAIN without conf files"
	    rm -R ./database &> /dev/null
	    rm -R ./blocks	&> /dev/null
	    rm -R ./sporks &> /dev/null
	    rm -R ./chainstate &> /dev/null
      mv $CONF_DIR_TMP/blocks_n_chains.tar.gz .
      #unzip bootstrap.zip
      tar -xvzf blocks_n_chains.tar.gz
      rm ./blocks_n_chains.tar.gz
    fi
  fi

  SYNCNODEPID=`ps -ef | grep -i -w ${NAME}_$SYNCNODEALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
  if [ -z "$SYNCNODEPID" ] && [ "$SYNCNODEALIAS" ]; then
    # start wallet
    echo "Starting $SYNCNODEALIAS."
    sh ~/bin/${NAME}d_$SYNCNODEALIAS.sh
    sleep 2 # wait 2 seconds
  fi

  PID=`ps -ef | grep -i ${NAME} | grep -i -w ${NAME}_${ALIAS} | grep -v grep | awk '{print $2}'`
  if [ -z "$PID" ]; then
    # start wallet
    echo "Starting $ALIAS."
    sh ~/bin/${NAME}d_$ALIAS.sh
    sleep 2 # wait 2 second
  fi

  if [[ $NODEIP =~ .*:.* ]]; then
    MNCONFIG=$(echo $ALIAS [$PUBIPv6]:$PORT $PRIVKEY "txhash" "outputidx")
  else
    MNCONFIG=$(echo $ALIAS $PUBIPv4:$PORT $PRIVKEY "txhash" "outputidx")
  fi
  echo $MNCONFIG >> ~/bin/masternode_config.txt

  COUNTER=$[COUNTER + 1]
done

if [ -d "$CONF_DIR_TMP" ]; then
  rm -rfd $CONF_DIR_TMP
fi

echo ""
echo -e "${YELLOW}****************************************************************"
echo -e "**Copy/Paste lines below in Hot wallet masternode.conf file**"
echo -e "**and replace txhash and outputidx with data from masternode outputs command**"
echo -e "**in hot wallet console**"
echo -e "**Tutorial: https://dogecash.org **"
echo -e "****************************************************************${NC}"
echo -e "${RED}"
cat ~/bin/masternode_config.txt
echo -e "${NC}"
echo "****************************************************************"
echo ""
