#!/bin/sh

usage() {
  echo "Usage: $0 [-s <zabbix_host>] -k <zabbix_item_key> <value>"
  exit 1
}

find_config() {
  if [ -f /etc/zabbix/zabbix_agent2.conf ]; then
    echo "/etc/zabbix/zabbix_agent2.conf"
  elif [ -f /etc/zabbix/zabbix_agentd.conf ]; then
    echo "/etc/zabbix/zabbix_agentd.conf"
  else
    echo ""
  fi
}

ZBX_HOST=""
ZBX_ITEM_KEY=""
VALUE=""

ZBX_SENDER_CONFIG="${ZBX_SENDER_CONFIG:-$(find_config)}"

if [ -z "$ZBX_SENDER_CONFIG" ] || [ ! -f "$ZBX_SENDER_CONFIG" ]; then
  echo "Error: No Zabbix configuration file found."
  exit 1
fi

while getopts "s:k:" opt; do
  case $opt in
    s) ZBX_HOST="$OPTARG" ;;
    k) ZBX_ITEM_KEY="$OPTARG" ;;
    *) usage ;;
  esac
done

if [ -z "$ZBX_ITEM_KEY" ]; then
  usage
fi

shift $((OPTIND - 1))
if [ $# -eq 0 ]; then
  usage
fi
VALUE="$*"

# Aggiungi il parametro -s solo se ZBX_HOST è definito
if [ -n "$ZBX_HOST" ]; then
  exec zabbix_sender --config "$ZBX_SENDER_CONFIG" -s "$ZBX_HOST" --key "$ZBX_ITEM_KEY" --value "$VALUE"
else
  exec zabbix_sender --config "$ZBX_SENDER_CONFIG" --key "$ZBX_ITEM_KEY" --value "$VALUE"
fi
