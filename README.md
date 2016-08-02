# docker-zabbix-agentd
A Debian latest based Docker container running zabbix_agentd in a CoreOS instance.

Environment variables prefixed with "ZBX_CONF_" will be written to /etc/zabbix/zabbix_agentd.d/80-env-generated.conf (override by setting ZBX_CONFIGFILE).  
ZBX_CONF_ServerActive=proxy02,server01 => ServerActive=proxy02,server01  
To support multiple UserParameter settings "_[0-9]*" will be cut from the end.

## From cloud-config
```
#cloud-config

coreos:
  units:
    - name: zabbix-agentd.service
      command: start
      content: |
        [Unit]
        Description=Zabbix Monitor Agent
        Documentation=https://www.zabbix.com/documentation/2.2/manual/concepts/agent
        [Service]
        ExecStartPre=/bin/sh -c 'cat >> /tmp/zabbix-agentd-env.txt <<<ZBX_CONF_Server=proxy02,server01'
        ExecStartPre=/bin/sh -c 'cat >> /tmp/zabbix-agentd-env.txt <<<ZBX_CONF_ServerActive=proxy02'
        ExecStartPre=/bin/sh -c 'cat >> /tmp/zabbix-agentd-env.txt <<<ZBX_CONF_EnableRemoteCommands=1'
        ExecStartPre=/bin/sh -c 'cat >> /tmp/zabbix-agentd-env.txt <<<ZBX_CONF_StartAgents=10'
        ExecStartPre=/bin/sh -c 'cat >> /tmp/zabbix-agentd-env.txt <<<ZBX_CONF_Timeout=30'
        ExecStartPre=/bin/sh -c 'cat >> /tmp/zabbix-agentd-env.txt <<<ZBX_CONF_Hostname=$(/bin/hostname -f)'
        ExecStart=/usr/bin/docker run --rm --env-file=/tmp/zabbix-agentd-env.txt --net=host --name zabbix-agentd godmodelabs/docker-zabbix-agentd:zabbix22
        ExecStop=-/usr/bin/docker stop zabbix-agentd
        ExecStopPost=-/bin/rm -f /tmp/zabbix-agentd-env.txt
```
