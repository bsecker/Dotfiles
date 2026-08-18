#!/bin/bash
#
# Generates a new kube config file based on credentials found in the ~/.kube/configs directory
# see md file in same folder for instructions
#
# Notice
# * Will replace ~/.kube/config after creating a backup
# * Script with in-line replace any 'default' names found in configs files.

set -euxo pipefail

#export KUBECONFIG=~/.kube/config

for _f in ~/.kube/configs/* ; do
    # write to a temp file and then move it back to the original file
    # avoids stupid sed in-place replacement issues (AI generated fix)
    sed "s/ default/ $(basename "$_f")/" "$_f" > "$_f.tmp" && mv "$_f.tmp" "$_f"
    export KUBECONFIG="${KUBECONFIG:+$KUBECONFIG:}$_f" 
done

kubectl config view --flatten > ~/.kube/config.new

# Backup
if [ -e "$HOME/.kube/config" ] ; then
    mv ~/.kube/config "$HOME/.kube/config.$(date +'%F_%H-%M').bk"
fi

mv ~/.kube/config.new ~/.kube/config
