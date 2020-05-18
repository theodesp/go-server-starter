# Build
FROM golang:1.14-stretch as builder
LABEL maintainer = "Theo Despoudis 328805+theodesp@users.noreply.github.com"
RUN mkdir /build
WORKDIR /build
COPY . ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o app .

RUN adduser -S -D -H -h /build gorequestbin 
USER gorequestbin

# Execute
FROM alpine:3.9
RUN apk --no-cache add ca-certificates
WORKDIR /app/
COPY --from=builder /build ./

ARG UID="3322"
ARG GID="3322"

RUN mkdir /app/tmp
RUN addgroup --system --gid $GID gorequestbin && \
    adduser --system --uid $UID --no-create-home --ingroup gorequestbin gorequestbin && \
    chmod +x ./app
USER gorequestbin

# Metadata params
ARG VERSION
ARG BUILD_DATE
ARG VCS_URL
ARG VCS_REF
ARG NAME
ARG VENDOR

ENV GOREQUESTBIN-ADDRESS="127.0.0.1" \
    GOREQUESTBIN-PORT="3322"

# Metadata
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name=$NAME \
    org.label-schema.description="" \
    org.label-schema.url="https://example.com" \
    org.label-schema.vcs-url=https://github.com/theodesp/$VCS_URL \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vendor=$VENDOR \
    org.label-schema.version=$VERSION \
    org.label-schema.docker.schema-version="1.0" \
    org.label-schema.docker.cmd="docker run -d theodesp/go-requestbin"


ENTRYPOINT ["./app"]
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD curl --fail http://localhost:3000/ || exit 1
EXPOSE 3000