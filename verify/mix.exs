defmodule RefInspector.Verification.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ref_inspector_verification,
      version: "0.0.1",
      elixir: "~> 1.3",
      deps: deps(),
      deps_path: "../deps",
      lockfile: "../mix.lock"
    ]
  end

  def application do
    [applications: [:ref_inspector]]
  end

  defp deps do
    [{:ref_inspector, path: "../"}]
  end
end
