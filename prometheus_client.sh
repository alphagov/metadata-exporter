#!/usr/bin/env bash

bundle check || bundle install

bundle exec bin/prometheus-metadata-exporter -h https://www.joint.signin.service.gov.uk/SAML2/metadata/federation
