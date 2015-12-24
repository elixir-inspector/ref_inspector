defmodule RefInspector.Mixfile do
  use Mix.Project

  @url_docs "http://hexdocs.pm/ref_inspector"
  @url_github "https://github.com/elixytics/ref_inspector"

  def project do
    [ app:           :ref_inspector,
      name:          "RefInspector",
      description:   "Referer parser library",
      package:       package,
      version:       "0.9.0-dev",
      elixir:        "~> 1.0",
      deps:          deps(Mix.env),
      docs:          docs,
      test_coverage: [ tool: ExCoveralls ]]
  end

  def application do
    [ applications: [ :poolboy, :yamerl ],
      mod:          { RefInspector, [] } ]
  end

  def deps(:docs) do
    deps(:prod) ++
      [ { :earmark, "~> 0.1",  optional: true },
        { :ex_doc,  "~> 0.11", optional: true } ]
  end

  def deps(:test) do
    deps(:prod) ++
      [ { :dialyze,     "~> 0.2", optional: true },
        { :excoveralls, "~> 0.4", optional: true } ]
  end

  def deps(_) do
    [ { :poolboy, "~> 1.0" },
      { :yamerl,  github: "yakaz/yamerl" } ]
  end

  def docs do
    [ extras:     [ "CHANGELOG.md", "README.md" ],
      main:       "readme",
      source_ref: "master",
      source_url: @url_github ]
  end

  def package do
    %{ files:       [ "CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib" ],
       licenses:    [ "Apache 2.0" ],
       links:       %{ "Docs" => @url_docs, "GitHub" => @url_github },
       maintainers: [ "Marc Neudert" ]}
  end
end
