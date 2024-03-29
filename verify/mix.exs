defmodule RefInspector.Verification.MixProject do
  use Mix.Project

  def project do
    [
      app: :ref_inspector_verification,
      version: "0.0.1",
      elixir: "~> 1.9",
      deps: [{:ref_inspector, path: "../"}],
      deps_path: "../deps",
      lockfile: "../mix.lock"
    ]
  end
end
