#!/bin/bash
# Loads ingestion/.env into the current shell session.
# Usage: source load_env.sh
set -a
source ingestion/.env
set +a
