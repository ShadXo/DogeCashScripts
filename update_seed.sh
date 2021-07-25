echo
echo "DogeCash - Masternode updater"
echo ""
echo "Welcome to the MONK Masternode update script."
echo "Wallet v5.4.1"
echo

cd ~
sudo killall -9 dogecashd
sudo rm -rdf /usr/local/bin/dogecash*
cd

mkdir -p DOGECASH_TMP
cd DOGECASH_TMP
wget https://github.com/dogecash/dogecash/releases/download/5.4.1/dogecash-5.4.1-x86_64-linux-gnu.tar.gz
sudo chmod 775 dogecash-5.4.1-x86_64-linux-gnu.tar.gz
tar -xvzf dogecash-5.4.1-x86_64-linux-gnu.tar.gz

rm -f dogecash-5.4.1-x86_64-linux-gnu.tar.gz
sudo chmod 775 ./dogecash-5.4.1/bin/*
sudo mv ./dogecash-5.4.1/bin/* /usr/bin

cd ~
rm -rdf DOGECASH_TMP

dogecashd -reindex

sleep 1

dogecash-cli getinfo

echo "Your masternode wallets are now updated!"
