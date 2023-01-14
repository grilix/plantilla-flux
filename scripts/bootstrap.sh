#!/bin/sh

GITHUB_TOKEN_PATH="./.gh-token"

repo_from_remote() {
  REMOTE="$1"

  URL_LINE=$(git remote show -n "$REMOTE" |  grep -m 1 github)

  if [ "$?" != "0" ]; then
    echo "Error: Github no está en '$1'" >&2
    exit 1
  fi

  echo "$URL_LINE" |  sed -E 's~^.*:(.+).git$~\1~'
}

if [ ! -f $GITHUB_TOKEN_PATH ]; then
  echo "Error: Token de Github no está en: $GITHUB_TOKEN_PATH" >&2
  echo "       Crea uno con el scope \"repo\" desde https://github.com/settings/tokens" >&2
  exit 1
fi

REMOTE=$(repo_from_remote "origin")
USER=$(echo $REMOTE | awk -F/ '{print $1}')
REPO=$(echo $REMOTE | awk -F/ '{print $2}')

export GITHUB_USER="$USER"
export GITHUB_REPO="$REPO"
export GITHUB_TOKEN=$(cat $GITHUB_TOKEN_PATH)

BRANCH=${BRANCH:-main}
CLUSTER_ENV=${CLUSTER_ENV:-production}

echo " ***"
echo -n " *** Se instalará flux en el siguiente contexto: "
kubectl config current-context
echo " ***"
echo -n " *** Presiona [Enter] para confirmar (^C para cancelar): "
read CONF

## Meter flux
flux bootstrap github \
    --owner=${GITHUB_USER} \
    --repository=${GITHUB_REPO} \
    --interval=24h \
    --branch=$BRANCH \
    --personal \
    --path=clusters/$CLUSTER_ENV
