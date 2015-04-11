use Mix.Config

config :ref_inspector,
  yaml: Path.join(__DIR__, "../test/fixtures/referers.yml"),
  pool: [ max_overflow: 0, size: 1 ]
