#!/bin/bash

for workspace in {1..9} 0; do
	i3-resurrect restore -w "$workspace"
done
