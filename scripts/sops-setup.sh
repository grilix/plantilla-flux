#!/bin/sh -e

export GNUPGHOME="$PWD/.keys"

key_fingerprint() {
  # No sé si esto está bien, usar con cuidado (?)
  gpg --list-secret-keys "$1" 2>/dev/null | \
    grep -P -A1 'sec\s+rsa4096' | \
    tail -1 | sed -r 's/^\s+//m'
}

sops_key_secret() {
  kubectl get secrets/sops-gpg -n flux-system
}

register_key() {
  KEY_FP="$1"
cat <<EOF > ./.sops.yaml
---
creation_rules:
  - path_regex: config/.*.ya?ml
    encrypted_regex: ^(data|stringData)$
    pgp: $KEY_FP
EOF
  gpg --export --armor "$KEY_FP" > ./.sops.pub.asc
}

use_key() {
  export KEY_NAME="$1"
  export KEY_COMMENT="flux secrets"

  if [ ! -d .keys ]; then
    mkdir -m 0700 .keys
  fi

  KEY_FP=$(key_fingerprint "$KEY_NAME")

  if [ -z "$KEY_FP" ]; then
    gpg --batch --full-generate-key >/dev/null 2>&1 <<EOF
%no-protection
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Expire-Date: 0
Name-Comment: $KEY_NAME
Name-Real: $KEY_COMMENT
EOF

    KEY_FP=$(key_fingerprint "$KEY_NAME")
  fi

  echo "$KEY_FP"
}

create_sops_secret() {
  KEY_FP=$(use_key "$1")

  register_key "$KEY_FP"

  if ! kubectl get namespaces/flux-system >/dev/null 2>&1; then
    kubectl create namespace flux-system
  fi

  gpg --export-secret-keys --armor "$KEY_FP" | \
    kubectl create secret generic sops-gpg \
      --namespace=flux-system \
      --from-file=sops.asc=/dev/stdin >/dev/null
}


if ! sops_key_secret >/dev/null 2>&1; then
  create_sops_secret "cluster"
fi
