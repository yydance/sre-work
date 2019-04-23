#!/bin/bash
#
# os: ubuntu 16.04

if [ $1 -eq 0 ];then
  useradd -s /sbin/nologin mysql
  apt-get -y install cmake bison g++ build-essential libncurses5-dev make libjemalloc-dev gnutls-dev
fi

# mariadb releases: https://downloads.mariadb.org/mariadb/+releases/
base="data2"
source_dir="/root/mariadb-10.2.15"
port=3308
base_dir="/$base/app/mariadb"

mkdir -p /$base/app/mariadb /$base/appData/mariadb /$base/logs/mariadb /$base/tmp/mariadb /$base/pid /$base/app/scripts
chown -R mysql.mysql  /$base/app/mariadb /$base/appData/mariadb /$base/logs/mariadb /$base/tmp/mariadb
chmod 777 /$base/pid
[ ! -d $source_dir ] && tar xf /root/mariadb-10.2.15.tar.gz -C /root/
cd $source_dir
make clean
cmake . -DCMAKE_INSTALL_PREFIX=/$base/app/mariadb -DMYSQL_DATADIR=/$base/appData/mariadb -DMYSQL_UNIX_ADDR=/$base/appData/mariadb/mysql.sock  -DDEFAULT_CHARSET=latin1 -DDEFAULT_COLLATION=latin1_swedish_ci -DEXTRA_CHARSETS=all -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DENABLED_PROFILING=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DCMAKE_BUILD_TYPE:STRING=Release -DWITH_EMBEDDED_SERVER=0 -DWITH_UNIT_TESTS:BOOL=OFF -DINSTALL_LAYOUT:STRING=STANDALONE
make
make install
mkdir $base_dir/etc
chown -R mysql.mysql /$base/app/mariadb /$base/appData/mariadb /$base/logs/mariadb /$base/tmp/mariadb
echo never > /sys/kernel/mm/transparent_hugepage/enabled
cat >$base_dir/my.cnf<<EOF
[client]
port            = $port
socket          = /$base/appData/mariadb/mysql.sock
default-character-set = latin1
[mysqld]
server-id=1454470198
port            = $port
socket          = /$base/appData/mariadb/mysql.sock
basedir         = /$base/app/mariadb
datadir         = /$base/appData/mariadb
tmpdir          = /$base/tmp/mariadb
plugin-dir = /$base/app/mariadb/lib/plugin
plugin-load = ha_tokudb.so
back_log=1024
max_connections=4500
max_user_connections=4000
max_connect_errors=65536
wait_timeout=100
connect_timeout=20
interactive_timeout=100
skip-external-locking
skip-name-resolve
table_open_cache=6144
table_definition_cache=65536
max_allowed_packet = 128M
read_buffer_size = 128K
read_rnd_buffer_size = 128K
sort_buffer_size = 256K
join_buffer_size = 128K
thread_cache_size=256
thread_stack = 512K
query_cache_type=0
query_cache_limit = 1M
query_cache_min_res_unit = 1k
max_heap_table_size = 64M
tmp_table_size = 64M
character-set-server = latin1
default-storage-engine=TokuDB
performance_schema=0
binlog_cache_size=32k
max_binlog_size=500M
expire_logs_days=3
pid-file=/$base/pid/mariadb.pid
general-log-file=/$base/logs/mariadb/mariadb.info
slow-query-log-file=/$base/logs/mariadb/slow.info
log-error=/$base/logs/mariadb/mariadb.error
relay-log=/$base/appData/mariadb/mariadb-relay-bin
relay-log-index=/$base/appData/mariadb/mariadb-relay-bin.index
slave-net-timeout=30
replicate-wild-ignore-table=information_schema.%
replicate-wild-ignore-table=performance_schema.%
long_query_time = 2
key_buffer_size = 64M
myisam_sort_buffer_size = 64M
myisam_max_sort_file_size = 10G
concurrent_insert = 1
delayed_insert_timeout = 300
innodb_data_home_dir = /$base/appData/mariadb
innodb_log_group_home_dir = /$base/appData/mariadb
innodb_data_file_path = ibdata1:512M;ibdata2:16M:autoextend
innodb_buffer_pool_size = 2G
innodb_buffer_pool_instances = 1
innodb_log_files_in_group = 3
innodb_log_file_size = 512M
innodb_log_buffer_size = 128M
innodb_flush_log_at_trx_commit = 2
innodb_max_dirty_pages_pct = 60
innodb_io_capacity = 400
innodb_read_io_threads = 4
innodb_write_io_threads = 4
innodb_open_files = 60000
innodb_file_format = Barracuda
innodb_file_per_table = 1
innodb_flush_method = O_DIRECT
innodb_change_buffering = inserts
innodb_adaptive_flushing = 1
innodb_old_blocks_time = 1000
innodb_stats_on_metadata = 0
innodb_read_ahead_threshold = 0
innodb_use_native_aio = 0
innodb_lock_wait_timeout = 5
innodb_rollback_on_timeout = 0
innodb_purge_threads = 1
innodb_strict_mode = 1
transaction-isolation = READ-COMMITTED
tokudb_commit_sync = 0
tokudb_cache_size = 4G
tokudb_empty_scan = disabled
tokudb_directio = 1
tokudb_read_block_size = 128K
tokudb_read_buf_size = 128K
tokudb_fs_reserve_percent = 2
[mysqldump]
quick
max_allowed_packet = 128M
[mysql]
no-auto-rehash
prompt=(\u@\h) [\d]>\_
[myisamchk]
key_buffer_size = 64M
sort_buffer_size = 256k
[mysqlhotcopy]
interactive-timeout
[mysqld_safe]
open-files-limit = 65536
EOF

$source_dir/scripts/mysql_install_db --user=mysql --basedir=/$base/app/mariadb --datadir=/$base/appData/mariadb --defaults-file=$base_dir/my.cnf
# 启动脚本，参考/data/app/scripts/mariadb.sh
# 手动修改变量$data
cp $source_dir/support-files/mysql.server /$base/app/scripts/mariadb.sh
chmod +x /$base/app/scripts/mariadb.sh
