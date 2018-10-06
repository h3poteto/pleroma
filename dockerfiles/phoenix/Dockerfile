FROM h3poteto/phoenix:1.7.3

USER root
ENV APP_DIR /var/opt/app
ADD . ${APP_DIR}
RUN chown -R elixir:elixir ${APP_DIR}

RUN set -ex && \
    curl -fsSL https://github.com/minamijoyo/myaws/releases/download/v0.3.2/myaws_v0.3.2_linux_amd64.tar.gz \
    | tar -xzC /usr/local/bin && chmod +x /usr/local/bin/myaws

USER elixir
ENV MIX_ENV=prod

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod && \
    mix deps.compile && \
    mix compile

EXPOSE 4000:4000

ENTRYPOINT ["./dockerfiles/phoenix/entrypoint.sh"]

CMD ["mix", "phx.server"]