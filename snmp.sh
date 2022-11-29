#!/bin/sh

set -eu

GUDES="1 2 3"
PORTS="1 2 3 4 5 6 7 8"

HOSTS="1 2 3 4 5 6 7  10 11 14 15  21 26 27 28 29  31 32"
INTERFACES="1 2 3 4 5 6 7 8 9"

export snmparg="-O qv -v 2c -c public"

echo "/* THIS FILE IS AUTO GENERATED BY snmp.sh */"

#
# collect power socket states
#

for g in $GUDES; do
	for p in $PORTS; do
		stat=$(snmp get $snmparg gude$g .iso.org.dod.internet.private.enterprises.28507.1.1.2.2.1.3.$p) || break
		name=$(snmp get $snmparg gude$g .iso.org.dod.internet.private.enterprises.28507.1.1.2.2.1.2.$p) || break

		echo "#g${g}p${p}::before { content: \"$name\"; }"
		if [ $stat -eq 1 ]; then
			echo "#g${g}p${p} { background-color: #73d216; }"
		else
			echo "#g${g}p${p} { background-color: #cc0000; }"
		fi
	done
	echo
done

# gude 4
for p in $(jot 12); do
	stat=$(snmp get $snmparg gude4 1.3.6.1.4.1.28507.56.1.3.1.2.1.3.$p) || break
	name=$(snmp get $snmparg gude4 1.3.6.1.4.1.28507.56.1.3.1.2.1.2.$p) || break

	echo "#g4p${p}::before { content: \"$name\"; }"
	if [ $stat -eq 1 ]; then
		echo "#g4p${p} { background-color: #73d216; }"
	else
		echo "#g4p${p} { background-color: #cc0000; }"
	fi
done
echo

# epower
p=1
ftp -o /dev/stdout http://admin:admin@epower/config/home_f.html | \
    grep ^socket | tr -d ' ' | cut -d, -f2,3 | while read s; do
	stat="${s##*,}"
	name="${s%%,*}"
	echo "#ep${p}::before { content: $name; }"
	if [ $stat -eq 1 ]; then
		echo "#ep${p} { background-color: #73d216; }"
	else
		echo "#ep${p} { background-color: #cc0000; }"
	fi
	p=$((p + 1))
done
echo

#
# collect interface information
#

for ot in $HOSTS; do
	for i in $INTERFACES; do
		name=$(snmp get $snmparg -r 0 ot$ot .iso.org.dod.internet.mgmt.mib_2.ifMIB.ifMIBObjects.ifXTable.ifXEntry.ifName.$i) || break
		speed=$(snmp get $snmparg -r 0 ot$ot .iso.org.dod.internet.mgmt.mib_2.ifMIB.ifMIBObjects.ifXTable.ifXEntry.ifHighSpeed.$i) || break

		if [ "$name" = "No Such Object available on this agent at this OID" ]; then
			continue
		fi

		if [ "$name" = "No Such Instance currently exists at this OID" ]; then
			continue
		fi

		if [ "$name" = "No Such Instance currently exists at this OID" ]; then
			break 1
		fi

		if [ "$name" = "enc0" -o "$name" = "lo0" -o "$name" = "pflog0" ]; then
			echo "#ot${ot}i${i} { display: none; }"
			continue
		fi

		echo "#ot${ot}i${i}::before { content: \"$name\"; }"

		if [ $speed -eq 0 ]; then
			echo "#ot${ot}i${i} { background-color: #d3d7cf; }"
		else
			echo "#ot${ot}i${i} { background-color: #73d216; }"
		fi
	done
	echo
done
