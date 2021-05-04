#! /bin/bash
START_DT="10/Jun/2020:00:00:00"
END_DT="19/Jun/2020:23:59:59"

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
  # echo "\$4 >= \"[${START_DT}\" && \$4 <= \"[${END_DT}\" {print \$1 \$4}"
  # gzip -dc "${FILE}" | awk "\$4 >= \"[${START_DT}\" && \$4 <= \"[${END_DT}\" {print \$1 \$4}" | head -n 1
  gzip -dc "${FILE}" | awk "\$4 >= \"[${START_DT}\" && \$4 <= \"[${END_DT}\" {print \$1 $4 }" | sort | uniq -c | sort -t ' ' -k 1rn | head -n 10
else
  echo "${FILE} not exist"
fi
