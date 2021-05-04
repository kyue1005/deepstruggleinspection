#! /bin/bash

usage() {
    echo "Usage:"
    echo "top10_host.sh [-f FILE]"
    echo "Description:"
    echo "FILE,the path of gziped log file."
    exit -1
}

while getopts hf: opt; do
  case "${opt}" in
    f) FILE="${OPTARG}";;
    h) usage;;
    ?) usage;;
  esac
done

if [ -z ${FILE} ]; then
  usage
fi

if [ -f "${FILE}" ]; then
  TOP_IP=$(gzip -dc "${FILE}" | awk '{print $1}' | sort | uniq -c | sort -t ' ' -k 1rn | head -n 1 | awk '{print $2}')
  whois ${TOP_IP} | grep -iE ^country:
else
  echo "${FILE} not exist"
fi