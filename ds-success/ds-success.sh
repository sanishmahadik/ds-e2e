#!/bin/bash

echo "Running ds-success scenario"
echo "Setting signature version to v4"
aws configure set s3.signature_version s3v4

UPLOAD_FILE=upload.txt
DOWNLOAD_FILE=download.txt
MSG="This is a SQS test message"

echo "Got AVANTI_DATASERVICE_JSON=${AVANTI_DATASERVICE_JSON}"

S3_URI=$(echo -n ${AVANTI_DATASERVICE_JSON} | jq -r '.[].properties[].value' | grep s3 | cut -d '/' -f 4,5)
SQS_Q1=$(echo -n ${AVANTI_DATASERVICE_JSON} | jq -r '.[].properties[].value' | grep "https://sqs" | head -1)
SQS_Q2=$(echo -n ${AVANTI_DATASERVICE_JSON} | jq -r '.[].properties[].value' | grep "https://sqs" | tail -1)

echo "This is a test file" > ${UPLOAD_FILE}

case ${TEST_SCENARIO} in
  "upload-file")
    # upload file
    aws s3 cp ${UPLOAD_FILE} s3://${S3_URI}/${UPLOAD_FILE}
    ;;
  "download-file")
    # download file
    aws s3 cp s3://${S3_URI}/${UPLOAD_FILE} ${DOWNLOAD_FILE} && \
    # content should match
    diff ${UPLOAD_FILE} ${DOWNLOAD_FILE}
    ;;
  "send-message")
    # send message
    aws sqs send-message --queue-url ${SQS_Q1} --message-body ${MSG} && \
    aws sqs send-message --queue-url ${SQS_Q2} --message-body ${MSG}
    ;;
  "receive-message")
    #receive message
    MSG1=$(sudo aws sqs  receive-message --queue-url ${SQS_Q1} | jq -r '.Messages[].Body')
    MSG2=$(sudo aws sqs  receive-message --queue-url ${SQS_Q2} | jq -r '.Messages[].Body')
    if [ \( "$MSG1" != "$MSG" \)  -o \( "$MSG2" != "$MSG" \) ]; then
      exit 2
    fi
    ;;
esac
