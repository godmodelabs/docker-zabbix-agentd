#!/bin/bash

# enable bash debugging if DEBUG is set to "1"
[ ${DEBUG:-0} = "1" ] && set -x

# generate config
config_file=${ZBX_CONFIGFILE:-/etc/zabbix/zabbix_agentd.d/80-env-generated.conf}

## get all variables prefixed with ZBX_CONF_
for env_zabbix_option in ${!ZBX_CONF_*}
do
    zabbix_option=${env_zabbix_option#ZBX_CONF_}
    zabbix_option=${zabbix_option%_[0-9]*}
    echo "${zabbix_option}=${!env_zabbix_option}"
done > "${config_file}"
# generate config -- end

# remove hostname setting from default zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server/# Hostname=Zabbix server/g' /etc/zabbix/zabbix_agentd.conf

# create fifo as logfile so we don't waste disk space
log_file=/var/log/zabbix/zabbix_agentd.log
[ ! -e ${log_file} ] && mkfifo ${log_file} && chown zabbix:zabbix ${log_file}
## disable log rotation and set fifo as log file
echo "LogFile=${log_file}" >> /etc/zabbix/zabbix_agentd.d/99-log-rotation.conf
echo "LogFileSize=0" >> /etc/zabbix/zabbix_agentd.d/99-log-rotation.conf

# connect to fifo before agent starts
timeout 2 cat ${log_file} &

# start agentd
/usr/sbin/zabbix_agentd
## wait for cat to exit
wait
## use tail to wait for pid
agent_pid=`pgrep -o zabbix_agentd`
[ -n "${agent_pid}" ] && kill -0 ${agent_pid} && tail -F --pid=${agent_pid} ${log_file}
