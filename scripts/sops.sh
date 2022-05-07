#!/bin/sh

export GNUPGHOME="$(pwd)/.keys"

if [ "$#" = "0" ]; then
  echo "Error: No se han indicado argumentos." >&2
  echo "" >&2
  echo "Para encriptar:" >&2
  echo "    $0 -d --in-place config/production/cluster-secrets.sops.yaml" >&2
  echo "Para desencriptar:" >&2
  echo "    $0 -e --in-place config/production/cluster-secrets.sops.yaml" >&2

  exit 1
fi

sops $@
