#!/bin/bash
# 磁盘扩容，默认为vdb

disk="vdb"
fstype=$(df -hT|grep "$disk"|awk '{print $2}')
mount_dir=$(df -hT|grep "$disk" |awk '{print $NF}')

start_msg(){
echo -e "\033[0;36;1m> start resize fs work\033[0m"
}
resize_msg(){
echo -e "\033[0;36;1m> start resize /dev/$disk\033[0m"
}
mount_msg(){
echo -e "\033[0;36;1m> start mount /dev/$disk to $mount_dir\033[0m"
}
error_msg(){
echo -e "\033[0;31;1m> Error:check your os fs type!\033[0m"
}

ext4Fs(){
start_msg
umount /dev/$disk
e2fsck -f /dev/$disk
resize_msg
resize2fs /dev/$disk
mount_msg
mount /dev/$disk $mount_dir
}

xfsFs(){
start_msg
umount /dev/$disk
xfs_repair /dev/$disk
mount_msg
mount /dev/$disk $mount_dir
resize_msg
xfs_growfs $mount_dir
}

if [ "$fstype" = "ext4" ];then
  ext4Fs
elif [ "$fstype" = "xfs" ];then
  xfsFs
else
  error_msg
fi
