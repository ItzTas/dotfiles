#!/usr/bin/env bash
# Keeps a freshly started Spotifast muted until it is playing on this device at
# volume 0, then unmutes its output stream.

out=""
count=0
until [ -n "$out" ] || [ "$count" -ge 40 ]; do
	sleep 0.5
	count=$((count + 1))
	out=$(pw-dump 2>/dev/null | jq -r 'first(.[] | select(.info.props["node.name"]? // "" | test("^spotifast\\.soloist\\..*\\.output$")) | .id) // empty')
done
[ -n "$out" ] || exit 0
wpctl set-mute "$out" 1
trap 'wpctl set-mute "$out" 0' EXIT

id=""
count=0
until [ -n "$id" ] || [ "$count" -ge 30 ]; do
	sleep 0.5
	count=$((count + 1))
	device=$(ps -o args= -C soloist | sed -n 's/.*--device-name \(.*\) --api-key.*/\1/p' | head -1)
	[ -n "$device" ] || continue
	id=$(spotifast devices 2>/dev/null | grep -F "$device" | grep -oE "[0-9a-f-]{36}")
done
[ -n "$id" ] || exit 0

ok=0
for _ in $(seq 60); do
	if [ "$(playerctl -p spotifast status 2>/dev/null)" != Playing ]; then
		ok=0
		spotifast devices 2>/dev/null | grep -q "^\* $id" || {
			spotifast transfer "$id"
			sleep 2.5
		}
		spotifast play
		sleep 1
		continue
	fi
	if [ "$(playerctl -p spotifast volume 2>/dev/null)" != 0.000000 ]; then
		ok=0
		spotifast volume 0
		sleep 0.5
		continue
	fi
	ok=$((ok + 1))
	[ "$ok" -ge 10 ] && exit 0
	sleep 0.5
done
spotifast pause
