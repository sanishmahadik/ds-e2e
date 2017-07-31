#! /bin/bash

TESTDIR=ds-e2e-test
PREFIX=sanishmahadik
BUILD=${PREFIX}/${TESTDIR}:latest

echo "************* Building ${BUILD} *****************"
cd $TESTDIR
docker build -t $BUILD .
docker run -t -i --env-file env.list  $BUILD
docker push ${BUILD}
cd -
