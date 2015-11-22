#!/bin/bash
#
# https://github.com/jasonmcintosh/rabbitmq-zabbix
#
cd "$(dirname "$0")"
. .rab.auth
./api.py --username=$USERNAME --password=$PASSWORD --hostname=$RABBITMQ_HOSTNAME --port=$RABBITMQ_PORT --check=list_queues --filter="$FILTER" --conf=$CONF
