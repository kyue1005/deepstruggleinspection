#! /bin/bash
# START_DT="31/Jan/2021:00:00:00"
# END_DT="03/Feb/2021:23:59:59"

usage() {
    echo "Usage:"
    echo "top10_host.sh [-f FILE.gz] [-s START_DT] [-d END_DT]"
    echo "Description:"
    echo "FILE,the path of gziped log file."
    echo "START_DT,start datetime [dd/mm/yyyy:hh:mm:ss]."
    echo "END_DT,end datetime [dd/mm/yyyy:hh:mm:ss]."
    exit -1
}

while getopts hf:s:e: opt; do
  case "${opt}" in
    f) FILE="${OPTARG}";;
    s) START_DT="${OPTARG}";;
    e) END_DT="${OPTARG}";;
    h) usage;;
    ?) usage;;
  esac
done

if [ -z ${FILE} ] || [ -z ${START_DT} ] || [ -z ${END_DT} ]; then
  usage
fi

if [ -f ${FILE} ]; then
  START_DT_M=$(echo ${START_DT} | cut -d':' -f1 | sed -e 's/\//\\\//g')
  END_DT_M=$(echo ${END_DT} | cut -d':' -f1 | sed -e 's/\//\\\//g')

  START_REC=$(gzip -dc test/access.log.gz | sed -n "/${START_DT_M}/p" | awk -v var="[${START_DT}" '$4 >= var {print $4}' | head -n 1)
  END_REC=$(gzip -dc test/access.log.gz | sed -n "/${END_DT_M}/p" | awk -v var="[${END_DT}" '$4 <= var {print $4}' | tail -n 1)

  if [ -z ${START_REC} ] || [ -z ${END_REC} ]; then
    echo "Logs not found within date range"
  else
    START_REC_M=$(echo ${START_REC} | sed -e 's/\//\\\//g')
    END_REC_M=$(echo ${END_REC} | sed -e 's/\//\\\//g')
    
    gzip -dc "${FILE}" | sed -n "/\\${START_REC_M}/,/\\${END_REC_M}/p" | awk '{print $1}'  | sort | uniq -c | sort -t ' ' -k 1rn | head -n 10
  fi
else
  echo "${FILE} not exist"
fi
