# RefInspector

Referer parser library.

## Package Setup

To use RefInspector with your projects, edit your `mix.exs` file and add the required dependencies:

```elixir
defp deps do
  [
    # ...
    {:ref_inspector, "~> 1.0"},
    # ...
  ]
end
```

If you want to use a manual supervision approach (without starting the application) please look at the inline documentation of `RefInspector.Supervisor`.

## Application Configuration

Out of the box the default database will be stored in the `:priv_dir` of `:ref_inspector`. Both the database(s) and path used can be changed.

For a detailed list of available configuration options please consult `RefInspector.Config`.

## Referer Database

The default database is taken from the [snowplow-referer-parser](https://github.com/snowplow-referer-parser/referer-parser) project.

### Internal Domains

To exclude some domains from parsing you can mark them as internal using your configuration:

```elixir
config :ref_inspector,
  internal: ["www.example.com", "www.example.org"]
```

If a referer matches at least one of the configured domains (== ends with, paths ignored!), it will return a result with the medium `:internal`. Both `:source` and `:term` will be left at the initial/unknown state not intended for further processing.

## Basic Usage

### Database Download

You need to obtain a copy of the configured database by calling either `mix ref_inspector.download` from the command line or `RefInspector.Downloader.download/0` from within your application.

Refer to `RefInspector.Downloader` for more details.

### Referer Parsing

```elixir
iex(1)> RefInspector.parse("http://www.google.com/search?q=ref_inspector")
%RefInspector.Result{
  medium: "search",
  referer: "http://www.google.com/search?q=ref_inspector",
  source: "Google",
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
