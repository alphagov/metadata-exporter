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

CAS=../verify-puppet/modules/ida_truststore/files/federation_ca_certs/idap-core-test-ca.crt,../verify-puppet/modules/ida_truststore/files/federation_ca_certs/idap-relying-party-test-ca.crt,../verify-puppet/modules/ida_truststore/files/federation_ca_certs/idap-test-ca.crt,../verify-puppet/modules/ida_truststore/files/federation_ca_certs/idap-metadata-test-ca.crt,../verify-puppet/modules/ida_truststore/files/federation_ca_certs/idap-test-root-ca.crt
if [ "$env" == "" ]; then
    CAS=../verify-puppet/modules/ida_truststore/files/federation_ca_certs/idap-core-ca-g2.crt,../verify-puppet/modules/ida_truststore/files/federation_ca_certs/idap-relying-party-ca-g2.crt,../verify-puppet/modules/ida_truststore/files/federation_ca_certs/idap-ca-g2.crt,../verify-puppet/modules/ida_truststore/files/federation_ca_certs/idap-metadata-ca-g2.crt,../verify-puppet/modules/ida_truststore/files/federation_ca_certs/idap-root-ca.crt
fi

bundle exec bin/prometheus-metadata-exporter -h https://${signin_domain}/SAML2/metadata/federation --cas $CAS
