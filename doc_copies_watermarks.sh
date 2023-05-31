#!/bin/bash -e
# doc_copies_watermarks.sh
# @author: Mike Turi
# @date: 20230531
# @description: Assumes the specified PDF contains duplicate copies of a file; e.g., a ten-page PDF may contain five copies of a two-page document.  This script adds one watermark, "watermark1", for each page in the specified PDF and adds a second watermark unique to each document copy; the unique watermarks must be defined in a file, the "unique_watermark_file",  and separated by newlines.  The number of pages per copy of the document (e.g., 2 for the above example) and total number pages of the PDF (e.g., 10 for the above example) must also be specified.  Watermarked PDF copies will be generated and then combined to overwrite the original PDF; if you wish to delete the watermarked PDF copies (e.g., 5 total for the above example) then pass any value/character for the optional "rm_pdf_copies" parameter.  It is also optional to specify a password for the final PDF.  This script calls watermark_repeat.sh to produce each file's watermarks.
#

USAGE="Usage: `basename $0` <pdf_file> <watermark1> <unique_watermark_file> <pages_per_copy> <total_pages> [rm_pdf_copies] [password]"

if [ $# -lt "5" ]
then
    echo $USAGE
    exit 1 
fi

pdf_from_file=$1
pdfname=$(basename $pdf_from_file)
pdf_to_file="${pdf_from_file}.tmp.pdf"
watermark1=$2
unique_watermark_file=$3
#readarray -t uniquewmarray < "$unique_watermark_file"
IFS=$'\r\n' GLOBIGNORE='*' command eval 'uniquewmarray=($(cat $unique_watermark_file))'
pages_per_copy=$4
total_pages=$5
rm_pdf_copies=$6
password=$7

first_pg=1
last_pg=$(($first_pg+$pages_per_copy-1))

i=0
while [ $last_pg -le $total_pages ]
do
    len=${#uniquewmarray[$i]}
    uniquewm=${uniquewmarray[$i]:1:(($len-2))}
    newpdf="${pdfname}.${uniquewm}.pdf"
    uniquewmarray[$i]=$newpdf
    #echo "$newpdf" "$uniquewm"
    uniquewm+=$uniquewm
    uniquewm+=$uniquewm
    i=$(($i+1))
    #cp "$pdf_from_file" "$newpdf"
    gs -dAutoRotatePages=/None -dFirstPage="$first_pg" -dLastPage="$last_pg" -sDEVICE=pdfwrite -o "$newpdf" "$pdf_from_file"
    ./watermark_repeat.sh "$newpdf" "$watermark1" "${uniquewm:0:32}"
    first_pg=$(($first_pg+$pages_per_copy))
    last_pg=$(($last_pg+$pages_per_copy))
done

# Assuming generated PDFs are in the script dir (and no other PDFs are there)
gs -dAutoRotatePages=/None -sDEVICE=pdfwrite -o "$pdf_from_file" *.pdf

if [ -z $rm_pdf_copies ]
then
   echo "Split PDFs remain in script directory"
else
   for j in "${uniquewmarray[@]}"
   do
       rm "$j"
   done
   echo "Split PDFs were deleted"
fi
