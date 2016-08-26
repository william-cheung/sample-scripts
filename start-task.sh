#!/bin/bash

PROC_DIR=$(dirname $0)
PROC_EXE=qcloud-to-entry.sh
PROC_NAME=qcloud-to-entry

pid=$(pgrep $PROC_NAME)
if [ -n "$pid" ]; then
  echo "There is still an instance of '$PROC_NAME' running. Quit ..."
  exit 1
fi

if [ ! -d $PROC_DIR/log ]; then
  mkdir $PROC_DIR/log
fi

nohup $PROC_DIR/$PROC_EXE > $PROC_DIR/log/$(date '+%Y-%m-%d-%H-%M-%S').txt &
exit 0
