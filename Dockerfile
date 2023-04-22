FROM ubuntu AS client-prod

ENV MODE=client \
    PROXY_SERVER=https://user:pass@example.com \
    LISTEN_ADDR=socks://0.0.0.0:1080

WORKDIR /app

RUN apt-get update && \
    apt-get install -y ca-certificates wget xz-utils

RUN wget "$(wget https://api.github.com/repos/klzgrad/naiveproxy/releases/latest -O - | grep "linux-x64" | grep "download" | awk '{print($2)}' | sed 's/"//g')" && \
    tar -xf *.tar.xz && \
    rm *.tar.xz && \
    mv naive*/naive naive

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]

FROM golang:1.19 AS build

WORKDIR /go

RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest && \
    /go/bin/xcaddy build --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive

FROM ubuntu AS server-prod

WORKDIR /app

EXPOSE 80
EXPOSE 443

ENV MODE=server

COPY --from=build /go/caddy /app/caddy
COPY Caddyfile /app/Caddyfile

RUN apt-get update && \
    apt-get install -y ca-certificates

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
