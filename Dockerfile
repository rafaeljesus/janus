FROM golang:1.10-alpine AS builder

WORKDIR /go/src/github.com/hellofresh/janus

COPY . .

RUN apk add --update bash make git
RUN export JANUS_BUILD_ONLY_DEFAULT=1 && make

# ---

FROM alpine

ADD assets/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /go/src/github.com/hellofresh/janus/dist/janus /

RUN mkdir -p /etc/janus/apis && \
    mkdir -p /etc/janus/auth

RUN apk add --update curl && \
    rm -rf /var/cache/apk/*

HEALTHCHECK --interval=5s --timeout=5s --retries=3 CMD curl -f http://localhost:8081/status || exit 1

EXPOSE 8080 8081 8443 8444
ENTRYPOINT ["/janus_linux-amd64"]
