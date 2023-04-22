FROM ubuntu AS client-prod

ENV PROXY_SERVER=https://user:pass@example.com \
    LISTEN_ADDR=socks://0.0.0.0:1080

WORKDIR /app

RUN apt-get update && \
    apt-get install -y ca-certificates wget xz

RUN wget -O naive.tar.xz "$(wget https://api.github.com/repos/klzgrad/naiveproxy/releases/latest -O - | grep "linux-x64" | grep "download" | awk '{print($2)}' | sed 's/"//g')" && \
    tar -xzvf naive.tar.xz && \
    rm naive.tar.xz && \
    mv naive*/naive naive

CMD ["./naive", "--proxy-server", "$PROXY_SERVER", "--listen", "$LISTEN_ADDR"]

FROM golang:1.19 AS build

WORKDIR /go

RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest && \
    /go/bin/xcaddy build --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive

FROM ubuntu AS server-prod

WORKDIR /app

EXPOSE 80
EXPOSE 443

COPY --from=build /go/caddy /app/caddy
COPY Caddyfile /app/Caddyfile

RUN apt-get update && \
    apt-get install -y ca-certificates

CMD ["./caddy", "run", "--config", "/app/Caddyfile"]
