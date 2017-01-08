#!/bin/sh
: "${VIM_EXE:=vim}"
OUTFILE='outputs'

$VIM_EXE -S runner.vim  -Nu ./fixtures/vimrc -R '+SnowflakeRunTest' -c 'qa!'

cat $OUTFILE

IS_FAILED=`grep "Failures: 0" $OUTFILE | wc -l`
if [ $IS_FAILED -eq 0 ]; then
  exit 1
fi
exit 0
