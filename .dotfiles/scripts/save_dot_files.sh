#!/bin/sh

check_and_commit() {
	if [ -n "$(yadm status --porcelain)" ]; then
		yadm commit -a -m "files updated"
		yadm push origin master
	fi
}

while true; do
	check_and_commit
	sleep 260
done
