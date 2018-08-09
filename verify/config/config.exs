use Mix.Config

config :ref_inspector,
  database_files: ["referers.yml"],
  database_path: Path.join(__DIR__, "../database"),
  internal: ["snowplowanalytics.com"]
