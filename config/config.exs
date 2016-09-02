use Mix.Config

config :ref_inspector,
  database_path:  Path.join(__DIR__, "../test/fixtures"),
  internal:       [ "www.example.com", "www.example.org" ],
  pool:           [ max_overflow: 0, size: 1 ]
