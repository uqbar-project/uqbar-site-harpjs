#!/bin/bash

echo "Starting deployment"

TEMP_DIRECTORY="/tmp/__temp_static_content"
CURRENT_COMMIT=`git rev-parse HEAD`
ORIGIN_URL="github.com/uqbar-project/uqbar-project.github.io.git"
ORIGIN_URL_WITH_CREDENTIALS="https://${GITHUB_TOKEN}@${ORIGIN_URL}"

echo "Compiling site"

mkdir ${TEMP_DIRECTORY}
harp compile ./site ${TEMP_DIRECTORY}
cp .gitignore ${TEMP_DIRECTORY}
ls ${TEMP_DIRECTORY}

echo "Removing old static content"
git rm -rf . || exit 1

echo "Copying newly generated static content"
cp -r ${TEMP_DIRECTORY}/* . || exit 1
cp ${TEMP_DIRECTORY}/.gitignore . || exit 1

echo "Pushing new content to $ORIGIN_URL"
git config user.name "Travis-CI" || exit 1
git config user.email "travis@uqbar-project.com" || exit 1

git add -A . || exit 1
git commit --allow-empty -m "Generated static site for $CURRENT_COMMIT" || exit 1
git remote set-url origin "$ORIGIN_URL_WITH_CREDENTIALS"
#git push --force --quiet "$ORIGIN_URL_WITH_CREDENTIALS" gh-pages > /dev/null 2>&1
git push -u --force origin master

echo "Cleaning up temp files"
rm -Rf ${TEMP_DIRECTORY}

echo "Deployed successfully."
exit 0