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

RUN mkdir /app/tmp
RUN adduser -S -D -H -h ./tmp gorequestbin 
USER gorequestbin

# Metadata params
ARG VERSION
ARG BUILD_DATE
ARG VCS_URL
ARG VCS_REF
ARG NAME
ARG VENDOR

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
EXPOSE 3000