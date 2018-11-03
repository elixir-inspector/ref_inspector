# RefInspector

Referer parser library.

## Package Setup

To use RefInspector with your projects, edit your `mix.exs` file and add the required dependencies:

```elixir
defp deps do
  [
    # ...
    {:ref_inspector, "~> 0.20"},
    # ...
  ]
end
```

If you want to use a manual supervision approach (without starting the application) please look at the inline documentation of `RefInspector.Supervisor`.

## Application Configuration

Out of the box the default database will be stored in the `:priv_dir` of `:ref_inspector`. Both the database(s) and path used can be changed.

For a detailed list of available configuration options please consult `RefInspector.Config`.

## Referer Database

Using `mix ref_inspector.download` you can store a local copy of the regexes database in the configured path. This database is taken from the [snowplow-referer-parser](https://github.com/snowplow-referer-parser/referer-parser) project.

The local path of the downloaded file will be shown to you upon command invocation.

As a default database path (if not configured otherwise) the result of `Application.app_dir(:ref_inspector, "priv")` will be used.

If you want to download the database files using your application you can directly call `RefInspector.Downloader.download/0`.

When using both the mix task and a default remote configuration an informational README is placed next to the downloaded file(s). This behaviour can be deactivated by configuration:

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

If a referer matches at least one of the configured domains (== ends with, paths ignored!), it will return a result with the medium `:internal`. Both `:source` and `:term` will be left at the initial/unknown state not intended for further processing.

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

Several (minimal) benchmark scripts are included. Please refer to the Mixfile or `mix help` output for their names.

## Resources

- [snowplow-referer-parser](https://github.com/snowplow-referer-parser/referer-parser)

## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

_Referers.yml_ taken from the [snowplow-referer-parser](https://github.com/snowplow-referer-parser/referer-parser) project. See there for detailed license information about the data contained.
