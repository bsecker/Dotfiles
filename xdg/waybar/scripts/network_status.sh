#!/usr/bin/env bash

ip -o -4 addr show scope global | awk 'NR == 1 {split($4, address, "/"); print "󰤨  " address[1]}'
