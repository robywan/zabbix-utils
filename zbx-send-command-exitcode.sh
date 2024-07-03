#!/bin/sh

usage() {
  echo "Usage: $0 -s <zabbix_host> -k <zabbix_item_key> <command>"
  exit 1
}

ZBX_HOST=""
ZBX_ITEM_KEY=""
ZBX_SENDER_CONFIG="${ZBX_SENDER_CONFIG:-/etc/zabbix/zabbix_agentd.conf}"
COMMAND=""

while getopts "s:k:" opt; do
  case $opt in
    s) ZBX_HOST="$OPTARG" ;;
    k) ZBX_ITEM_KEY="$OPTARG" ;;
    *) usage ;;
  esac
done

if [ -z "$ZBX_HOST" ] || [ -z "$ZBX_ITEM_KEY" ]; then
  usage
fi

shift $(($OPTIND - 1))
if [ $# -eq 0 ]; then
  usage
fi
COMMAND="$*"

$COMMAND
COMMAND_EXITCODE=$?

zabbix_sender --config "$ZBX_SENDER_CONFIG" -s "$ZBX_HOST" --key "$ZBX_ITEM_KEY" --value "$COMMAND_EXITCODE"

exit $COMMAND_EXITCODE
