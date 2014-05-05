# ExReferer

## Usage

```elixir
iex(1)> ExReferer.parse("http://some.referer.com/with?query=parameters")
[ medium: :search,
  source: "google",
  term:   "ex_referer",
  string: "http://www.google.com/search?q=ex_referer" ]
```

_Medium_ will be one of __:unknown__, __:email__, __:search__ or __:social__ (always an atom).

_Source_ will be __:unknown__ (as atom) if nothing was matched, otherwise a string
with the detected provider.

_Term_ will be __:none__ (as atom) if no query parameters were given to parse or the
provider does not send any terms to detect (mostly social or email referers).
Otherwise it will be an unencoded string will the term passed (can be empty).

_String_ will return the passed referer unmodified.


## Resources

- [referer-parser](https://github.com/snowplow/referer-parser)
- [yamler](https://github.com/superbobry/yamler)


## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

_Referers.yml_ taken from the [referer-parser](https://github.com/snowplow/referer-parser)
project. See there for detailed license information about the data contained.
