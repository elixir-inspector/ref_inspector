defmodule RefInspector.MixProject do
  use Mix.Project

  @url_changelog "https://hexdocs.pm/ref_inspector/changelog.html"
  @url_github "https://github.com/elixir-inspector/ref_inspector"
  @version "2.1.0-dev"

  def project do
    [
      app: :ref_inspector,
      name: "RefInspector",
      version: @version,
      elixir: "~> 1.9",
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
      extra_applications: extra_applications(Mix.env()) ++ [:logger],
      mod: {RefInspector.Application, []}
    ]
  end

  defp aliases() do
    [
      "bench.database": "run bench/database.exs",
      "bench.parse": "run bench/parse.exs"
    ]
  end

  defp extra_applications(:test), do: [:inets]
  defp extra_applications(_), do: []

  defp deps do
    [
      {:benchee, "~> 1.3", only: :bench, runtime: false},
      {:credo, "~> 1.7", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.16.0", only: :test, runtime: false},
      {:hackney, "~> 1.0"},
      {:yamerl, "~> 0.7"}
    ]
  end

  defp dialyzer do
    [
      flags: [
        :error_handling,
        :underspecs,
        :unmatched_returns
      ],
      ignore_warnings: ".dialyzer_ignore.exs",
      list_unused_filters: true,
      plt_add_apps: [:mix],
      plt_core_path: "plts",
      plt_local_path: "plts"
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md",
        LICENSE: [title: "License"],
        "README.md": [title: "Overview"]
      ],
      formatters: ["html"],
      groups_for_modules: [
        "Database Downloader": [
          RefInspector.Downloader,
          RefInspector.Downloader.Adapter
        ]
      ],
      main: "RefInspector",
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @url_github
    ]
  end

  defp package do
    [
      files: ["CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib", "priv"],
      licenses: ["Apache-2.0"],
      links: %{
        "Changelog" => @url_changelog,
        "GitHub" => @url_github
      }
    ]
  end
end
