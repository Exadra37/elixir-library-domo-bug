# DomoBug

Proof of concept for this [issue](https://github.com/IvanRublev/Domo/issues/3) in the Domo Library.

## DOCKER

Run the the proof of concept for the bug with the included docker stack for development and production.

### Setup Env file

Copy the example file:

```
cp .env.example .env
```

Create the secret key base:

```
$ mix phx.gen.secret
zf1VzetidccgkGNVTOij+fOVh+2GJbyME8zyX6ZcoTL6Jg+xCjqBPIcNnyQhkbti
```

Add the secret to the `.env` file:

```
SECRET_KEY_BASE=zf1VzetidccgkGNVTOij+fOVh+2GJbyME8zyX6ZcoTL6Jg+xCjqBPIcNnyQhkbti
```

### Dev

Build the development image:

```
docker-compose build dev
```

Get a shell inside the docker container:

```
docker-compose run --rm --service-ports dev
```

Now you should be in the docker container shell...

In case you have already fetched the deps and build the app from the host you need to remove the build and deps folder:

```
rm -rf _build deps
```

Get deps:

```
mix deps.get
```

Run with:

```
iex -S mix phx.server
```

Visit http://localhost:4000 or do it with `cURL`:

```
$ curl localhost:4000
{"data":{"since":"2021-04-10T18:30:01.263609","state":"todo","title":"Task Todo"}}
```

### Prod

Build the release:

```
docker-compose build release
```

Run the release:

```
docker-compose up prod
```

Visit http://localhost:8000 or do it with `cURL`:

```
$ curl localhost:8000
{"errors":{"detail":"Internal Server Error"}}
```

and the error in the logs:

```
Request: GET /
prod_1     | ** (exit) an exception was raised:
prod_1     |     ** (UndefinedFunctionError) function Mix.Compilers.ApplicationTracer.trace/2 is undefined (module Mix.Compilers.ApplicationTracer is not available)
prod_1     |         Mix.Compilers.ApplicationTracer.trace({:alias_reference, [line: 10], NaiveDateTime}, #Macro.Env<aliases: [], context: nil, context_modules: [ProgressType], file: "/app/lib/progress_type.ex", function: nil, functions: [{Kernel, [!=: 2, !==: 2, *: 2, ...]}], lexical_tracker: #PID<3.1671.0>, line: 7, macro_aliases: [], macros: [{Domo, ...}, {...}], module: ProgressType, requires: [...], ...>)
prod_1     |         (elixir 1.11.3) src/elixir_env.erl:36: :elixir_env."-trace/2-lc$^0/1-0-"/3
prod_1     |         (elixir 1.11.3) src/elixir_env.erl:36: :elixir_env.trace/2
prod_1     |         (elixir 1.11.3) lib/macro.ex:1440: Macro.do_expand_once/2
prod_1     |         (elixir 1.11.3) lib/macro.ex:1610: Macro.expand_until/2
prod_1     |         (domo 1.0.1) lib/domo/type_spec_matchable/remote_type.ex:11: Domo.TypeSpecMatchable.RemoteType.expand/2
prod_1     |         (domo 1.0.1) lib/domo/type_contract.ex:642: Domo.TypeSpecMatchable.Any.match_spec?/3
prod_1     |         (domo_bug 0.1.0) lib/progress_type.ex:7: ProgressType.TypeChecker.__field_error/1
```
