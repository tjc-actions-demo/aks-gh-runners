#!/bin/sh
echo "Displaying network interfaces:"
ip addr

echo "Displaying routing table:"
cat /etc/resolv.conf

curl $1
