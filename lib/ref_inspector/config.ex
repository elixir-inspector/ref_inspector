defmodule RefInspector.Config do
  @moduledoc """
  Utility module to simplify access to configuration values.
  """

  @doc """
  Returns the configured yaml path or `nil`.
  """
  @spec yaml_path :: String.t | nil
  def yaml_path do
    case Application.get_env(:ref_inspector, :yaml, nil) do
      nil  -> nil
      path -> path |> Path.expand()
    end
  end
end
