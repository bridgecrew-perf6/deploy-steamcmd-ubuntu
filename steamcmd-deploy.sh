#!/bin/bash

# A script to quickliy deploy steamcmd on ubuntu
# milage may vary depending on distro
# according to instructions from
# https://www.linode.com/docs/guides/install-steamcmd-for-a-steam-game-server/

# perform full system upgrade and reboot first
# and create user steam -- maybe this can be automated in the future, too
# run with sudo privilege

# install screen for persistent terminal sessions

apt install screen

# make firewall configurations wit iptables

echo 'making firewall configurations with ip tables'

echo '*filter

# Allow all loopback (lo0) traffic and reject traffic
# to localhost that does not originate from lo0.
-A INPUT -i lo -j ACCEPT
-A INPUT ! -i lo -s 127.0.0.0/8 -j REJECT

# Allow ping.
-A INPUT -p icmp -m state --state NEW --icmp-type 8 -j ACCEPT

# Allow SSH connections.
-A INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT

# Allow the Steam client.
-A INPUT -p udp -m udp --dport 27000:27030 -j ACCEPT
-A INPUT -p udp -m udp --dport 4380 -j ACCEPT

# Allow inbound traffic from established connections.
# This includes ICMP error returns.
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Log what was incoming but denied (optional but useful).
-A INPUT -m limit --limit 3/min -j LOG --log-prefix "iptables_INPUT_denied: " --log-level 7
-A FORWARD -m limit --limit 3/min -j LOG --log-prefix "iptables_FORWARD_denied: " --log-level 7

# Reject all other inbound.
-A INPUT -j REJECT
-A FORWARD -j REJECT

COMMIT' > v4

echo '*filter

# Allow all loopback (lo0) traffic and reject traffic
# to localhost that does not originate from lo0.
-A INPUT -i lo -j ACCEPT
-A INPUT ! -i lo -s ::1/128 -j REJECT

# Allow ICMP.
-A INPUT -p icmpv6 -j ACCEPT

# Allow inbound traffic from established connections.
-A INPUT -m state --state ESTABLISHED -j ACCEPT

# Reject all other inbound.
-A INPUT -j REJECT
-A FORWARD -j REJECT

COMMIT' > v6

iptables-restore < v4
ip6tables-restore < v6

#make iptables persistent through reboot
echo 'making persistence for iptables'

apt install iptables-persistent

dpkg-reconfigure iptables-persistent

# add necessary repositories for ubuntu

echo 'adding additional required repositories'

add-apt-repository multiverse
dpkg --add-architecture i386
apt update

# install required libraries
echo 'installing additional required 32bit libraries'
apt install lib32gcc1 lib32stdc++6 libc6-i386 libcurl4-gnutls-dev:i386 libsdl2-2.0-0:i386

# install steamcmd
echo 'now installing steamcmd'
apt install steamcmd

exit
