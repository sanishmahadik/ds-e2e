#!/bin/bash

echo "Running object-store-success scenario"
echo "Setting signature version to v4"
aws configure set s3.signature_version s3v4

# hard-code the bucket-name for now
BUCKET_NAME=sanish-avanti-test
TESTNAME="dummy"

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
  "dummy")
    aws s3 ls
    ;;
  "check-upload-download")
    # upload file
    should_succeed "aws s3 cp ${UPLOAD_FILE} s3://${BUCKET_NAME}/${UPLOAD_FILE}"
    # download file
    should_succeed "aws s3 cp s3://${BUCKET_NAME}/${UPLOAD_FILE} ${DOWNLOAD_FILE}"
    # content should match
    should_succeed "diff ${UPLOAD_FILE} ${DOWNLOAD_FILE}"
    ;;
  "bad-perms-failure")
    # not able to upload even with valid command
    should_fail "aws s3 cp ${UPLOAD_FILE} s3://${BUCKET_NAME}/${UPLOAD_FILE}"
    # not able to download
    should_fail "aws s3 cp s3://${BUCKET_NAME}/${UPLOAD_FILE} ${DOWNLOAD_FILE}"
esac
