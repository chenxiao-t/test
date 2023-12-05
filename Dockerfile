FROM golang:1.20-alpine3.17 as builder
WORKDIR $GOPATH/src/go.k6.io/k6
ADD . .
RUN apk --no-cache add git
RUN go install go.k6.io/xk6/cmd/xk6@latest
RUN xk6 build --with github.com/grafana/xk6-output-influxdb --output /tmp/k6

FROM alpine:3.17
RUN apk add --no-cache ca-certificates && \
    adduser -D -u 12345 -g 12345 k6
COPY --from=builder /tmp/k6 /usr/bin/k6

WORKDIR /app
COPY . /app

ENV K6_OUT="xk6-influxdb=http://influxdb:8086"
ENV K6_INFLUXDB_ORGANIZATION=k6io
ENV K6_INFLUXDB_BUCKET=demo
ENV K6_INFLUXDB_INSECURE=true
ENV K6_INFLUXDB_TOKEN=EEKpryGZk8pVDXmIuy484BKUxM5jOEDv7YNoeNZUbsNbpbPbP6kK_qY9Zsyw7zNnlZ7pHG16FYzNaqwLMBUz8g==

EXPOSE 6565

USER 12345
WORKDIR /home/k6
ENTRYPOINT ["k6", "run", "/app/http_2.js"]
