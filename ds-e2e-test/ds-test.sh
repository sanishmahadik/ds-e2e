#!/bin/bash

echo "Setting signature version to v4"
aws configure set s3.signature_version s3v4
aws configure set region us-west-1

UPLOAD_FILE=upload.txt
DOWNLOAD_FILE=download.txt
MSG="This is a SQS test message"
success_scenario=1

if [[ "${TEST_SCENARIO}" == *fail ]]; then
  echo "Running failure scenario"
  success_scenario=0
fi

if [ -n "$AVANTI_DATASERVICE_FOR_OTHER_NAMESPACE" ]; then
  echo "Getting the passed data-service info for another namespace"
  AVANTI_DATASERVICE_JSON=$AVANTI_DATASERVICE_FOR_OTHER_NAMESPACE
fi

echo "Got AVANTI_DATASERVICE_JSON=${AVANTI_DATASERVICE_JSON}"


S3_URI=$(echo -n ${AVANTI_DATASERVICE_JSON} | jq -r '.[].properties[].value' | grep s3)
S3_BUCKET=$(echo -n ${S3_URI} | cut -d '/' -f 4)
S3_REL_PATH=$(echo -n ${S3_URI} | cut -d '/' -f 5 | awk '{ print $1 }')
S3_PATH=${S3_BUCKET}/${S3_REL_PATH}

SQS_Q1=$(echo -n ${AVANTI_DATASERVICE_JSON} | jq -r '.[].properties[].value' | grep "https://sqs" | head -1)
SQS_Q2=$(echo -n ${AVANTI_DATASERVICE_JSON} | jq -r '.[].properties[].value' | grep "https://sqs" | tail -1)

# only success scenarios get full JSON 
if [ "$success_scenario" -eq "1" ]; then 
  if [ -z "$S3_BUCKET" ]; then 
    echo "Failed to parse S3 BUCKET"
    exit 2
  elif [ -z "$S3_REL_PATH" ]; then 
    echo "Failed to parse S3 REL_PATH"
    exit 2
  elif [ -z "$SQS_Q1" ]; then
    echo "Failed to parse SQS Q1"
    exit 2
  elif [ -z "$SQS_Q1" ]; then
    echo "Failed to parse SQS Q2"
    exit 2
  else
    echo "S3_BUCKET=${S3_BUCKET}"
    echo "S3_REL_PATH=${S3_REL_PATH}"
    echo "S3_PATH=${S3_PATH}"
    echo "SQS_Q1=${SQS_Q1}"
    echo "SQS_Q2=${SQS_Q2}"
  fi
fi

echo "This is a test file" > ${UPLOAD_FILE}

case ${TEST_SCENARIO} in
  upload-file*)
    # upload file
    echo "${TEST_SCENARIO}: file=${UPLOAD_FILE} s3path=${S3_BUCKET}/${S3_REL_PATH}/${UPLOAD_FILE}"
    aws s3 cp ${UPLOAD_FILE} s3://${S3_BUCKET}/${S3_REL_PATH}/${UPLOAD_FILE}
    ;;
  download-file*)
    # download file
    echo "${TEST_SCENARIO}: s3path=${S3_BUCKET}/${S3_REL_PATH}/${UPLOAD_FILE}"
    aws s3 cp s3://${S3_PATH}/${UPLOAD_FILE} ${DOWNLOAD_FILE}
    # content should match
    diff ${UPLOAD_FILE} ${DOWNLOAD_FILE}
    ;;
  send-message*)
    # send message
    echo "${TEST_SCENARIO}: q1=${SQS_Q1} q2=${SQS_Q2}"
    aws sqs send-message --queue-url ${SQS_Q1} --message-body "${MSG}" && \
    aws sqs send-message --queue-url ${SQS_Q2} --message-body "${MSG}"
    ;;
  receive-message*)
    #receive message
    echo "${TEST_SCENARIO}: q1=${SQS_Q1} q2=${SQS_Q2}"
    MSG1=$(aws sqs  receive-message --queue-url ${SQS_Q1} | jq -r '.Messages[].Body')
    MSG2=$(aws sqs  receive-message --queue-url ${SQS_Q2} | jq -r '.Messages[].Body')
    if [ \( "$MSG1" != "$MSG" \)  -o \( "$MSG2" != "$MSG" \) ]; then
      exit 1
    fi
    ;;
esac

# if the last command failed; exit 1
if [ "$?" -ne "0" ]; then
  exit 1
else 
  exit 0
fi
