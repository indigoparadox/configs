#!/bin/bash

USERNAME=`whoami`
echo "Username is: $USERNAME"

if [ ! -f "`pwd`/kubeconfig" ]; then
   echo "./kubeconfig not found!"
   exit 1
fi

echo "Setting KUBECONFIG to ./kubeconfig..."
export KUBECONFIG="`pwd`/kubeconfig"
echo "Set KUBECONFIG to: $KUBECONFIG"

echo "Getting secret..."
KUBE_SECRET="`kubectl -n kube-system get secret | grep $USERNAME | awk '{print $1}'`"

if [ -z "$KUBE_SECRET" ]; then
   echo "Could not get secret!"
   exit 1
fi

kubectl -n kube-system describe secret "$KUBE_SECRET" | grep "^token:" | awk '{print $2}' > auth.txt
echo "Auth key exported to auth.txt"
