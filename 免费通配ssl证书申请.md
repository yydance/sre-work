利用[acme.sh](https://github.com/Neilpang/acme.sh)生成通配证书，该项目从[letencrypt](https://letsencrypt.org/)获取证书

主要步骤：
- 安装前准备
- 安装acme.sh
- 生成证书
- 将证书copy到NGINX服务目录
- 配置NGINX ssl
- 更新acme.sh   

**安装前准备**  
利用dns的方式生成通配证书，这里用阿里云，需要两个变量  
```
export Ali_Key="123456"
export Ali_Secret="abcdef"
```

**1.安装acme.sh**  
```
curl  https://get.acme.sh | sh
```  

1.1 该脚本会将acme.sh安装到用户的**home**目录下：
```
~/.acme.sh
```  
并创建一个bash的alias，即`alias acme.sh=~/.acme.sh/acme.sh`   
1.2 自动创建cron job，每天自动检测所有的证书，如果即将过期，会自动更新证书，更高级安装选项参考:https://github.com/Neilpang/acme.sh/wiki/How-to-install  

**2.申请通配证书**  
```
acme.sh --issue --dns dns_ali -d halfsre.com -d *.halfsre.com
```  

2.1 安装证书
```
acme.sh --install-cert -d halfsre.com --cert-file /usr/local/nginx/conf/cert/halfsre.com.cer --key-file /usr/local/nginx/conf/cert/halfsre.com.key --fullchain-file /usr/local/nginx/conf/cert/halfsre.com.fullchain.cer --reloadcmd "systemctl nginx restart"
```  

**3.修改nginx配置文件**
```
ssl_certificate /etc/nginx/cert/halfsre.com.cer;
ssl_certificate_key /etc/nginx/cert/halfsre.com.key; 
include /etc/letsencrypt/options-ssl-nginx.conf;
```  

options-ssl-nginx.conf
```
ssl_session_cache shared:le_nginx_SSL:1m;
ssl_session_timeout 1440m;
ssl_protocols TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers "ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS";
```  

**4.重启nginx服务**
```
systemctl restart nginx
```  

可以看到自动检测更新crontab
```
16 0 * * * "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" > /dev/null
```
