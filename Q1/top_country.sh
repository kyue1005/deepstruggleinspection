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

if [ -f "${FILE}" ]; then
  TOP_IP=$(gzip -dc "${FILE}" | cut -d' ' -f1 | sort | uniq -c | sort -r | head -n 1 | cut -d' ' -f2)
  whois ${TOP_IP} | grep -iE ^country:
else
  echo "${FILE} not exist"
fi