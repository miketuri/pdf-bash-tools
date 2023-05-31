#!/bin/bash -e
# watermark_repeat.sh
# @author: Mike Turi
# @date: 20230531
# @description: Repeatedly prints custom text as a watermark across a page for additional page security.  Can have two different lines of watermark text.  Repeatedly calls pdf_watermark.sh to produce each watermark.
#               It is optional to specify the x- and y-position for the watermark(s), where to start the watermark(s) (first page number), where to end the watermark(s) (last page number), and password.

USAGE="Usage: `basename $0` <pdf_file> <watermark1> [watermark2] [first_page] [last_page] [password]"
 
if [ $# -lt "2" ] 
then
    echo $USAGE
    exit 1 
fi

pdf_from_file=$1
pdf_to_file="${pdf_from_file}.tmp.pdf"
watermark1=$2
watermark2=$3
first_page=$4
last_page=$5
password=$6

if [ $# -lt "3" ]
then
    watermark2="$watermark1"
fi

echo "$pdf_from_file **Note: 32 character max. for watermark text**"

x=80
y=0
pos=0

flag1st=1

for((y=0;y<8;y++))
do
    if (($flag1st==0))
    then
        first_page=""
        last_page=""
    fi

    pos=$[$y*100]
    if (($y%2==0))
    then
        ./pdf_watermark.sh "$pdf_from_file" "$pdf_to_file" "$watermark1" "$x" "$pos" "$first_page" "$last_page" "$password"
	flag1st=0
    else
        ./pdf_watermark.sh "$pdf_from_file" "$pdf_to_file" "$watermark2" "$x" "$pos" "$first_page" "$last_page" "$password"
	flag1st=0
    fi
    mv "$pdf_to_file" "$pdf_from_file"

done

y=0

for((x=1;x<5;x++))
do

    if (($flag1st==0))
    then
        first_page=""
        last_page=""
    fi

    pos=$[80+$x*100]
    if (($x%2==0))
    then
        ./pdf_watermark.sh "$pdf_from_file" "$pdf_to_file" "$watermark1" "$pos" "$y" "$first_page" "$last_page" "$password"
	flag1st=0
    else
        ./pdf_watermark.sh "$pdf_from_file" "$pdf_to_file" "$watermark2" "$pos" "$y" "$first_page" "$last_page" "$password"
	flag1st=0
    fi
    mv "$pdf_to_file" "$pdf_from_file"

done

