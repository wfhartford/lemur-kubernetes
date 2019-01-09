#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

password() {
  dd if=/dev/urandom bs=30 count=1 status=none | base64 -w 0
}

passwordB64() {
  password | base64 -w 0
}

encryptionKeys() {
  echo "['$(dd if=/dev/urandom bs=32 count=1 status=none | base64 -w 0 | tr '+/' '-_')']" | base64 -w 0
}

LEMUR_PASSWORD=$(password)

echo "Lemur user password will be '$LEMUR_PASSWORD'"

cat > init-secret.yaml << EOF
# This secret contains passwords only required when lemur starts for the first
# time, once lemur has started and the administrator can log in, this secret
# can be permanently deleted.
apiVersion: v1
kind: Secret
metadata:
  namespace: lemur
  name: init
type: Opaque
data:
  # The postgres root password required when lemur first starts up in order to create the lemur user and schema.
  postgres-password: $(passwordB64)
  # The lemur password used by an administrator to log into lemur.
  lemur-password: $(echo -n ${LEMUR_PASSWORD} | base64 -w 0)
EOF

cat > lemur-secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  namespace: lemur
  name: lemur
type: Opaque
data:
  # The password used by lemur to access postgres, required every time lemur
  # runs.
  database-password: $(passwordB64)
  flask-secret-key: $(passwordB64)
  lemur-token-secret: $(passwordB64)
  lemur-encryption-keys: $(encryptionKeys)
EOF
