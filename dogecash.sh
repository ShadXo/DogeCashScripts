#!/bin/bash

##
##
##

RED='\033[1;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
LIGHTCYAN='\033[1;36m'
NC='\033[0m' # No Color

## Black        0;30     Dark Gray     1;30
## Red          0;31     Light Red     1;31
## Green        0;32     Light Green   1;32
## Brown/Orange 0;33     Yellow        1;33
## Blue         0;34     Light Blue    1;34
## Purple       0;35     Light Purple  1;35
## Cyan         0;36     Light Cyan    1;36
## Light Gray   0;37     White         1;37

# Execute getopt
ARGS=$(getopt -o "c:" -l "coin:" -n "$0" -- "$@");

eval set -- "$ARGS";

while true; do
    case "$1" in
        -c |--coin)
            shift;
                    if [ -n "$1" ];
                    then
                        NAME="$1";
                        shift;
                    fi
            ;;
        --)
            shift;
            break;
            ;;
    esac
done

COIN=$NAME
if [ -z "$COIN" ]; then
  COIN="dogecash"
fi

if [ "$COIN" == "dogecash" ]; then
  MAINCOLOR=$CYAN
  ACCENTCOLOR=$LIGHTCYAN
else
  MAINCOLOR=$RED
  ACCENTCOLOR=$LIGHTCYAN
fi

# Run upgrade service
wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/upgrade_service.sh -O upgrade_service.sh > /dev/null 2>&1
chmod 777 upgrade_service.sh
dos2unix upgrade_service.sh > /dev/null 2>&1
/bin/bash ./upgrade_service.sh -c $COIN

center() {
  #termwidth="$(tput cols)"
  termwidth=51
  padding="$(printf '%0.1s' *{1..500})"
  printf '%*.*s %s %*.*s\n' 0 "$(((termwidth-2-${#1})/2))" "$padding" "$1" 0 "$(((termwidth-1-${#1})/2))" "$padding"
}

echo && echo
#echo "******** Powered by the DogeCash Community ********"
echo "************** Powered by DogeCash ****************"
echo "************** https://dogecash.net ***************"
echo "***************************************** v1.2.0 **"
#echo "******************** ${COIN^^} *********************"
center ${COIN^^}
echo "******************** MAIN MENU ********************"
echo ""
echo -e "${MAINCOLOR}1) LIST ALL NODES" # -> DOGECASH_LIST.SH" # OK
echo -e "2) CHECK NODES SYNC" #  -> DOGECASH_CHECK_SYNC.SH" # OK
echo -e "3) RESYNC NODES THAT ARE OUT OF SYNC" #  -> DOGECASH_CHECK_RESYNC_ALL.SH" # OK
echo -e "4) (RE-)START NODES" #  -> DOGECASH_RESTART.SH" # OK
echo -e "5) STOP NODES" #  -> DOGECASH_STOP.SH" # OK
echo -e "6) INSTALL NEW NODES" #  -> DOGECASH_SETUPV1.SH" # OK
echo -e "7) CHECK NODES STATUS" #  -> DOGECASH_CHECK_STATUS.SH" # OK
echo -e "8) RESYNC SPECIFIC NODE (useful if node is stopped)" # -> DOGECASH_RESYNC.sh # OK
echo -e "9) REMOVE SPECIFIC NODE" # -> DOGECASH_REMOVE.sh # OK
echo -e "10) UPDATE NODE WALLET" # -> UPDATE_WALLET.sh # OK
echo -e "11) UPDATE WALLET ADDNODES" # -> UPDATE_ADDNODES.sh # OK
echo -e "12) NODE INFO (DO NOT SHARE WITHOUT REMOVING PRIVATE INFO)" # -> dogecash_info.sh # OK
echo -e "13) FORK FINDER" # -> find_fork.sh # OK
echo -e "14) CALCULATE FREE MEMORY AND CPU FOR NEW NODES" # -> memory_cpu_sysinfo.sh # OK
echo -e "${ACCENTCOLOR}15) DOGECASH LOGO" # DOGECASH LOGO
echo -e "${MAINCOLOR}0) EXIT${NC}" # OK
echo "---------------------------------------------------"
echo "Choose an option:"
read OPTION
# echo ${OPTION}
ALIAS=""

clear

case $OPTION in
    1)
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/dogecash_list.sh -O dogecash_list.sh > /dev/null 2>&1
        chmod 777 dogecash_list.sh
        dos2unix dogecash_list.sh > /dev/null 2>&1
        /bin/bash ./dogecash_list.sh -c $COIN
        ;;
    2)
        echo -e "${MAINCOLOR}Which node do you want to check if synced? Enter alias (if empty it will run on all nodes)${NC}"
        read ALIAS
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/dogecash_check_sync.sh -O dogecash_check_sync.sh > /dev/null 2>&1
        chmod 777 dogecash_check_sync.sh
        dos2unix dogecash_check_sync.sh > /dev/null 2>&1
        /bin/bash ./dogecash_check_sync.sh -c $COIN -n $ALIAS
        ;;
    3)
        echo -e "${MAINCOLOR}Which node do you want to check sync and resync? Enter alias (if empty it will run on all nodes)${NC}"
        read ALIAS
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/dogecash_check_resync_all.sh -O dogecash_check_resync_all.sh > /dev/null 2>&1
        chmod 777 dogecash_check_resync_all.sh
        dos2unix dogecash_check_resync_all.sh > /dev/null 2>&1
        /bin/bash ./dogecash_check_resync_all.sh -c $COIN -n $ALIAS
        ;;
    4)
        echo -e "${MAINCOLOR}Which node do you want to (re-)start? Enter alias (if empty it will run on all nodes)${NC}"
        read ALIAS
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/dogecash_restart.sh -O dogecash_restart.sh > /dev/null 2>&1
        chmod 777 dogecash_restart.sh
        dos2unix dogecash_restart.sh > /dev/null 2>&1
        /bin/bash ./dogecash_restart.sh -c $COIN -n $ALIAS
        ;;
    5)
        echo -e "${MAINCOLOR}Which node do you want to stop? Enter alias (if empty it will run on all nodes)${NC}"
        read ALIAS
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/dogecash_stop.sh -O dogecash_stop.sh > /dev/null 2>&1
        chmod 777 dogecash_stop.sh
        dos2unix dogecash_stop.sh > /dev/null 2>&1
        /bin/bash ./dogecash_stop.sh -c $COIN -n $ALIAS
        ;;
    6)
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/dogecash_setup.sh -O dogecash_setup.sh > /dev/null 2>&1
        chmod 777 dogecash_setup.sh
        dos2unix dogecash_setup.sh > /dev/null 2>&1
        /bin/bash ./dogecash_setup.sh -c $COIN
        ;;
    7)
        echo -e "${MAINCOLOR}For which node do you want to check masternode status? Enter alias (if empty it will run on all nodes)${NC}"
        read ALIAS
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/dogecash_check_status.sh -O dogecash_check_status.sh > /dev/null 2>&1
        chmod 777 dogecash_check_status.sh
        dos2unix dogecash_check_status.sh > /dev/null 2>&1
        /bin/bash ./dogecash_check_status.sh -c $COIN -n $ALIAS
        ;;
    8)
        echo -e "${MAINCOLOR}Which node do you want to resync? Enter alias (mandatory!)${NC}"
        read ALIAS
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/dogecash_resync.sh -O dogecash_resync.sh > /dev/null 2>&1
        chmod 777 dogecash_resync.sh
        dos2unix dogecash_resync.sh > /dev/null 2>&1
        /bin/bash ./dogecash_resync.sh -c $COIN -n $ALIAS
        ;;
    9)
        echo -e "${MAINCOLOR}Which node do you want to remove? Enter alias (mandatory!)${NC}"
        read ALIAS
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/dogecash_remove.sh -O dogecash_remove.sh > /dev/null 2>&1
        chmod 777 dogecash_remove.sh
        dos2unix dogecash_remove.sh > /dev/null 2>&1
        /bin/bash ./dogecash_remove.sh -c $COIN -n $ALIAS
        ;;
    10)
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/update_wallet.sh -O update_wallet.sh > /dev/null 2>&1
        chmod 777 update_wallet.sh
        dos2unix update_wallet.sh > /dev/null 2>&1
        /bin/bash ./update_wallet.sh -c $COIN
        ;;
    11)
        echo -e "${MAINCOLOR}For which node do you want the addnodes updated? Enter alias (if empty it will run on all nodes)${NC}"
        read ALIAS
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/update_addnodes.sh -O update_addnodes.sh > /dev/null 2>&1
        chmod 777 update_addnodes.sh
        dos2unix update_addnodes.sh > /dev/null 2>&1
        /bin/bash ./update_addnodes.sh -c $COIN -n $ALIAS
        ;;
    12)
        echo -e "${MAINCOLOR}For which node do you want to get info? Enter alias (if empty it will run on all nodes)${NC}"
        read ALIAS
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/dogecash_info.sh -O dogecash_info.sh > /dev/null 2>&1
        chmod 777 dogecash_info.sh
        dos2unix dogecash_info.sh > /dev/null 2>&1
        /bin/bash ./dogecash_info.sh -c $COIN -n $ALIAS
        ;;
    13)
        echo -e "${MAINCOLOR}On which node do you want to check for a fork? Enter alias (mandatory!)${NC}"
        read NODE
        echo -e "${MAINCOLOR}Start checking from block? (mandatory!)${NC}"
        read BLOCK
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/find_fork.sh -O find_fork.sh > /dev/null 2>&1
        chmod 777 find_fork.sh
        dos2unix find_fork.sh > /dev/null 2>&1
        /bin/bash ./find_fork.sh -c $COIN -n $NODE -b $BLOCK
        ;;
    14)
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/memory_cpu_sysinfo.sh -O memory_cpu_sysinfo.sh > /dev/null 2>&1
        chmod 777 memory_cpu_sysinfo.sh
        dos2unix memory_cpu_sysinfo.sh > /dev/null 2>&1
        /bin/bash ./memory_cpu_sysinfo.sh
        ;;
    15)
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/dogecash_logo.sh -O dogecash_logo.sh > /dev/null 2>&1
        chmod 777 dogecash_logo.sh
        dos2unix dogecash_logo.sh > /dev/null 2>&1
        /bin/bash ./dogecash_logo.sh
        ;;
    0)
        exit 0
        ;;
    50)
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/dogecash_setupv1-f.sh -O dogecash_setupv1-f.sh > /dev/null 2>&1
        chmod 777 dogecash_setupv1-f.sh
        dos2unix dogecash_setupv1-f.sh > /dev/null 2>&1
        /bin/bash ./dogecash_setupv1-f.sh
        ;;
    51)
        wget https://raw.githubusercontent.com/ShadXo/DogeCashScripts/master/dogecash_setupv1.1.sh -O dogecash_setupv1.1.sh > /dev/null 2>&1
        chmod 777 dogecash_setupv1.1.sh
        dos2unix dogecash_setupv1.1.sh > /dev/null 2>&1
        /bin/bash ./dogecash_setupv1.1.sh -c $COIN
        ;;
    *) echo "Invalid option $OPTION";;
esac

###
read -n 1 -s -r -p "***** Press any key to go back to the ${COIN^^} MAIN MENU *****"
/bin/bash ./dogecash.sh -c $COIN
