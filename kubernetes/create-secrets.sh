#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

LEMUR_PASSWORD=$(dd if=/dev/urandom bs=30 count=1 status=none | base64 -w 0)

echo "Lemur user password will be '$LEMUR_PASSWORD'"

cat > init-secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  namespace: lemur
  name: init
type: Opaque
data:
  postgres-password: $(dd if=/dev/urandom bs=30 count=1 status=none | base64 -w 0 | base64 -w 0)
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
  database-password: $(dd if=/dev/urandom bs=30 count=1 status=none | base64 -w 0 | base64 -w 0)
EOF
