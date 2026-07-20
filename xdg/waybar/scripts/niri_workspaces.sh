#!/bin/bash

niri msg -j workspaces | jq -r '
  sort_by(.idx)
  | map(if .is_active then "[\(.idx)]" else "\(.idx)" end)
  | join(" ")
'
