#!/bin/sh
#
# dhcpmon script
# Checks the interface DHCP status and reloads it if necessary
#
# Copyright (c) 2020 Micha LaQua <micha.laqua@gmail.com>
#
# This belongs into /usr/local/bin/dhcpmon.sh

log () {
  echo "$1"
  logger -t "dhcpmon" "$1"
}

if [ -z $1 ]; then
  log "[ERROR] No interface specified"
  exit 1
fi

IFACE=$1

ifconfig $IFACE > /dev/null 2>&1
if [ $? -gt 0 ]; then
  log "[ERROR] Interface $IFACE does not exist"
  exit 1
fi

curtime=$(date +%s)
uptime=$(sysctl kern.boottime | awk -F'sec = ' '{print $2}' | awk -F',' '{print $1}')
uptime=$(($curtime - $uptime))
if [ $uptime -lt 300 ]; then
  log "System uptime is less than 5m. Not checking DHCP status of $IFACE"
  exit 0
fi

if [ $(ifconfig $IFACE | grep -c -w inet) -eq 0 ]; then
  log "$IFACE DHCP seems down, reloading interface..."
  ifconfig $IFACE down
  sleep 1
  ifconfig $IFACE up
fi
