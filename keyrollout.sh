#!/bin/sh

set -eu

# FreeBSD, Linux, OpenBSD Test and virt KVM server
for m in /home/[flo]t*/users /home/virt/users; do
	authfile="$(dirname "$m")/.ssh/authorized_keys"
	echo -n "renew $authfile"
	rm -f "$authfile"
	for user in $(cat "$m"); do
		if [ ! -s "/home/test/sshkeys/$user" ]; then
			echo "$user in $m does not have a key" > /dev/stderr
			continue
		fi
		echo -n " $user"
		sed -e "s/^/environment=\"testuser=$user\" /" \
		    "/home/test/sshkeys/$user" >> "$authfile"
	done
	echo
done
