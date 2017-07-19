#!/bin/bash
# Clear the screen
reset

# Global variables
buildDir=$(pwd)

# Display pointless banner
echo "----------------------------------------"
echo "             -[CnC Builder]-            "
echo "       -[Tested on Ubuntu 14.04]-       "
echo "                                        "
echo "      written by: @InvokeThreatGuy      "
echo "----------------------------------------"
echo ""
sleep 1

# Prompt user to continue
# could be better, must enter "yes" exactly
read -p "Ready to proceed? [yes/no]: "
if [ "$REPLY" != "yes" ]; then
   exit 1
fi

# Update the system first and install some dependencies
echo ""
echo "[*] -> Installing Dependencies..."
echo ""
sleep 2
apt-get update
apt-get install build-essential git python-pip

# Setup lterm for terminal logging
# Change the logging dir as needed
echo ""
echo "[*] -> Installing and Configuring lterm..."
echo ""
sleep 2
pip install lterm
mkdir terminal_logs
lterm.py -b -i -l $buildDir/terminal_logs/

# Install Oracle Java 8 for CobaltStrike
echo ""
echo "[*] -> Installing Oracle Java 8..."
sleep 2
echo ""
apt-add-repository ppa:webupd8team/java
apt-get update
apt-get install oracle-java8-installer
update-java-alternatives -s java-8-oracle

# Unpack and Activate CobaltStrike
echo ""
echo "[*] -> Installaing CobaltStrike..."
echo ""
sleep 2
tar xzf cobaltstrike-trial.tgz
cd cobaltstrike
./update
cd $buildDir
echo ""

# Setup SSH
# Copy custom SSHD config over original
echo ""
echo "[*] -> Configuring SSH..."
echo ""
sleep 2
cp sshd_config /etc/ssh/sshd_config

# Setup firewall
echo ""
echo "[*] -> Configuring Firewall..."
echo ""
sleep 2
iptables -F
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 7654 -j ACCEPT
iptables -A INPUT -p tcp --dport 50050 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -I INPUT 1 -i lo -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP

# Save firewall rules across reboots
echo ""
echo "[*] -> Saving IPTables rules across reboots..."
sleep 2
apt-get install iptables-persistent
echo ""

# Restart SSH for changes to take affect
echo ""
echo "[*] -> Restarting SSH Service..."
sleep 1
service ssh restart
echo ""
echo "___________________________________________________"
echo ""
echo "[*] - SCRIPT COMPLETE!"
echo ""
echo "[*] - > Executing HTTPsC2DoneRight..."
./HTTPsC2DoneRight.sh
