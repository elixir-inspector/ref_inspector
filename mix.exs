defmodule RefInspector.MixProject do
  use Mix.Project

  @url_github "https://github.com/elixir-inspector/ref_inspector"

  def project do
    [
      app: :ref_inspector,
      name: "RefInspector",
      version: "2.0.0-dev",
      elixir: "~> 1.7",
      aliases: aliases(),
      deps: deps(),
      description: "Referer parser library",
      dialyzer: dialyzer(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        "bench.database": :bench,
        "bench.parse": :bench,
        coveralls: :test,
        "coveralls.detail": :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {RefInspector.Application, []}
    ]
  end

  defp aliases() do
    [
      "bench.database": "run bench/database.exs",
      "bench.parse": "run bench/parse.exs"
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.0", only: :bench, runtime: false},
      {:credo, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14.0", only: :test, runtime: false},
      {:hackney, "~> 1.0"},
      {:yamerl, "~> 0.7"}
    ]
  end

  defp dialyzer do
    [
      flags: [
        :error_handling,
        :race_conditions,
        :underspecs,
        :unmatched_returns
      ],
      ignore_warnings: ".dialyzer_ignore.exs",
      list_unused_filters: true,
      plt_add_apps: [:mix],
      plt_core_path: "plts",
      plt_file: {:no_warn, "plts/dialyzer.plt"}
    ]
  end

  defp docs do
    [
      main: "RefInspector",
      source_ref: "master",
      source_url: @url_github
    ]
  end

  defp package do
    %{
      files: ["CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib", "priv"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @url_github}
    }
  end
end
