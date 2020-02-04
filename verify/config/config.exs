use Mix.Config

config :ref_inspector,
  database_files: ["referers.yml"],
  database_path: Path.expand("../database", __DIR__),
  internal: ["snowplowanalytics.com"],
  remote_urls: [
    {"referers.yml",
     "https://raw.githubusercontent.com/snowplow-referer-parser/referer-parser/master/resources/referers.yml"}
  ]
