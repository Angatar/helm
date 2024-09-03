FROM --platform=$BUILDPLATFORM alpine:latest as helper
LABEL org.opencontainers.image.authors="d3fk"
ARG TARGETPLATFORM
ENV OS="linux"
ENV HELM_TMP_ROOT="/tmp/install"

# Architecture mapping
RUN case $TARGETPLATFORM in \
        "linux/arm/v5") ARCH="arm";; \
        "linux/arm/v6") ARCH="arm";; \
        "linux/arm/v7") ARCH="arm";; \
        "linux/arm64") ARCH="arm64";; \
        "linux/386") ARCH="386";; \
        "linux/amd64") ARCH="amd64";; \
        "linux/i686") ARCH="386";; \
        "linux/i386") ARCH="386";; \
        "linux/s390x") ARCH="s390x";; \
        "linux/ppc64le") ARCH="ppc64le";; \
        *) echo "Unsupported architecture: $TARGETPLATFORM" && exit 1;; \
    esac \
    # Set variables
    && TAG=$( wget https://get.helm.sh/helm-latest-version -q -O - 2>&1 || true ) \
    && HELM_DIST="helm-$TAG-$OS-$ARCH.tar.gz" \
    && DOWNLOAD_URL="https://get.helm.sh/$HELM_DIST" \
    && CHECKSUM_URL="$DOWNLOAD_URL.sha256" \
    && HELM_TMP_FILE="$HELM_TMP_ROOT/$HELM_DIST" \
    && HELM_SUM_FILE="$HELM_TMP_ROOT/$HELM_DIST.sha256" \
    && HELM_TMP="$HELM_TMP_ROOT/helm" \
    # Add openssl required for checksum
    && apk add --no-cache openssl \
    # Create install dir & download Helm + checksum
    && mkdir "$HELM_TMP_ROOT" \
    && wget -q -O "$HELM_SUM_FILE" "$CHECKSUM_URL" \
    && wget -q -O "$HELM_TMP_FILE" "$DOWNLOAD_URL" \
    # Verify the checksum
    && sum=$(openssl sha256 ${HELM_TMP_FILE} | awk '{print $2}') \
    && expected_sum=$(cat ${HELM_SUM_FILE}) \
    && [ "$sum" != "$expected_sum" ] \
    && echo "SHA sum of ${HELM_TMP_FILE} does not match. Aborting." \
    && exit 1 || echo "Verifying checksum... Done." \
    # Extract Helm
    && mkdir -p "$HELM_TMP" \
    && tar xf "$HELM_TMP_FILE" -C "$HELM_TMP" \
    && mv  "$HELM_TMP/$OS-$ARCH/helm" "$HELM_TMP/."


FROM scratch
LABEL org.opencontainers.image.authors="d3fk"
COPY --from=helper /tmp/install/helm/helm /helm

ENTRYPOINT ["/helm"]
CMD ["--help"]
WORKDIR /files

