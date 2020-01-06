#!/usr/bin/env bash

# exit on errors
set -e

# Script will check out the Demisto content repo and then generate documentation based upon the checkout

SCRIPT_DIR=$(dirname ${BASH_SOURCE})
CURRENT_DIR=`pwd`
if [[ "${SCRIPT_DIR}" != /* ]]; then
    SCRIPT_DIR="${CURRENT_DIR}/${SCRIPT_DIR}"
fi
CONTENT_GIT_DIR=${SCRIPT_DIR}/.content
DOCS_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Do a shallow clone to speed things up

if [ ! -d ${CONTENT_GIT_DIR} ]; then
    echo "Cloning content to dir: ${CONTENT_GIT_DIR} ..."
    git clone --depth 100 --no-single-branch https://github.com/demisto/content.git ${CONTENT_GIT_DIR}
else
    echo "Content dir: ${CONTENT_GIT_DIR} exists"    
fi
cd ${CONTENT_GIT_DIR}
if [ ${DOCS_BRANCH} != "master" ] && (git branch -a | grep "remotes/origin/${DOCS_BRANCH}$"); then
    echo "found remote branch: '$DOCS_BRANCH' will use it for generating docs"
    git checkout $DOCS_BRANCH
else
    echo "Using master to generate build"
    git checkout master
fi
git pull

cd ${SCRIPT_DIR}

TARGET_DIR=${SCRIPT_DIR}/../docs/reference
echo "Deleting and creating dir: ${TARGET_DIR}"
rm -rf ${TARGET_DIR}
mkdir ${TARGET_DIR}

echo "Generating docs..."
pipenv run ./gendocs.py -t "${TARGET_DIR}" -d "${CONTENT_GIT_DIR}"