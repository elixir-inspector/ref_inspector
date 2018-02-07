use Mix.Config

config :ref_inspector,
  database_files: ["referers_search.yml", "referers_social.yml"],
  database_path: Path.join(__DIR__, "../test/fixtures"),
  ets_cleanup_delay: 10,
  internal: ["www.example.com", "www.example.org"],
  pool: [max_overflow: 0, size: 1]
