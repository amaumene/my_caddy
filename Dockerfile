FROM golang:alpine AS builder

WORKDIR /app

RUN wget -O - https://api.github.com/repos/caddyserver/caddy/releases/latest | grep 'tarball_url' | cut -d '"' -f 4 | xargs wget -O caddy.tar.gz

RUN mkdir caddy

RUN tar xaf caddy.tar.gz -C caddy --strip-components=1

WORKDIR /app/caddy

RUN rm -rf vendor go.mod go.sum

RUN go mod init github.com/caddyserver/caddy && go mod tidy

RUN cd cmd/caddy && CGO_ENABLED=0 go build -o caddy -ldflags "-w -s"

FROM scratch

COPY --from=builder /app/caddy/cmd/caddy/caddy /app/caddy

EXPOSE 8080/tcp
EXPOSE 8443/tcp

ENTRYPOINT [ "/app/caddy" ]
