#!/bin/bash

echo "Running object-store-success scenario"

# hard-code the bucket-name for now
BUCKET_NAME=sanish-avanti-test

UPLOAD_FILE=upload.txt
DOWNLOAD_FILE=download.txt

function should_fail() {
echo "testing for failure: $1"
bash -c "$1"

if [ "$?" -eq "0" ]; then
  echo "Expected failure for $1; instead succeeded"
  exit 1
fi
return 0
}

function should_succeed() {
echo "testing for success: $1"
bash -c "$1"

if [ "$?" -ne "0" ]; then
  echo "Expected success for $1; instead failed"
  exit 2
fi
return 0
}

echo "This is a test file" > ${UPLOAD_FILE}

case ${TESTNAME} in
  "unencrypted-failure") 
    # no sse specified for upload
    should_fail "aws s3 cp ${UPLOAD_FILE} s3://${BUCKET_NAME}/${UPLOAD_FILE}"
    # bad sse algorithm specified for upload
    should_fail "aws s3 cp ${UPLOAD_FILE} s3://${BUCKET_NAME}/${UPLOAD_FILE} --sse AES128"
    ;;
  "encrypted-success") 
    # sse specified for upload
    should_succeed "aws s3 cp ${UPLOAD_FILE} s3://${BUCKET_NAME}/${UPLOAD_FILE} --sse"
    # good sse algorithm specified
    should_succeed "aws s3 cp ${UPLOAD_FILE} s3://${BUCKET_NAME}/${UPLOAD_FILE} --sse AES256"
    # download file
    should_succeed "aws s3 cp s3://${BUCKET_NAME}/${UPLOAD_FILE} ${DOWNLOAD_FILE}"
    # content should match
    should_succeed "diff ${UPLOAD_FILE} ${DOWNLOAD_FILE}"
    ;;
  "bad-perms-failure")
    # not able to upload even with valid command
    should_fail "aws s3 cp ${UPLOAD_FILE} s3://${BUCKET_NAME}/${UPLOAD_FILE} --sse"
    # not able to download
    should_fail "aws s3 cp s3://${BUCKET_NAME}/${UPLOAD_FILE} ${DOWNLOAD_FILE}"
esac
