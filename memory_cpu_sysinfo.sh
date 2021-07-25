#!/bin/bash

RED='\033[1;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
BROWN='\033[0;34m'
NC='\033[0m' # No Color

# dependencies
sudo apt-get install -y bc

TOTALMEM=0
TOTALCPU=0
COUNTER=0
COIN=$1
NUMBOFCPUCORES=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)

if [ -z "$COIN" ]; then
   COIN="daemon"
fi

# echo "COIN=${COIN}"
echo -e "${BLUE}*** Calculating, please wait ...${NC}"
echo -e "${BLUE}---------------------------------------------------${NC}"

for PID in `ps -ef | grep -i ${COIN} | grep daemon | grep conf | grep -v grep | awk '{printf "%d\n", $2}'`; do
   # echo "PID=${PID}"
   PIDMEM=$(cat /proc/${PID}/status |grep VmRSS | awk '{printf "%d\n", $2}')
   # echo "PIDMEM=${PIDMEM}"
   TOTALMEM=$(expr ${TOTALMEM} + ${PIDMEM})

   PIDCPU=$(echo `ps -p ${PID} -o %cpu | grep -v CPU |awk '{printf "%0.2f\n", $1}'`)
   # echo "PIDCPU=${PIDCPU}"
   TOTALCPU=$(echo "${TOTALCPU} + ${PIDCPU}" | bc)

   COUNTER=$[COUNTER + 1]
done

echo -e "${GREEN}Currently running nodes: ${COUNTER} ${NC}"

if [ $COUNTER == 0 ]
then
   echo -e "${RED}No installed nodes found! Default stats will be used! ${NC}"
   COUNTER=1
fi

#echo "Total memory used ${TOTALMEM} Kb"

if [ -z "$NUMBOFCPUCORES" ]; then
   NUMBOFCPUCORES=1
elif  [ $COUNTER == 0 ]; then
   NUMBOFCPUCORES=1
fi

# echo "NUMBOFCPUCORES=${NUMBOFCPUCORES}"

if [ -z "$TOTALCPU" ]; then
   TOTALCPU=0
fi

TOTALCPU=$(echo "${TOTALCPU} / ${NUMBOFCPUCORES}" |bc)
echo -e "${GREEN}Total CPU% used ${TOTALCPU}%${NC}"

TOTALMEMMB=$(expr ${TOTALMEM} / 1024)
# echo "Total memory used ${TOTALMEMMB} Mb"

AVERAGEMEMMB=$(expr ${TOTALMEMMB} / ${COUNTER})

if [ -z "$AVERAGEMEMMB" ]; then
   AVERAGEMEMMB=500
elif  [ $AVERAGEMEMMB == 0 ]; then
   AVERAGEMEMMB=500
fi

AVERAGECPU=$(echo "${TOTALCPU} / ${COUNTER}" |bc -l)
echo -e "${GREEN}Average CPU used ${AVERAGECPU}% per node${NC}"

TOTALMEMGB=$(expr ${TOTALMEMMB} / 1024)
echo -e "${GREEN}Total memory used ${TOTALMEMGB} Gb${NC}"

echo -e "${GREEN}Average memory used ${AVERAGEMEMMB} Mb per node${NC}"

FREEMEMMB=$(free -m | grep Mem | awk '{printf "%d\n", $4}')
echo -e "${GREEN}Free memory ${FREEMEMMB} Mb${NC}"
NUMOFFREENODESMEM=$(expr ${FREEMEMMB} / ${AVERAGEMEMMB})

if [ -z "$AVERAGECPU" ]; then
   AVERAGECPU=0.5
elif  [ $AVERAGECPU == 0 ]; then
   AVERAGECPU=0.5
fi

NUMOFFREENODESCPU=$(echo "100 / ${AVERAGECPU}" | bc)

### RESULT ###
echo ""
echo -e "${YELLOW}Based on free memory, this server can host approx. ${RED}${NUMOFFREENODESMEM}${NC} ${YELLOW}additional nodes${NC}"
echo -e "${YELLOW}Based on free CPU, this server can host approx. ${RED}${NUMOFFREENODESCPU}${NC} ${YELLOW}additional nodes${NC}"
echo -e "${PURPLE}###All data is for informational purposes only and may be inaccurate!###${NC}"