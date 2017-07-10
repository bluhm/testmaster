#!/bin/sh

action="$SSH_ORIGINAL_COMMAND"
setenv="/usr/local/bin/envdir /home/$USER/env"
PATH="/home/test/bin:$PATH"

case "$action" in
	""|"console")
		exec /usr/local/bin/console "$USER"
		;;
	"on"|"off"|"cycle")
		if $setenv checklock.sh; then
			exec $setenv power.sh $action
		fi
		;;
	"setup"|"install")
		if $setenv checklock.sh; then
			exec $setenv install.sh
		fi
		;;
	"upgrade")
		if $setenv checklock.sh; then
			exec $setenv upgrade.sh
		fi
		;;
	"env")
		if $setenv checklock.sh; then
			exec $setenv env
		fi
		;;
	"lock")
		exec $setenv lock.sh
		;;
	"free")
		exec $setenv free.sh
		;;
	"help")
		echo "        - console"
		echo "on      - power on"
		echo "off     - power off"
		echo "cycle   - power cycle"
		echo "install - install current snapshot"
		echo "upgrade - upgrade to current snapshot"
		echo "lock    - lock access to machine"
		echo "free    - free access to machine"
		echo "help    - print this message"
		;;
	*)
		echo "unknown command";;
esac

exit 1
