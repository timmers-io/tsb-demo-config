#!/bin/bash
# Copyright (c) Tetrate, Inc 2022 All Rights Reserved.

set -e

# Check requirements
hash tctl 2>/dev/null || (echo "tctl missing" && exit 1)
hash yq 2>/dev/null || (echo "yq missing" && exit 1)
hash envsubst 2>/dev/null || (echo "envsubst missing" && exit 1)
hash kubectl 2>/dev/null || (echo "kubectl missing" && exit 1)

#export HUB=${HUB:-gcr.io/tetrate-internal-containers}
# gcr.io/timmers-315717/demo-apps
# us-east5-docker.pkg.dev/timmers-315717/demo-apps/obs-tester-server
export HUB=${HUB:-gcr.io/timmers-images}
export OBSTESTER_TAG=${OBSTESTER_TAG:-1.0}
export SDLC_ENV=${SDLC_ENV:-dev}

export ESHOP_HOST=${SDLC_ENV}-${ESHOP_HOST:-eshop.tetrate.io}
export PAYMENTS_HOST=${SDLC_ENV}-${PAYMENTS_HOST:-payments.tetrate.io}

export TENANT_OWNER=${TENANT_OWNER:-nacx}
export ESHOP_OWNER=${ESHOP_OWNER:-zack}
export PAYMENTS_OWNER=${PAYMENTS_OWNER:-wusheng}

tctl config profiles export "$(tctl config profiles get-current)" --file /tmp/tctl-profile >/dev/null
TSB=$(yq '.clusters[0].bridge-address' /tmp/tctl-profile)

cat <<EOF
=== Deploying eSHop application ===
HUB:            ${HUB}
OBSTESTER_TAG:  ${OBSTESTER_TAG}
SDLC_ENV:       ${SDLC_ENV}
TSB ADDRESS:    ${TSB}

ESHOP_HOST:     ${ESHOP_HOST}
PAYMENTS_HOST:  ${PAYMENTS_HOST}
TENANT_OWNER:   ${TENANT_OWNER}
ESHOP_OWNER:    ${ESHOP_OWNER}
PAYMENTS_OWNER: ${PAYMENTS_OWNER}
EOF

echo
read -rp "Continue? (y|n) "
[[ ${REPLY} == "y" ]] || exit 0


# Deploy k8s applications
echo -e "\n=== Deploying k8s apps ===\n"
envsubst < namespaces.yaml  | kubectl apply -f -
for f in apps/*.yaml; do 
    envsubst < "${f}" | kubectl apply -f -
done


# Configure TSB
echo -e "\n=== Configuring TSB ===\n"
#FILES=(teams workspaces ingress permissions)
FILES=(teams workspaces ingress)
for f in "${FILES[@]}"; do
    envsubst < tsb/"${f}".yaml | tctl apply -f -
done

echo -e "\n=== Installing traffic generator ===\n"
envsubst < trafficgen.yaml | kubectl apply -f -
