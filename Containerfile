FROM scratch AS ctx

COPY files /files
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/bluefin /files
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/shared /files
COPY --from=ghcr.io/projectbluefin/brew:latest /system_files /files
COPY build.sh /build.sh

FROM alpine:latest AS fonts
RUN apk add --no-cache curl unzip
RUN mkdir -p /fonts/jbmono
RUN curl -fsSLo /tmp/jbmono.zip "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip" && \
    unzip /tmp/jbmono.zip -d /fonts/jbmono && \
    rm /tmp/jbmono.zip

FROM quay.io/gnome_infrastructure/gnome-build-meta:gnomeos-nightly

RUN --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=tmpfs,dst=/run \
    --mount=type=bind,from=ctx,source=/,dst=/tmp/ctx \
    --mount=type=bind,from=fonts,source=/fonts/jbmono,dst=/tmp/fonts/jbmono \
    /tmp/ctx/build.sh

LABEL containers.bootc=1
LABEL org.opencontainers.image.source="https://github.com/projectbluefin/distroless"

RUN bootc container lint
