# Ref Inspector

Referer parser library.


## Setup

### Dependency

To use Ref Inspector with your projects, edit your `mix.exs` file and add the
required dependencies:

```elixir
defp deps do
  [{ :ref_inspector, "~> 0.12" }]
end
```

You should also update your applications to include all necessary projects:

```elixir
def application do
  [ applications: [ :ref_inspector ]]
end
```

### Referer Database

Using `mix ref_inspector.yaml.download` you can store a local copy of the
regexes database in the configured path. This database is taken from the
[referer-parser](https://github.com/snowplow/referer-parser) project.

The local path of the downloaded file will be shown to you upon command
invocation.

### Configuration

Add the referer database you want to use to your project configuration:

```elixir
use Mix.Config

# static configuration
config :ref_inspector,
  database_files: [ "referers_search.yml", "referers_social.yml" ],
  database_path:  Path.join(Mix.Utils.mix_home, "ref_inspector") ]

# system environment configuration
config :ref_inspector,
  database_files: [{ :system, "SOME_SYSTEM_ENV_VARIABLE" }],
  database_path:  { :system, "SOME_SYSTEM_ENV_VARIABLE" }
```

#### Configuration (Database Files)

The remote urls of your database file are configurable:

```elixir
config :ref_inspector,
  remote_urls: [
    "https://raw.githubusercontent.com/snowplow/referer-parser/master/resources/referers.yml"
  ]
```

All files configured will be saved as under the configured database path
with the filename of the url.

Shown configuration is used as the default location during download.

#### Configuration (HTTP client)

The database is downloaded using
[`:hackney`](https://github.com/benoitc/hackney). To pass custom configuration
values to hackney you can use the key `:http_opts` in your config:

```elixir
config :ref_inspector,
  http_opts: [ proxy: "http://mycompanyproxy.com" ]
```

These values are expanded if using aforementioned `{ :system, "SOME_VAR" }`
rule and then passed unmodified to the client process.

Please see
[`:hackney.request/5`](https://hexdocs.pm/hackney/hackney.html#request-5)
for a complete list of available options.


## Usage

```elixir
iex(1)> RefInspector.parse("http://www.google.com/search?q=ref_inspector")
%RefInspector.Result{
  referer: "http://www.google.com/search?q=ref_inspector",
  medium:  "search",
  source:  "google",
  term:    "ref_inspector"
}
```

_Medium_ will be one of `:unknown`, `:email`, `:search` or `:social`
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
