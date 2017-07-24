#!/bin/bash

echo "Running object-store-success scenario"
echo "Setting signature version to v4"
aws configure set s3.signature_version s3v4

# hard-code the bucket-name for now
BUCKET_NAME=sanish-avanti-test

UPLOAD_FILE=upload.txt
DOWNLOAD_FILE=download.txt
SSEC_KEY=abcdef1234567890abcdef1234567890

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
    # sse-s3 specified explicitly
    should_succeed "aws s3 cp ${UPLOAD_FILE} s3://${BUCKET_NAME}/${UPLOAD_FILE} --sse AES256"
    # sse-kms algorithm specified
    should_succeed "aws s3 cp ${UPLOAD_FILE} s3://${BUCKET_NAME}/${UPLOAD_FILE} --sse aws:kms"
    # download file
    should_succeed "aws s3 cp s3://${BUCKET_NAME}/${UPLOAD_FILE} ${DOWNLOAD_FILE}"
    # content should match
    should_succeed "diff ${UPLOAD_FILE} ${DOWNLOAD_FILE}"
    # sse-c algorithm specified
    should_succeed "aws s3 cp ${UPLOAD_FILE} s3://${BUCKET_NAME}/${UPLOAD_FILE} --sse-c AES256 --sse-c-key ${SSEC_KEY}"
    # download file
    should_succeed "aws s3 cp s3://${BUCKET_NAME}/${UPLOAD_FILE} ${DOWNLOAD_FILE} --sse-c AES256 --sse-c-key ${SSEC_KEY}"
    # content should match
    should_succeed "diff ${UPLOAD_FILE} ${DOWNLOAD_FILE}"
    ;;
  "bad-perms-failure")
    # not able to upload even with valid command
    should_fail "aws s3 cp ${UPLOAD_FILE} s3://${BUCKET_NAME}/${UPLOAD_FILE} --sse"
    # not able to download
    should_fail "aws s3 cp s3://${BUCKET_NAME}/${UPLOAD_FILE} ${DOWNLOAD_FILE}"
esac
