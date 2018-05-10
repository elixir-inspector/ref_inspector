# Ref Inspector

Referer parser library.


## Setup

### Dependency

To use Ref Inspector with your projects, edit your `mix.exs` file and add the
required dependencies:

```elixir
defp deps do
  [{ :ref_inspector, "~> 0.19" }]
end
```

### Application/Supervisor Setup

Probably the easiest way to manage startup is by simply
adding `:ref_inspector` to the list of applications:

```elixir
def application do
  [ applications: [ :ref_inspector ]]
end
```

A second possible approach is to take care of supervision yourself. This
means you should add `:ref_inspector` to your included applications instead:

```elixir
def application do
  [ included_applications: [ :ref_inspector ]]
end
```

And also add the appropriate `RefInspector.Supervisor` to your hierarchy:

```elixir
# in your application/supervisor
children = [
  # ...
  supervisor(RefInspector.Supervisor, [])
  # ..
]
```

### Referer Database

Using `mix ref_inspector.download` you can store a local copy of the
regexes database in the configured path. This database is taken from the
[referer-parser](https://github.com/snowplow/referer-parser) project.

The local path of the downloaded file will be shown to you upon command
invocation.

If you want to download the database files using your application you can
directly call `RefInspector.Downloader.download/0`.

When using both the mix task and a default remote configuration an informational
README is placed next to the downloaded file(s). This behaviour can be
deactivated by configuration:

```elixir
config :ref_inspector,
  skip_download_readme: true
```

### Configuration

Add the referer database you want to use to your project configuration:

```elixir
use Mix.Config

# static configuration
config :ref_inspector,
  database_files: [ "referers_search.yml", "referers_social.yml" ],
  database_path:  Path.join(Mix.Utils.mix_home, "ref_inspector") ]

# dynamic configuration
# { mod, fun } tuple without arguments
# called upon supervisor (re-) start
# and when running the mix download task
#
# This method is expected to always return `:ok`
config :ref_inspector
  init: { MyInitModule, :my_init_fun }
```

#### Configuration (Database Files)

The remote urls of your database file are configurable:

```elixir
# default configuration
config :ref_inspector,
  remote_urls: [{
    "referers.yml",
    "https://s3-eu-west-1.amazonaws.com/snowplow-hosted-assets/third-party/referer-parser/referers-latest.yml"
  }]

# custom configuration
config :ref_inspector,
  remote_urls: [
    "http://some.host/custom.yml",
    { "local_filename.yml", "http://some.host/remote_filename.yml" }
  ]
```

All files configured will be saved as under the configured database path.
If you have not configure a custom file path the filename extracted from the
url will be taken.

#### Configuration (ETS Cleanup)

When reloading the old database is deleted with a configurable delay. The delay
is defined in milliseconds with a default of `30_000`.

```elixir
config :ref_inspector,
  ets_cleanup_delay: 30_000
```

#### Configuration (HTTP client)

The database is downloaded using
[`:hackney`](https://github.com/benoitc/hackney). To pass custom configuration
values to hackney you can use the key `:http_opts` in your config:

```elixir
config :ref_inspector,
  http_opts: [ proxy: "http://mycompanyproxy.com" ]
```

Please see
[`:hackney.request/5`](https://hexdocs.pm/hackney/hackney.html#request-5)
for a complete list of available options.

#### Configuration (Worker Pool)

All parsing requests are internally done using a `:poolboy` worker pool. The
behaviour of this pool can be configured:

```elixir
config :ref_inspector,
  pool: [ max_overflow: 10, size: 5 ]
```

As these options are passed unmodified please look at the official
[poolboy documentation](https://github.com/devinus/poolboy) for details.

Defaults are defined in the module `RefInspector.Pool`.

### Reloading

Sometimes (for example after downloading a new database set) it is required to
reload the internal database. This can be done asynchronously:

```elixir
RefInspector.reload()
```

This process is handled in the background, so for some time the old data will
be used for lookups.

If you need to check if the database is still empty or (at least partially!)
loaded, you can use `RefInspector.ready?/0`. Please be aware that this method
checks the current state and not what will happen after an (potentially running)
reload is finished.


## Usage

```elixir
iex(1)> RefInspector.parse("http://www.google.com/search?q=ref_inspector")
%RefInspector.Result{
  referer: "http://www.google.com/search?q=ref_inspector",
  medium:  :search,
  source:  "google",
  term:    "ref_inspector"
}
```

_Medium_ will be one of `:unknown`, `:email`, `:paid`, `:search` or `:social`
(always an atom). If configured to do so it might also be `:internal`.

_Source_ will be `:unknown` (as atom) if nothing was matched, otherwise a string
with the detected provider.

_Term_ will be `:none` (as atom) if no query parameters were given to parse or the
provider does not send any terms to detect (mostly social or email referers).
Otherwise it will be an unencoded string will the term passed (can be empty).

_Referer_ will return the passed referer unmodified.

### Internal Domains

To exclude some domains from parsing you can mark them as `:internal` using
your configuration:

```elixir
config :ref_inspector,
  internal: [ "www.example.com", "www.example.org" ]
```

If a referer matches (== ends with) at least one of the configured domains
(paths ignored!), it will return a result with the medium `:internal`.
Both `:source` and `:term` will be left at the initial/unknown state not
intended for further processing.


## Resources

- [referer-parser](https://github.com/snowplow/referer-parser)


## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

_Referers.yml_ taken from the [referer-parser](https://github.com/snowplow/referer-parser)
project. See there for detailed license information about the data contained.
