#!/bin/bash

if [ -f ~/.sshagent ]; then
   source ~/.sshagent
fi

if [ "`ps -q $SSH_AGENT_PID -o comm=`" != "ssh-agent" ]; then
   echo "launching ssh-agent..."
   ssh-agent | grep export > ~/.sshagent
   source ~/.sshagent
fi

#. ~/.sshagent

