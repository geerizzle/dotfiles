#!/bin/bash

hdd() {
  hdd="$(df -h | awk 'NR==4{print $4, $5}')"
  echo -e "NVMe: $hdd"
}

net() {
  net="$(iwctl station wlan0 show | awk 'NR==7{print $3}')"
  echo -e "NET: $net"
}

mem() {
  mem=`free | awk '/Mem/ {printf "%dM", $3 / 1024.0, $2 / 1024.0 }'`
  echo -e "RAM: $mem"
}

kern() { 
  echo -e "$(uname -r)";
}
cpu() {
  read cpu a b c previdle rest < /proc/stat
  prevtotal=$((a+b+c+previdle))
  sleep 0.5
  read cpu a b c idle rest < /proc/stat
  total=$((a+b+c+idle))
  cpu=$((100*( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))
  echo -e "CPU: $cpu%"
}

vol() {
    vol=`amixer get Master | awk -F'[][]' 'END{ print $4":"$2 }' | sed 's/on://g'`
    echo -e "VOL: $vol "
}

SLEEP_SEC=2

while :; do
    echo "+@fg=7; $(net) +@fg=0; | +@fg=6; $(cpu) +@fg=0; | +@fg=2; $(mem) +@fg=0; | +@fg=3; $(hdd) +@fg=0; | +@fg=4; $(vol)+@fg=0; |" 
    sleep $SLEEP_SEC
done
