defmodule RefInspector.Verification.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ref_inspector_verification,
      version: "0.0.1",
      elixir: "~> 1.5",
      deps: [{:ref_inspector, path: "../"}],
      deps_path: "../deps",
      lockfile: "../mix.lock"
    ]
  end
end
