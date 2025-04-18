FROM golang:alpine AS builder

WORKDIR /app

RUN wget -O - https://api.github.com/repos/caddyserver/caddy/releases/latest | grep 'tarball_url' | cut -d '"' -f 4 | xargs wget -O caddy.tar.gz

RUN mkdir caddy

RUN tar xaf caddy.tar.gz -C caddy --strip-components=1

WORKDIR /app/caddy

RUN rm -rf vendor go.mod go.sum

RUN go mod init github.com/caddyserver/caddy && go mod tidy

RUN cd cmd/caddy/; CGO_ENABLED=0 go build -o caddy -ldflags "-w -s"

FROM scratch

COPY --chown=65532 --from=builder /app/caddy/cmd/caddy/caddy /app/caddy

VOLUME /config
VOLUME /data

ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

EXPOSE 8080/tcp
EXPOSE 8443/tcp
EXPOSE 8443/udp

CMD [ "/app/caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile" ]
