#!/data/app/python3/bin/python3
# author: damon.yang
# 描述: 云主机系统数据采集器
#

from urllib import (request, parse, error)
import os, socket, uuid, fcntl, struct, subprocess, platform
import hashlib, re, json
import ssl
import logging, logging.handlers
import traceback

## ssl verify false ##
ssl._create_default_https_context = ssl._create_unverified_context

JKB_UD_PROD = {'cn-bj1': ['cn-bj1-01'], 'cn-bj2': ['cn-bj2-02', 'cn-bj2-03', 'cn-bj2-04']}
TSB_UD_PROD = {'cn-bj1': ['cn-bj1-01'], 'cn-bj2': ['cn-bj2-02', 'cn-bj2-03', 'cn-bj2-04']}
YCB_UD_PROD = {'cn-bj1': ['cn-bj1-01'], 'cn-bj2': ['cn-bj2-02', 'cn-bj2-03', 'cn-bj2-04']}
TSB_AI_PROD = {'cn-hangzhou': ['cn-hangzhou-b'], 'cn-beijing': ['cn-beijing-a']}
PLATFORM = {'ud':'UCloud','ai':'Aliyun'}
AI_QA_BETA = {'cn-beijing':['cn-beijing-a']}


## return value of regx match pattern
def re_pattern(pattern, text):
    match = re.search(pattern, text)
    try:
        s = match.start()
        e = match.end()
        return text[s:e]
    except:
        plt = platform.platform().split('-')
        return plt[-2]


## return hash value
def hashInfo(param):
    hash = hashlib.md5()
    hash.update(param.encode())
    return hash.hexdigest()


## return disk value of '/data' prefix
def diskInfo():
    disk_info = subprocess.check_output("df|grep '/data'|awk '{print $2}'", shell=True).decode('utf-8').split('\n')
    disk_size = 0
    for disk in disk_info:
        if disk:
            disk_size += int(disk)
    disk_size = str(round(disk_size / 1024 / 1024)) + 'GB'
    return disk_size


## return network interface name list
def network():
    network_name = []
    with open('/proc/net/dev', 'r') as fd:
        for line in fd.readlines():
            if line.strip().startswith('eth'):
                network_name.append(line.strip().split(':')[0])
    network_name.reverse()
    return network_name


## return ip of network interface
def ipaddr(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(s.fileno(), 0x8915, struct.pack('256s', bytes(ifname[:15], 'utf-8')))[20:24])


## get all system value,and return "sys_info" dict
def sysInfo():
    sys_info = {}
    hostname = socket.gethostname()
    cpu_core_num = os.cpu_count()
    with open('/proc/meminfo', 'r') as fd:
        for line in fd.readlines():
            if line.startswith('MemTotal'):
                mem_info = line.split(':')[1].strip()
                mem = round(int(mem_info.split(' ')[0]) / 1024)
                break
    with open('/etc/issue', 'r') as fd:
        for line in fd.readlines():
            sys_num = re_pattern("([0-9]{1,2}\.)+[0-9]{1,2}", line)
            if sys_num.startswith('7.'):
                sys_os = 'centos' + sys_num
            else:
                sys_os = line.split(' ')[0] + sys_num
            break
    node = uuid.getnode()
    mac = uuid.UUID(int=node).hex[-12:]
    interface = network()
    private_ip = ipaddr(interface[-1])
    interface.pop()
    ext_private_ip = ""
    if interface:
        for net in interface:
            ext_private_ip = ext_private_ip + " " + ipaddr(net)
        ext_private_ip = ext_private_ip.strip()
    host_id = hashInfo(private_ip + mac)
    ptform = hostname.split('-')[1]
    business = hostname.split('-')[0] + '-' + hostname.split('-')[2]
    disk = diskInfo()
    if ptform == 'ud':
        region = 'cn-bj2'
        project_id = 'org-10071'
        if business == 'jkb-prod':
            if private_ip.startswith('10.10'):
                zone = JKB_UD_PROD[region][1]
            if private_ip.startswith('10.19'):
                zone = JKB_UD_PROD[region][2]
        if business == 'tsb-prod':
            if private_ip.startswith('10.10'):
                zone = TSB_UD_PROD[region][1]
            if private_ip.startswith('10.19'):
                zone = TSB_UD_PROD[region][2]
        if business == 'ycb-prod':
            zone = YCB_UD_PROD[region][0]
    if ptform == 'ai':
        project_id = ''
        if business == 'tsb-prod':
            region = 'cn-hangzhou'
            zone = TSB_AI_PROD[region][0]
        qa_beta_business = ['jkb-qa','jkb-beta','tsb-qa','tsb-beta']
        for qb in qa_beta_business:
            if business == qb:
                region = 'cn-beijing'
                zone = AI_QA_BETA[region][0]

    sys_info['ext_private_ip'] = ext_private_ip
    sys_info['private_ip'] = private_ip
    sys_info['hostname'] = hostname
    sys_info['system'] = sys_os
    sys_info['mem'] = mem
    sys_info['cpu_core_num'] = cpu_core_num
    sys_info['platform'] = ptform
    sys_info['business'] = business
    sys_info['disk'] = disk
    sys_info['host_id'] = host_id
    sys_info['zone'] = zone
    sys_info['region'] = region
    sys_info['project_id'] = project_id
    return sys_info


def log_error(message):
    logger = logging.getLogger('collector')
    log_dir = '/data/logs/collector/'
    log_filename = log_dir + 'collector.error.log'
    if os.path.exists(log_dir):
        pass
    else:
        os.makedirs(log_dir)
    logger.setLevel(logging.INFO)
    datefmt = '%Y-%m-%d %H:%M:%S'
    # datefmt = '%Y-%m-%d %H:%M:%S %p'
    frt_args = "%(asctime)s %(name)s %(levelname)s %(message)s"
    formatter = logging.Formatter(frt_args, datefmt=datefmt)
    handler = logging.handlers.RotatingFileHandler(log_filename, maxBytes=256 * 10 ** 6, backupCount=5)
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.error(message)
    logger.removeHandler(handler)
    handler.close()

if __name__ == '__main__':
#    print(sysInfo())
    data_args = sysInfo()
    encoded_args = parse.urlencode(data_args).encode('utf-8')
    url = 'https://x.x.x.x:1024/api/cloud-assets/'
    r = request.Request(url=url, data=parse.urlencode(data_args).encode('utf-8'))
    r.add_header('Authorization', 'Token 636df046287b95c50944d955c9e22eb297e6bf3f')
    try:
        rt = request.urlopen(r)
        if rt.code == 201 or rt.code == 202:
            pass
        else:
            log_error(traceback.format_exc())
    except (error.HTTPError,error.URLError) as e:
        message = "reason:{}".format(e.reason)
        log_error(message)
