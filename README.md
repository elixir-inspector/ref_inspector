# ExReferer

## Usage

    iex(1)> ExReferer.parse("http://some.referer.com/with?query=parameters")
    [ medium: :search,
      source: "google",
      term:   "ex_referer",
      string: "http://www.google.com/search?q=ex_referer" ]

Medium will be one of :unknown, :email, :search or :social (always an atom).

Source will be :unknown (as atom) if nothing was matched, otherwise a string
with the detected provider.

Term will be :none if no query parameters where given to parse or the provider
does not send any terms to detect (mostly social or email referers). Otherwise
it will be an unencoded string will the term passed (can be empty).


## Resources

- [httpotion](https://github.com/myfreeweb/httpotion)
- [referer-parser](https://github.com/snowplow/referer-parser)
- [yamler](https://github.com/superbobry/yamler)


## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

_Referers.yml_ taken from the [referer-parser](https://github.com/snowplow/referer-parser)
project. See there for detailed license information about the data contained.
