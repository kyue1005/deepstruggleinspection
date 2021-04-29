#! /bin/bash

usage() {
    echo "Usage:"
    echo "top10_host.sh [-f FILE]"
    echo "Description:"
    echo "FILE,the path of gziped log file."
    exit -1
}

while getopt ":f" opt; do
  case "${opt}" in
    f) FILE="${OPTARG}";;
    h) usage;;
    ?) usage;;
  esac
done

echo $opt

if [ -z "${f}" ]; then
    usage
fi

if [ -f "${FILE}" ]; then
  gzip -d "${FILE}" | cut -d' ' -f1 | sort | uniq -c | sort -r | head -n 10
fi