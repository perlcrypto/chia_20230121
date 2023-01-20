#!/bin/sh

LOCK_FILE=/home/jsp/plot_mv.lock

if [ -f $LOCK_FILE ]; then
  echo "This script is already running!"
  exit 1
fi

touch $LOCK_FILE

if [ ! -f $LOCK_FILE ]; then
  echo "Cannot create lock file!"
  exit 1
fi

perl ~/chia_blockchain/mv_plot.pl

rm -f ${LOCK_FILE}
