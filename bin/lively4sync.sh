#!/bin/bash

REPOSITORY="$1"
USERNAME="$2"
PASSWORD="$3"
EMAIL="$4"
BRANCH="$5"
MSG="$6"

pushd $REPOSITORY > /dev/null

ORIGIN=`git config --get remote.origin.url | sed "s/https:\/\//https:\/\/$USERNAME:$PASSWORD@/"`

echo "REPO: " "$REPOSITORY" "USERNAME: " "$USERNAME" 

git status --porcelain | grep  "??" | sed 's/^?? /git add /' | bash
git config user.name "$USERNAME"
git config user.email "$EMAIL"
STATUS=`git status --porcelain | grep -v "??" | tr "\n" ";"`
if [ -z "$MSG" ]; then
  COMMIT="SYNC "$STATUS
else  
  COMMIT="$MSG"
fi
echo COMMIT $COMMIT

if [ -e "${REPOSITORY}/.git/MERGE_HEAD" ]; then
  echo "merge in progress - you had conflicts or a manual merge is in progress"
  exit
fi

git commit -m "$COMMIT" -a ; 
echo "PULL"
git pull --no-edit origin "$BRANCH" ; 

# ALT: #Issue6
# git pull --rebase --no-edit origin "$BRANCH" ; 


echo "PUSH2"
echo git push "$ORIGIN" "$BRANCH"
git push "$ORIGIN" "$BRANCH"

echo "FETCH AGAIN"
#git fetch origin "$BRANCH"
git fetch
popd > /dev/null