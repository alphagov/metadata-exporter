#!/usr/bin/env bash

set -euo pipefail

env="${1-joint.}"
signin_domain="www.${env}signin.service.gov.uk"

echo "Using $signin_domain"

function cleanup {
  set +e
  docker stop prometheus
}

trap cleanup EXIT

bundle check || bundle install

docker run --rm --name prometheus -d -v $PWD/prometheus.yml:/etc/prometheus/prometheus.yml -p 9090:9090 prom/prometheus

bundle exec bin/prometheus-metadata-exporter -m https://${signin_domain}/SAML2/metadata/federation --cas ../verify-puppet/modules/ida_truststore/files/federation_ca_certs/
