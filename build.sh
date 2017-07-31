#! /bin/bash

DIR=ds-e2e-test
PREFIX=sanishmahadik
BUILD=${PREFIX}/${DIR}:latest

echo "************* Building ${PASS_BUILD} *****************"
cd $DIR
docker build -t $BUILD .
docker run -t -i --env-file env.list  $BUILD
docker push ${BUILD}
cd -
