ARG ELIXIR_VERSION=1.18.3
ARG OTP_VERSION=27.2.4
ARG DEBIAN_VERSION=bookworm-20250428-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

## Builder
FROM ${BUILDER_IMAGE} AS builder

RUN apt-get update -y && apt-get install -y \
    build-essential git \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV="prod"
ENV ERL_FLAGS="+JPperf true"

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

COPY config/* config/
COPY priv priv
COPY lib lib
RUN mix compile
RUN mix release

## Runner
FROM ${RUNNER_IMAGE}

RUN apt-get update && apt-get install -y \
  wkhtmltopdf \
  libstdc++6 \
  libx11-6 \
  libxrender1 \
  libfontconfig1 \
  libfreetype6 \
  ca-certificates \
  locales \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

ENV MIX_ENV="prod"

COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/snatch_ex ./

USER nobody

CMD ["./bin/snatch_ex", "start"]
