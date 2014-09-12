defmodule ExReferer.Mixfile do
  use Mix.Project

  def project do
    [ app:        :ex_referer,
      name:       "ExReferer",
      source_url: "https://github.com/elixytics/ex_referer",
      version:    "0.4.0",
      elixir:     "~> 1.0",
      deps:       deps(Mix.env),
      docs:       [ readme: true, main: "README" ] ]
  end

  def application do
    [ applications: [ :yamerl ],
      mod:          { ExReferer, [] } ]
  end

  def deps(:docs) do
    deps(:prod) ++
      [ { :earmark, "~> 0.1" },
        { :ex_doc,  "~> 0.6" } ]
  end

  def deps(_) do
    [ { :poolboy, "~> 1.0" },
      { :yamerl,  github: "yakaz/yamerl" } ]
  end
end
