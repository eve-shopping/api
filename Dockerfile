FROM crystallang/crystal:0.35.1-alpine as build

COPY shard.lock /app/shard.lock
COPY shard.yml /app/shard.yml

WORKDIR /app

RUN shards install --production

COPY src/ /app/src/

RUN shards build --release --production --no-debug --static
RUN strip ./bin/api
RUN strip ./bin/micrate

COPY db/ /app/db/

FROM scratch
COPY --from=build /app/bin /
COPY --from=build /app/db /db

EXPOSE 3000

ENTRYPOINT ["/api"]
