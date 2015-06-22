use Mix.Config

config :ref_inspector,
  internal: [ "snowplowanalytics.com" ],
  yaml:     Path.join(__DIR__, "../database/referers.yml"),
  pool:     [ max_overflow: 0, size: 1 ]
