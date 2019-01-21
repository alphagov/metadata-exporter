#!/usr/bin/env bash

bundle check || bundle install

bundle exec bin/prometheus-metadata-exporter
