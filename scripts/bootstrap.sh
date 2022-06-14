#!/bin/sh

repo_from_remote() {
  REMOTE="$1"

  URL_LINE=$(git remote show -n "$REMOTE" |  grep -m 1 github)

  if [ "$?" != "0" ]; then
    echo "Error: Github no está en '$1'" >&2
    exit 1
  fi

  echo "$URL_LINE" |  sed -E 's~^.*:(.+).git$~\1~'
}

REMOTE=$(repo_from_remote "origin")
USER=$(echo $REMOTE | awk -F/ '{print $1}')
REPO=$(echo $REMOTE | awk -F/ '{print $2}')

export GITHUB_USER="$USER"
export GITHUB_REPO="$REPO"
export GITHUB_TOKEN=$(cat ./gh-token)

## Meter flux
flux bootstrap github \
    --owner=${GITHUB_USER} \
    --repository=${GITHUB_REPO} \
    --interval=24h \
    --branch=main \
    --personal \
    --path=clusters/production
