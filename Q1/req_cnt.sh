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
  gzip -dc "${FILE}" | sed -r '/^\s*$/d' | wc -l
else
  echo "${FILE} not exist"
fi
