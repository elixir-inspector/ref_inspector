# ExReferer

Referer parser library.


## Configuration

To use ExReferer with your projects, edit your `mix.exs` file and add it as a
dependency:

```elixir
defp deps do
  [ { :ex_referer, github: "elixytics/ex_referer" } ]
end
```


## Usage

```elixir
iex(1)> ExReferer.start_link()
{ :ok, #PID<0.80.0> }
iex(2)> ExReferer.load_yaml("/path/to/referers.yml")
:ok
iex(3)> ExReferer.parse("http://www.google.com/search?q=ex_referer")
%ExReferer.Response{
  string: "http://www.google.com/search?q=ex_referer",
  medium: "search",
  source: "google",
  term:   "ex_referer"
}
```

_Medium_ will be one of __:unknown__, __:email__, __:search__ or __:social__ (always an atom).

_Source_ will be __:unknown__ (as atom) if nothing was matched, otherwise a string
with the detected provider.

_Term_ will be __:none__ (as atom) if no query parameters were given to parse or the
provider does not send any terms to detect (mostly social or email referers).
Otherwise it will be an unencoded string will the term passed (can be empty).

_String_ will return the passed referer unmodified.

### Downloading "referers.yml"

Using `mix ex_referer.yaml.download` you can store a local copy of the referers
database to your local MIX_HOME directory.

The complete path will be shown to you upon command invocation.

After downloading you can load it during startup:

```elixir
iex(1)> ExReferer.start_link()
{ :ok, #PID<0.80.0> }
iex(2)> ExReferer.load_yaml(Mix.ExReferer.local_yaml)
:ok
```


## Resources

- [referer-parser](https://github.com/snowplow/referer-parser)
- [yamerl](https://github.com/yakaz/yamerl)


## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

_Referers.yml_ taken from the [referer-parser](https://github.com/snowplow/referer-parser)
project. See there for detailed license information about the data contained.
