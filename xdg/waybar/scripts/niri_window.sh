#!/bin/bash

niri msg -j focused-window | jq -r '.title // ""'
