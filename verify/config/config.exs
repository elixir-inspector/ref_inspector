use Mix.Config

config :ref_inspector,
  database_files: ["referers.yml"],
  database_path: Path.expand("../database", __DIR__),
  internal: ["snowplowanalytics.com"],
  startup_sync: true
