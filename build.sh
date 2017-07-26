#! /bin/bash
set -e

PASS_DIR=ds-success
FAIL_DIR=ds-failure
PREFIX=sanishmahadik
PASS_BUILD=${PREFIX}/${PASS_DIR}:latest
FAIL_BUILD=${PREFIX}/${FAIL_DIR}:latest

echo "************* Building ${PASS_BUILD} *****************"
cd $PASS_DIR 
docker build -t $PASS_BUILD .
docker run -t -i --env-file env.list  $PASS_BUILD 
docker push ${PASS_BUILD}
cd -

echo "************* Building ${FAIL_BUILD} *****************"
cd $FAIL_DIR
docker build -t $FAIL_BUILD . 
docker run -t -i --env-file env.list  $FAIL_BUILD 
docker push ${FAIL_BUILD}
cd -
