#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM maven:3.8.6-jdk-8-slim AS stage-atlas
LABEL maintainer="aare.puussaar@gmail.com"
ARG VERSION=3.0.0-SNAPSHOT

ENV	MAVEN_OPTS "-Xms4g -Xmx4g -Dhttp.socketTimeout=60000 -Dhttp.connectionTimeout=60000 -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 -Dmaven.wagon.http.retryHandler.count=3"

RUN apt-get update \
    && apt-get install -y git unzip python python3 build-essential \
	&& git clone http://github.com/aarepuu/atlas.git \
	&& cd atlas \
    && mvn clean -DskipTests package -Pdist \
	&& mv distro/target/apache-atlas-${VERSION}-server.tar.gz /apache-atlas.tar.gz

FROM scratch
FROM ubuntu:22.04

COPY --from=stage-atlas /apache-atlas.tar.gz /apache-atlas.tar.gz


RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install apt-utils \
    && apt-get -y install \
        wget \
        python3 \
		python3-pip \
        openjdk-8-jdk-headless \
        net-tools \
        curl \
    && cd / \
    && export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-arm64" \
    && apt-get clean 

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN groupadd hadoop && \
	useradd -m -d /opt/atlas -g hadoop atlas

RUN cd /opt \
	&& tar xzf /apache-atlas.tar.gz -C /opt/atlas --strip-components=1

RUN rm -rf /apache-atlas.tar.gz

RUN cd /opt/atlas/bin \
    && ./atlas_start.py -setup || true

VOLUME ["/opt/atlas/conf", "/opt/atlas/logs"]