# Ref Inspector

Referer parser library.


## Setup

### Dependency

To use Ref Inspector with your projects, edit your `mix.exs` file and add it as a
dependency:

```elixir
defp deps do
  [ { :ref_inspector, github: "elixytics/ref_inspector" } ]
end
```

You should also update your applications to include all necessary projects:

```elixir
def application do
  [ applications: [ :ref_inspector, :yamerl ] ]
end
```

### Referer Database

Using `mix ref_inspector.yaml.download` you can store a local copy of the
regexes database in the configured path. This database is taken from the
[referer-parser](https://github.com/snowplow/referer-parser) project.

The local path of the downloaded file will be shown to you upon command
invocation.

### Configuration

Add the path to the referer database you want to use to your project
configuration:

```elixir
use Mix.Config

config :ref_inspector,
  yaml: Path.join(Mix.Utils.mix_home, "ref_inspector/referers.yml")
```

The shown path is the default download path used by the mix task.


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

_Medium_ will be one of `:unknown`, `:email`, `:search` or `:social` (always an atom).

_Source_ will be `:unknown` (as atom) if nothing was matched, otherwise a string
with the detected provider.

_Term_ will be `:none` (as atom) if no query parameters were given to parse or the
provider does not send any terms to detect (mostly social or email referers).
Otherwise it will be an unencoded string will the term passed (can be empty).

_Referer_ will return the passed referer unmodified.


## Resources

- [referer-parser](https://github.com/snowplow/referer-parser)
- [yamerl](https://github.com/yakaz/yamerl)


## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

_Referers.yml_ taken from the [referer-parser](https://github.com/snowplow/referer-parser)
project. See there for detailed license information about the data contained.
