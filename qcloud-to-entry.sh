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

formatted_date() {
  echo '['$(date '+%Y-%m-%d %H-%M-%S')']'
}

resume_downloading() {
  echo $(formatted_date) 'start downloading' $1
  wget -q $DATA_ROOT/$1 -P data-downloading
  echo $(formatted_date) 'downloading' $1 'completed'
  mv data-downloading/$1 data-sending/ 
}

send_data_to_entry() {
  echo $(formatted_date) 'start sending' $1
  cat data-sending/$1 \
    | awk -f $SCRPT_DIR/formatter.awk \
    | $DIST_ROOT/bin/xurl
  echo $(formatted_date) 'sending' $1 'completed' 
  rm -vf data-sending/$1
}

download_and_send() {
  ls data-downloading \
    | xargs -n 1 -P $MAX_PROCS sh -c \
        'rm data-downloading/"$@" && resume_downloading "$@" && send_data_to_entry "$@"' _
}


#______________________________________________________________________________
# The Main Program

export DATA_ROOT=$DATA_ROOT
export DIST_ROOT=$DIST_ROOT
export SCRPT_DIR=$SCRPT_DIR
export MAX_PROCS=$MAX_PROCS

export -f formatted_date
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
cat index-old.txt | xargs -i rm -vf {}
wget $DATA_ROOT/index.txt

diff index-old.txt index.txt \
  | grep '^> ' \
  | tr -d '> ' \
  | xargs -i touch data-downloading/{}

download_and_send
