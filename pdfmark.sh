#!/bin/bash -e
# pdfmark.sh
# @author: Mike Turi's modifications of Nestor Urquiza's pdfmark.sh in pdf-bash-tools repository
# @date: 20230508
# @description: Accepts a pdfmark file. See http://partners.adobe.com/public/developer/en/acrobat/sdk/pdf/pdf_creation_apis_and_specs/pdfmarkReference.pdf
#               Then it applies the metadata to the input pdf file generating the resulting output file
#               It is optional to specify the where to start modifications (first page number), where to end modifications (last page number), and password.

USAGE="Usage: `basename $0` <pdf_from_file> <pdf_to_file> <pdfmark_file> [first_page] [last_page] [password]"
 
if [ $# -lt "3" ] 
then
    echo $USAGE
    exit 1 
fi

pdf_from_file=$1
pdf_to_file=$2
pdfmark_file=$3
first_page=$4
last_page=$5
password=$6

if [ -z $first_page ]
then
    firstpage_switch=""
else
    firstpage_switch="-dFirstPage=$first_page"
fi

if [ -z $last_page ]
then
    lastpage_switch=""
else
    lastpage_switch="-dLastPage=$last_page"
fi

if [ -z $password ]
then
    user_pwd_switch=""
    owner_pwd_switch=""
    pdf_pwd_switch=""
else
    user_pwd_switch="-sUserPassword=$password"
    owner_pwd_switch="-sOwnerPassword=$password"
    pdf_pwd_switch="-sPDFPassword=$password"
fi

gs $pdf_pwd_switch $owner_pwd_switch $user_pwd_switch -dBATCH -dNOPAUSE -q $firstpage_switch $lastpage_switch -dAutoRotatePages=/None -sOutputFile="$pdf_to_file" \
    -sDEVICE=pdfwrite "$pdfmark_file" "$pdf_from_file"
