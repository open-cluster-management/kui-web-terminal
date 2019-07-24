#
# Copyright 2019 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ARG ARCH
# FROM node:8-alpine
FROM hyc-cloud-private-edge-docker-local.artifactory.swg-devops.com/build-images/node-${ARCH}:dubnium-ubi7.6-123-minimal

ARG VCS_REF
ARG VCS_URL
ARG IMAGE_NAME
ARG IMAGE_DESCRIPTION
ARG ARCH

ADD downloads/kubectl-linux-${ARCH} /usr/local/bin/kubectl
ADD downloads/helm-linux-${ARCH}.tar.gz /usr/local/helm/
ADD downloads/cloudctl-linux-${ARCH} /usr/local/bin/cloudctl
ADD downloads/istioctl-linux-${ARCH} /usr/local/bin/istioctl
# add bin for helm
ADD root /

LABEL org.label-schema.vendor="IBM" \
      org.label-schema.name="$IMAGE_NAME" \
      org.label-schema.description="$IMAGE_DESCRIPTION" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.license="Licensed Materials - Property of IBM" \
      org.label-schema.schema-version="1.0"


ENV PORT 3000
EXPOSE 3000/tcp

# default passphrase for the self-signed certificates; this Dockerfile
# is intended only for testing, do not use this for productioncd 
ENV PASSPHRASE kuishell
ENV NOBODY_GID 99
# For use when using ubi-minimal image
ENV LINUX_DISTRO rhel

WORKDIR /kui-proxy/kui



# we will download a gamut of helm clients and place them here
# see plugins/plugin-k8s/src/lib/util/discovery/helm-client.ts
# ENV KUI_HELM_CLIENTS_DIR=/usr/local/bin
# ENV HELM_LATEST_VERSION="${KUI_HELM_CLIENTS_DIR}"/helm

# Following was for alpine image
# RUN apk add --no-cache ca-certificates bash git
#
# For UBI need to use microdnf (UBI already includes bash but needs shadow-utils for adduser)
RUN microdnf install \
    ca-certificates \
    git \
    python \
    shadow-utils \
    vi \
    which \
    && microdnf clean all

###########

RUN ln -s /usr/local/helm/linux-${ARCH}/helm /usr/local/bin/helm_original  && chmod 755 /usr/local/bin/*

COPY ./tmp/kui /kui-proxy/kui
# copy the client webpack bundles and other artifacts into the proxy app/public folder
COPY ./client/dist/webpack /kui-proxy/kui/app/public

# RUN cd /kui-proxy/kui && apk add python make g++ && npm rebuild node-pty --update-binary && apk del python make g++
RUN cd /kui-proxy/kui
RUN microdnf install make gcc gcc-c++ \
    && microdnf clean all
RUN npm rebuild node-pty --update-binary
RUN microdnf remove make gcc gcc-c++ \
    && microdnf clean all

CMD [ "npm", "start" ]
