#!/bin/bash
# description: init centos operation system,applying to centos-6.x and centos-7.x
# modified at : 2019-06-08 22:30

os_version() {
  os_ver=$(uname -r |grep -o 'el[0-9]')
}

os_version
# install base packages, maybe you don't need
yum -y install vim lsof sysstat wget iptraf openssh-clients gcc gcc-c++ ntp cmake gzip zip epel-release bind-utils
yum clean all
yum makecache

# set ntpdate
ntpdate 0.centos.pool.ntp.org && hwclock -w

# disable iptables or firewalld and Selinux
# set file descriptors
if [[ "$os_ver" = "el7" ]];then
  systemctl stop firewalld
  systemctl disable firewalld
  sed -i 's/4096/655350/g' /etc/security/limits.d/20-nproc.conf
elif [[ "$os_ver" == "el6" ]];then
  service iptables stop
  chkconfig iptables off
  sed -i 's/1024/655350/g' /etc/security/limits.d/90-nproc.conf
fi
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

if [ -f /etc/security/limits.conf.default -a -f /etc/security/limits.conf ];then
mv /etc/security/limits.conf /etc/security/limits.conf.$(date '+%Y%m%d%H%M%S')
else
mv /etc/security/{limits.conf,limits.conf.default}
fi
cat > /etc/security/limits.conf <<EOF
*	soft nofile	655350
*	hard nofile	655350
*	soft nproc	655350
*	hard nproc	655350
EOF

# set sshd configure
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
sed -i '/22/s/#Port 22/Port 41600/g' /etc/ssh/sshd_config
if [[ "$os_ver" = "el7" ]];then
  systemctl reload sshd
elif [[ "$os_ver" = "el6" ]];then
  service sshd reload
fi

# set kernel
if [ -f /etc/sysctl.conf.default -a -f /etc/sysctl.conf ];then
mv /etc/sysctl.conf /etc/sysctl.conf.$(date '+%Y%m%d%H%M%S')
else
mv /etc/{sysctl.conf,sysctl.conf.default}
fi
cat > /etc/sysctl.conf <<EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_synack_retries = 2
kernel.sysrq = 1
net.ipv4.ip_local_port_range = 1500 65535
net.ipv4.tcp_window_scaling = 1
net.core.somaxconn = 65535
net.ipv4.tcp_congestion_control = cubic
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 5
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_rmem = 10240 87380 12582912
net.ipv4.tcp_wmem = 10240 87380 12582912
net.core.rmem_default = 6291456
net.core.wmem_default = 6291456
net.core.wmem_max = 12582912
net.core.rmem_max = 12582912
net.ipv4.tcp_max_orphans = 262114
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.core.netdev_max_backlog = 655350
vm.overcommit_memory = 1
vm.overcommit_ratio = 60
fs.file-max = 1000000
EOF
sysctl -p
