FROM golang:1.15-buster as builder

WORKDIR /go/src/github.com/electrocucaracha/pkg-mgr
COPY . .

ENV GO111MODULE "on"
ENV CGO_ENABLED "0"
ENV GOOS "linux"
ENV GOARCH "amd64"

RUN go build -v -o /bin/demo_server demo/main.go

FROM gcr.io/distroless/base:nonroot
MAINTAINER Victor Morales <electrocucaracha@gmail.com>

ENV PORT "3000"
ENV LOCALE "en"

COPY --from=builder /bin/demo_server /demo_server

ENTRYPOINT ["/demo_server"]
