#!/bin/bash

hdd() {
  hdd="$(df -h | awk 'NR==3{print $4, $5}')"
  echo -e "NVMe: $hdd"
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
    echo "+@fg=0; $(kern) +@fg=0; | +@fg=0; $(cpu) +@fg=0; | +@fg=0; $(mem) +@fg=0; | +@fg=0; $(hdd) +@fg=0; | +@fg=0; $(vol)+@fg=0; |" 
    sleep $SLEEP_SEC
done
