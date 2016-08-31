#!/bin/bash

# URL prefix for downloading remote data files
DATA_ROOT=http://xxx.qcloud.com

# Run up to this number of processes downloading and
# sending data
MAX_PROCS=8

# Absolute path of this file
SCRPT_DIR=$(cd $(dirname $0); pwd)

# Aka 'output' directory in our spec.
DIST_ROOT=$SCRPT_DIR/../..

# Directory where we store temp data files
DATA_LDIR=$DIST_ROOT/status


#______________________________________________________________________________
# Functions
#   Preconditions:
#     Shell variables used MUST have been exported
#     $(pwd) = $(DATA_LDIR) && [[ -d data-downloading ]] && [[ -d data-sending]]  

log_info() {
  echo '['$(date '+%Y-%m-%d %H-%M-%S')']' $@
}

resume_downloading() {
  log_info 'Start downloading' $1
  
  wget -q $DATA_ROOT/$1 -P data-downloading
  
  if [[ ! -f data-downloading/$1 ]]; then
    log_info 'No such file or directory:' $DATA_ROOT/$1
  	return
  fi
  
  log_info 'Downloading' $1 'completed'
  
  mv data-downloading/$1 data-sending/ 
}

send_data_to_entry() {
  local data_file=data-sending/$1
  if [[ ! -f $data_file ]]; then
    return
  fi

  log_info 'Start sending' $data_file
  cat $data_file \
    | awk --posix -f $SCRPT_DIR/formatter.awk \
    | $DIST_ROOT/bin/url2entry $DIST_ROOT/conf/tencent/qcloud-to-entry.conf
  log_info 'Sending' $data_file 'completed' 
  rm -f $data_file
  log_info 'Removed' $data_file
}

download_and_send() {
  if [[ -z $(ls data-downloading) ]]; then
    return
  fi

  ls data-downloading \
    | xargs -n 1 -P $MAX_PROCS sh -c \
        'rm data-downloading/"$@"; resume_downloading "$@"; send_data_to_entry "$@"' _
}


#______________________________________________________________________________
# The Main Program

export DATA_ROOT=$DATA_ROOT
export DIST_ROOT=$DIST_ROOT
export SCRPT_DIR=$SCRPT_DIR
export MAX_PROCS=$MAX_PROCS

export -f log_info
export -f resume_downloading
export -f send_data_to_entry


if [[ ! -d $DATA_LDIR ]]; then
  mkdir -p $DATA_LDIR
fi

cd $DATA_LDIR

if [[ ! -d data-downloading ]]; then
  mkdir data-downloading
fi

if [[ ! -d data-sending ]]; then
  mkdir data-sending
fi

# restart getting partially-downloaded data files and 
# re-sending partially-sent data files 
download_and_send

if [[ ! -f index.txt ]]; then
  touch index.txt
fi

mv index.txt index-old.txt
wget -q $DATA_ROOT/index.txt

if [[ ! -f index.txt ]]; then
  log_info 'Fatal error: failed to download' $DATA_ROOT/index.txt
  exit 2
fi

diff index-old.txt index.txt \
  | grep '^> ' \
  | tr -d '> ' \
  | xargs -i touch data-downloading/{}

# download and send new data files
download_and_send
