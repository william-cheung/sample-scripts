#!/bin/bash

PROC_NAME=qcloud-to-entry

function kill_pstree() {
  local proc=$1
  
  if [ -z "$proc" ]; then
    return
  fi 

  local subprocs=$(ps --ppid $proc | tail +2 | awk '{print $1}')

  echo "Killing process... PID $proc" 
  kill -9 $proc
  
  echo $subprocs | xargs sh -c 'kill_pstree "$@"' _ 
}

export -f kill_pstree

kill_pstree $(pgrep $PROC_NAME)