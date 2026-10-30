#!/bin/sh
# Elasticsearch 9.2.x: register ElastiFlow ILM policy, GeoIP pipeline and index template.
set -eu

ES_URL="${ES_URL:-http://elastiflow-elasticsearch:9200}"
CONFIG_DIR="${CONFIG_DIR:-/config}"

put_config() {
    name="$1"
    endpoint="$2"
    file="$3"

    printf '\nInstalling %s ...\n' "$name"

    # --fail-with-body gives nonzero exit on HTTP 4xx/5xx while keeping
    # Elasticsearch's JSON error response for diagnostics.
    if ! response=$(curl --silent --show-error --fail-with-body \
        --retry 5 --retry-delay 2 --retry-connrefused \
        --connect-timeout 10 --max-time 180 \
        -X PUT \
        -H "Content-Type: application/json" \
        --data-binary "@${CONFIG_DIR}/${file}" \
        "${ES_URL}/${endpoint}"); then
        printf 'Failed to install %s:\n%s\n' "$name" "$response" >&2
        exit 1
    fi

    printf '%s\n' "$response"
    if ! printf '%s\n' "$response" | grep -Eq '"acknowledged"[[:space:]]*:[[:space:]]*true'; then
        printf 'Unexpected response while installing %s\n' "$name" >&2
        exit 1
    fi
}

put_config "ILM policy" "_ilm/policy/elastiflow" "ilm-policy.json"
put_config "GeoIP pipeline" "_ingest/pipeline/elastiflow-geoip" "geoip-pipeline.json"
put_config "Index template" "_index_template/elastiflow-4.0.1" "index-template.json"

printf '\nElasticsearch initialization completed.\n'
