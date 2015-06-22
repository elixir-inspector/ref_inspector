use Mix.Config

config :ref_inspector,
  internal: [ "www.example.com", "www.example.org" ],
  yaml:     Path.join(__DIR__, "../test/fixtures/referers.yml"),
  pool:     [ max_overflow: 0, size: 1 ]
