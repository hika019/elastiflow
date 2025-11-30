#------------------------------------------------------------------------------
# Portions of this file are Copyright (C)2020 Robert Cowart
# 
# Portions of this file are subject to the Robert Cowart Public License (the
# "License") and may not be used or distributed except in compliance with the
# License. You may obtain a copy of the License at:
# 
# http://www.koiossian.com/public/robert_cowart_public_license.txt
# 
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
# the specific language governing rights and limitations under the License.
# 
# The Original Source Code was developed by Robert Cowart. Portions created by
# Robert Cowart are Copyright (C)2020 Robert Cowart. All Rights Reserved.
#------------------------------------------------------------------------------

FROM alpine:latest AS stage0

RUN wget https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-City.mmdb -O /usr/share/GeoLite2-City.mmdb && \
    wget https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-ASN.mmdb -O /usr/share/GeoLite2-ASN.mmdb

FROM elastic/logstash:9.2.1

ARG BUILD_DATE
ARG VERSION="9.2.1"

LABEL org.opencontainers.image.created="$BUILD_DATE" \
      org.opencontainers.image.authors="elastiflow@gmail.com" \
      org.opencontainers.image.url="https://github.com/robcowart/elastiflow/README.md" \
      org.opencontainers.image.documentation="https://github.com/robcowart/elastiflow/DOCKER.md" \
      org.opencontainers.image.source="https://github.com/robcowart/elastiflow" \
      org.opencontainers.image.version="$VERSION" \
      org.opencontainers.image.vendor="Robert Cowart" \
      org.opencontainers.image.title="ElastiFlow™ - Logstash" \
      org.opencontainers.image.description="ElastiFlow 4.x upgraded to Elastic Stack 9.2.1 - Personal/Non-commercial use only"

ENV ELASTIFLOW_ES_HOST="http://127.0.0.1:9200"

RUN $HOME/bin/logstash-plugin install logstash-codec-sflow \
    && $HOME/bin/logstash-plugin update

WORKDIR /usr/share/logstash/config
COPY --chown=logstash:logstash ./docker_assets/logstash.yml ./
COPY --chown=logstash:logstash ./docker_assets/pipelines.yml ./

COPY --from=stage0 /usr/share/GeoLite2-City.mmdb /etc/logstash/elastiflow/geoipdbs/GeoLite2-City.mmdb
COPY --from=stage0 /usr/share/GeoLite2-ASN.mmdb /etc/logstash/elastiflow/geoipdbs/GeoLite2-ASN.mmdb

WORKDIR /etc/logstash/elastiflow
COPY --chown=logstash:root ./logstash/elastiflow/ ./

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
