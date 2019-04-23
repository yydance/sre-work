#!/bin/bash
# 获取内网IP

ip_a="10\."
ip_b="172\."
ip_c="192\.168\."
app_dir="/data/app"
base_dir="$app_dir/scripts"
log_msg(){
    echo -e ">>> \033[032;1m$@\033[0m"
}
get_ip(){
  network=$(ip a|grep UP|grep -v DOWN|grep -v 'lo:'|awk '{print $2}'|cut -d':' -f1)
  network_count=$(echo $network|xargs -n1|wc -l)
  if [ $network_count -eq 1 ];then
    ip=$(ip a|grep "$network"|tail -1|cut -d'/' -f1|awk '{print $2}')
  else
    for net in $network;do
      ip=$(ip a|grep "$net"|tail -1|cut -d'/' -f1|awk '{print $2}')
      if $($(echo $ip |grep "^$IP_A" >/dev/null);then
        break
      elif $(echo $ip |grep "^$IP_B" >/dev/null);then
        break
      elif $(echo $ip |grep "^$IP_C" >/dev/null);then
        break
      else
        break
      fi
    done
  fi
}

get_ip
