#!/bin/bash
target=$1
red='\e[31m'
logo='\033[0;36m'
end='\e[0m'
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

#### Subdomain
rm -rf ${BASE_DIR}/out > /dev/null
printf "${red}[!] Subdomain enumeration [${logo}subfinder${end}${red}] . . . ${end}\t"
subfinder -d ${target} -recursive -silent -t 1000 -o ${BASE_DIR}/out/${target}_subfinder.txt > /dev/null
printf "[${logo}$(wc -l ${BASE_DIR}/out/${target}_subfinder.txt|awk '{print $1}')${end}]\n"
printf "${red}[!] Subdomain enumeration [${logo}findomain${end}${red}] . . . ${end}\t"
findomain --quite --resolved --target ${target} --unique-output out/${target}_findomain.txt >/dev/null
printf "[${logo}$(wc -l ${BASE_DIR}/out/${target}_findomain.txt|awk '{print $1}')${end}]\n"
printf "${red}[!] Subdomain enumeration [${logo}assetfinder${end}${red}] . . . ${end}\t"
assetfinder --subs-only ${target} | tee out/${target}_assetfinder.txt > /dev/null
printf "[${logo}$(wc -l ${BASE_DIR}/out/${target}_assetfinder.txt|awk '{print $1}')${end}]\n"
printf "${red}[!] Subdomain enumeration [${logo}amass${end}${red}] . . . ${end}\t"
amass enum -passive -d ${target} -silent -o out/{target}_amass.txt > /dev/null
printf "[${logo}$(wc -l ${BASE_DIR}/out/${target}_amass.txt|awk '{print $1}')${end}]\n"
cat ${BASE_DIR}/out/*.txt | anew | httprobe -prefer-https -t 1000 | tee ${BASE_DIR}/out/${target}_unique.txt > /dev/null
printf "[${logo}All Unique & Alive Subdomains:${end} \t ${logo}$(wc -l ${BASE_DIR}/out/${target}_unique.txt|awk '{print $1}') ${end}]\n"

#### WAF Identification
wafwoof -i ${BASE_DIR}/out/${target}_unique.txt -o ${BASE_DIR}/out/${target}_wafs.txt > /dev/null
cat ${BASE_DIR}/out/${target}_wafs.txt | sed -e 's/^[ \t]*//' -e 's/ \+ /\t/g' -e '/(None)/d' | tr -s "\t" ";" | tee ${BASE_DIR}/out/${target}_behind_waf.txt
printf "\n[${logo}Subdomain behind WAF:${end} \t ${logo}$(wc -l ${BASE_DIR}/out/${target}_behind_waf.txt|awk '{print $1}') ${end}} \n"



