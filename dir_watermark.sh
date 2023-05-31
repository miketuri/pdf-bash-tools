#!/bin/bash -e
# dir_watermark.sh
# @author: Mike Turi
# @date: 20230531
# @description: Adds watermarks to each file in a directory (assuming all files are PDFs).  Need to define the directory name and first watermark as arguments; the second watermark is the name of the PDF file without the .pdf extension.  Repeatedly calls watermark_repeat.sh to produce each file's watermarks.
#

USAGE="Usage: `basename $0` <dirname> <watermark1>"

if [ $# -lt "2" ] 
then
    echo $USAGE
    exit 1 
fi

dirname=$1
watermark1=$2

fname="foo"
watermark2="bar"
len=0

for pdffile in "$dirname"/*
do
    fname=$(basename $pdffile)
    len=${#fname}
    watermark2=${fname:0:(($len-4))}
    watermark2+=" $watermark2"
    watermark2+=" $watermark2"
    ./watermark_repeat.sh "$pdffile" "$watermark1" "${watermark2:0:32}"
done
