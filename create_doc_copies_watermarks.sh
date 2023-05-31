#!/bin/bash -e
# create_doc_copies_watermarks.sh
# @author: Mike Turi
# @date: 20230531
# @description: This script adds watermarks and creates duplicate copies of a file.  For example, a four-page PDF can be watermarked and duplicated into twenty copies of the document; the resultant PDF will have eighty pages (4 * 20).  This script adds one watermark, "watermark1", for each page in the specified PDF and adds a second watermark unique to each document copy created; the unique watermarks must be defined in a file, the "unique_watermark_file",  and separated by newlines.  Watermarked PDF copies will be generated and then combined to overwrite the original PDF; if you wish to delete the watermarked PDF copies (e.g., 20 total for the above example) then pass any value/character for the optional "rm_pdf_copies" parameter.  It is also optional to specify a password for the final PDF.  This script calls watermark_repeat.sh to produce each file's watermarks.
#

USAGE="Usage: `basename $0` <pdf_file> <watermark1> <unique_watermark_file> [rm_pdf_copies] [password]"

if [ $# -lt "3" ]
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
rm_pdf_copies=$4
password=$5

for ((i=0; i < ${#uniquewmarray[@]}; i++))
do
    len=${#uniquewmarray[$i]}
    uniquewm=${uniquewmarray[$i]:1:(($len-2))}
    newpdf="${pdfname}.${uniquewm}.pdf"
    uniquewmarray[$i]=$newpdf
    uniquewm+=$uniquewm
    uniquewm+=$uniquewm
    gs -dAutoRotatePages=/None -sDEVICE=pdfwrite -o "$newpdf" "$pdf_from_file"
    ./watermark_repeat.sh "$newpdf" "$watermark1" "${uniquewm:0:32}"
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
