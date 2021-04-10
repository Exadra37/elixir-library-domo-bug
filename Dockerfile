ARG ELIXIR_VERSION
ARG OTP_VERSION
ARG ALPINE_VERSION

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-alpine-${ALPINE_VERSION} as build

ARG BUILD_RELEASE_FROM=master

ENV MIX_ENV=prod

WORKDIR /app

RUN \
  apk upgrade --no-cache && \
  apk add \
    --no-cache \
    openssh-client \
    build-base \
    npm \
    git \
    python3 && \

  mix local.hex --force && \
  mix local.rebar --force

COPY .env /release/.env
COPY ./.git /workspace

RUN \
  git clone --local /workspace . && \
  git checkout "${BUILD_RELEASE_FROM}" && \
  ls -al && \

  export $(grep -v '^#' /release/.env | xargs -0) && \
  export PORT=8000 && \

  mix deps.get --only prod && \
  mix compile && \
  mix release && \
  ls -al _build/prod && \
  ls -al _build/prod/rel

# Start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM alpine:${ALPINE_VERSION} AS app

ENV USER="phoenix"
ENV HOME=/home/"${USER}"
ENV APP_DIR="${HOME}/app"

RUN \
  apk upgrade --no-cache && \
  apk add --no-cache \
    openssl \
    ncurses-libs && \

  # Creates a unprivileged user to run the app
  addgroup \
   -g 1000 \
   -S "${USER}" && \
  adduser \
   -s /bin/sh \
   -u 1000 \
   -G "${USER}" \
   -h "${HOME}" \
   -D "${USER}" && \

  su "${USER}" sh -c "mkdir ${APP_DIR}"

# Everything from this line onwards will run in the context of the unprivileged user.
USER "${USER}"

WORKDIR "${APP_DIR}"

COPY --from=build --chown="${USER}":"${USER}" /app/_build/prod/rel/domo_bug ./

ENTRYPOINT ["./bin/domo_bug"]

# Docker Usage:
#  * build: sudo docker build -t phoenix/domo_bug .
#  * shell: sudo docker run --rm -it --entrypoint "" -p 80:4000 -p 443:4040 phoenix/domo_bug sh
#  * run:   sudo docker run --rm -it -p 80:4000 -p 443:4040 --env-file .env --name domo_bug phoenix/domo_bug
#  * exec:  sudo docker exec -it domo_bug sh
#  * logs:  sudo docker logs --follow --tail 10 domo_bug
#
# Extract the production release to your host machine with:
#
# ```
# sudo docker run --rm -it --entrypoint "" --user $(id -u) -v "$PWD/_build:/home/phoenix/_build"  phoenix/domo_bug sh -c "tar zcf /home/phoenix/_build/app.tar.gz ."
# ls -al _build
# ````
CMD ["start"]
