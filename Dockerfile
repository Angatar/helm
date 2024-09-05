ARG APPNAME="helm"
ARG APP_TMP_ROOT="/tmp/install"
FROM --platform=$BUILDPLATFORM alpine:latest AS helper
LABEL org.opencontainers.image.authors="d3fk"
ARG TARGETPLATFORM
ARG APPNAME
ARG APP_TMP_ROOT
ARG USERNAME=$APPNAME
ARG OS="linux"

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
    && APP_DIST="helm-$TAG-$OS-$ARCH.tar.gz" \
    && DOWNLOAD_URL="https://get.helm.sh/$APP_DIST" \
    && CHECKSUM_URL="$DOWNLOAD_URL.sha256" \
    && APP_TMP_FILE="$APP_TMP_ROOT/$APP_DIST" \
    && APP_SUM_FILE="$APP_TMP_ROOT/$APP_DIST.sha256" \
    && APP_TMP="$APP_TMP_ROOT/$APPNAME" \
    # Add openssl required for checksum
    && apk add --no-cache openssl \
    # Create install dir & download Helm + checksum
    && mkdir "$APP_TMP_ROOT" \
    && wget -q -O "$APP_SUM_FILE" "$CHECKSUM_URL" \
    && wget -q -O "$APP_TMP_FILE" "$DOWNLOAD_URL" \
    # Verify the checksum
    && sum=$(openssl sha256 ${APP_TMP_FILE} | awk '{print $2}') \
    && expected_sum=$(cat ${APP_SUM_FILE}) \
    && [ "$sum" != "$expected_sum" ] \
    && echo "SHA sum of ${APP_TMP_FILE} does not match. Aborting." \
    && exit 1 || echo "Verifying checksum... Done." \
    # Extract Helm
    && mkdir -p "$APP_TMP" \
    && tar xf "$APP_TMP_FILE" -C "$APP_TMP" \
    && mv  "$APP_TMP/$OS-$ARCH/$APPNAME" "$APP_TMP/."\
    # Creating user and group file to be exported in scratch for default user
    && mkdir "$APP_TMP_ROOT/etc" \
    && echo "$USERNAME:x:6009:6009:$USERNAME:/:/sbin/nologin" > $APP_TMP_ROOT/etc/passwd \
    && echo "$USERNAME:x:6009:"> $APP_TMP_ROOT/etc/group


FROM scratch
ARG APPNAME
ARG APP_TMP_ROOT
LABEL org.opencontainers.image.authors="d3fk"
LABEL org.opencontainers.image.source="https://github.com/Angatar/$APPNAME.git"
LABEL org.opencontainers.image.url="https://github.com/Angatar/$APPNAME"
LABEL org.opencontainers.image.base.name="docker.io/library/scratch"
LABEL org.opencontainers.image.title="$APPNAME"
LABEL org.opencontainers.image.description="Minimal container image only embedding \
Helm 3 official binary from Scratch, updated monthly, really useful to manage helm \
charts in your kubernetes clusters from any docker related environment"

COPY --from=helper $APP_TMP_ROOT/$APPNAME/$APPNAME /$APPNAME
COPY --from=helper $APP_TMP_ROOT/etc /etc
COPY --from=helper /etc/ssl/certs /etc/ssl/certs

USER $APPNAME
ENTRYPOINT ["/helm"]
CMD ["--help"]
WORKDIR /files
