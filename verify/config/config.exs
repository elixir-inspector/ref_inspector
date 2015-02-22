use Mix.Config

config :ref_inspector,
  yaml:              Path.join(__DIR__, "../database/referers.yml"),
  pool_max_overflow: 0,
  pool_size:         1
