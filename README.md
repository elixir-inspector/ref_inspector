# RefInspector

Referer parser library.

## Package Setup

To use RefInspector with your projects, edit your `mix.exs` file and add the
required dependencies:

```elixir
defp deps do
  [
    # ...
    {:ref_inspector, "~> 0.20"},
    # ...
  ]
end
```

### Package Startup (application)

Probably the easiest way to manage startup is by simply
adding `:ref_inspector` to the list of applications:

```elixir
def application do
  [
    applications: [
      # ...
      :ref_inspector,
      # ...
    ]
  ]
end
```

### Package Startup (manual supervision)

A second possible approach is to take care of supervision yourself. This
means you should add `:ref_inspector` to your included applications instead:

```elixir
def application do
  [
    included_applications: [
      # ...
      :ref_inspector,
      # ...
    ]
  ]
end
```

And also add the appropriate `RefInspector.Supervisor` to your hierarchy:

```elixir
# in your application/supervisor
children = [
  # ...
  RefInspector.Supervisor,
  # ..
]
```

## Application Configuration

To start using RefInspector you need to at least configure a `:database_path`.

If you are using the default database you can omit the `:database_files`
configuration value.

### Configuration (static)

One option for configuration is using a static configuration:

```elixir
config :ref_inspector,
  database_files: ["referers_search.yml", "referers_social.yml"],
  database_path: "/path/to/ref_inspector/databases"
```

### Configuration (dynamic)

If there are any reasons you cannot use a pre-defined configuration you
can also configure an initializer module to be called before starting
the application supervisor. This function is expected to always return `:ok`.

This may be the most suitable configuration if you have the databases located
in the `:priv_dir` of your application.

```elixir
config :ref_inspector,
  init: {MyInitModule, :my_init_fun}

defmodule MyInitModule do
  @spec my_init_fun() :: :ok
  def my_init_fun() do
    priv_dir = Application.app_dir(:my_app, "priv")

    Application.put_env(:ref_inspector, :database_path, priv_dir)
  end
end
```

### Configuration (Database Files)

The remote urls of your database file are configurable:

```elixir
# default configuration
config :ref_inspector,
  remote_urls: [
    {
      "referers.yml",
      "https://s3-eu-west-1.amazonaws.com/snowplow-hosted-assets/third-party/referer-parser/referers-latest.yml"
    }
  ]

# custom configuration
config :ref_inspector,
  remote_urls: [
    "http://some.host/custom.yml",
    {"local_filename.yml", "http://some.host/remote_filename.yml"}
  ]
```

All files configured will be saved as under the configured database path.
If you have not configure a custom file path the filename extracted from the
url will be taken.

### Configuration (ETS Cleanup)

When reloading the old database is deleted with a configurable delay. The delay
is defined in milliseconds with a default of `30_000`.

```elixir
config :ref_inspector,
  ets_cleanup_delay: 30_000
```

### Configuration (HTTP client)

The database is downloaded using
[`:hackney`](https://github.com/benoitc/hackney). To pass custom configuration
values to hackney you can use the key `:http_opts` in your config:

```elixir
config :ref_inspector,
  http_opts: [proxy: "http://mycompanyproxy.com"]
```

Please see
[`:hackney.request/5`](https://hexdocs.pm/hackney/hackney.html#request-5)
for a complete list of available options.

## Referer Database

Using `mix ref_inspector.download` you can store a local copy of the
regexes database in the configured path. This database is taken from the
[snowplow-referer-parser](https://github.com/snowplow-referer-parser/referer-parser)
project.

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

### Internal Domains

To exclude some domains from parsing you can mark them as internal using your configuration:

```elixir
config :ref_inspector,
  internal: ["www.example.com", "www.example.org"]
```

If a referer matches at least one of the configured domains (== ends with,
paths ignored!), it will return a result with the medium `:internal`.
Both `:source` and `:term` will be left at the initial/unknown state not
intended for further processing.

## Basic Usage

```elixir
iex(1)> RefInspector.parse("http://www.google.com/search?q=ref_inspector")
%RefInspector.Result{
  referer: "http://www.google.com/search?q=ref_inspector",
  medium: "search",
  source: "google",
  term: "ref_inspector"
}
```

Full documentation is available inline in the `RefInspector` module and at [https://hexdocs.pm/ref_inspector](https://hexdocs.pm/ref_inspector).

## Benchmark

Several (minimal) benchmark scripts are included. Please refer to the
Mixfile or `mix help` output for their names.

## Resources

- [snowplow-referer-parser](https://github.com/snowplow-referer-parser/referer-parser)

## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

_Referers.yml_ taken from the
[snowplow-referer-parser](https://github.com/snowplow-referer-parser/referer-parser)
project. See there for detailed license information about the data contained.
