#!/bin/bash

HERE=$(dirname "${BASH_SOURCE}")

# clone Armadillo repository
ARMA_NAME=armadillo-code
ARMA_REPO=https://gitlab.com/conradsnicta

pushd "$HERE/inc"
ARMA_FOLDER=$ARMA_NAME
ARMA_URL=$ARMA_REPO/${ARMA_NAME}.git

if [ ! -d "$ARMA_FOLDER" ]; then
    git clone "$ARMA_URL"
    (( $? == 0 )) || echo "ERROR: could not clone repo '$ARMA_URL' into folder '$ARMA_FOLDER'"
else
    echo "Found Armadillo in: $ARMA_FOLDER"
    echo "    (if the folder is empty / corrupted, delete it first)"
fi
popd

