#!/usr/bin/env bash

gsutil -m rsync -rdecC pages/  gs://data.functionally.dev/cardano/delegation/
