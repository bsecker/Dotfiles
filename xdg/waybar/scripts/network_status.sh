#!/bin/bash

ip -o -4 addr show dev wlp0s20f3 | awk '{split($4, address, "/"); print "󰤨  " address[1]}'
