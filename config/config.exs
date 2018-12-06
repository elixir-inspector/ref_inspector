use Mix.Config

if Mix.env() == :bench do
  config :ref_inspector, database_path: Path.expand("../bench/data", __DIR__)
end

if Mix.env() == :test do
  config :ref_inspector,
    database_files: ["referers_search.yml", "referers_social.yml"],
    database_path: Path.expand("../test/fixtures", __DIR__),
    ets_cleanup_delay: 10,
    internal: ["www.example.com", "www.example.org"]
end
