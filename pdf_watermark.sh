#!/bin/bash -e
# pdf_watermark.sh
# @author: Mike Turi modifications of Nestor Urquiza's pdf_watermark.sh in pdf-bash-tools repository
# @date: 20230508
# @description: Creates a temporary pdfmark and merges it with the input pdf to produce a watermark with a custom text
#               It is optional to specify the x- and y-position for the watermark, where to start the watermark (first page number), where to end the watermark (last page number), and password.

USAGE="Usage: `basename $0` <pdf_from_file> <pdf_to_file> <watermark> [xpos] [ypos] [first_page] [last_page] [password]"
 
if [ $# -lt "3" ] 
then
    echo $USAGE
    exit 1 
fi

pdf_from_file=$1
pdf_to_file=$2
watermark=$3
xpos=$4
ypos=$5
first_page=$6
last_page=$7
password=$8

if [ $# -lt "4" ]
then
    xpos=130
fi

if [ $# -lt "5" ]
then
    ypos=70
fi

#tmpfile=$(mktemp /tmp/pdf_watermark.XXXXXX)
tmpfile=mark.ps

#font="/Helvetica-Bold 72 selectfont"
color="0.4 setgray"
#color=".2 .2 .2 setrgbcolor"
angle=50


! read -d '' pdf_mark <<EOF
<<
   /EndPage
   {
     2 eq { pop false }
     {
         gsave      
         /Times-Roman findfont
         48 scalefont
         setfont
         newpath
         $((xpos)) $(($ypos)) moveto
         $(($angle)) rotate
         (${watermark}) true charpath
         0.25 setlinewidth
         (${color})
         stroke
         grestore
         true
     } ifelse
   } bind
>> setpagedevice
EOF

echo  "$pdf_mark" > "$tmpfile" 
./pdfmark.sh "$pdf_from_file" "$pdf_to_file" "$tmpfile" "$first_page" "$last_page" "$password"
rm "$tmpfile"
