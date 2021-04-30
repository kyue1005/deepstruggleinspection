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
  gzip -dc "${FILE}" | awk '{print $1}' | sort | uniq -c | sort -t ' ' -k 1rn | head -n 10
else
  echo "${FILE} not exist"
fi
