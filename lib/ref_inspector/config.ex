defmodule RefInspector.Config do
  @moduledoc """
  Utility module to simplify access to configuration values.
  """

  @doc """
  Provides access to configuration values with optional environment lookup.
  """
  @spec get(atom) :: term
  def get(key) do
    :ref_inspector
    |> Application.get_env(key)
    |> maybe_fetch_system()
  end

  @doc """
  Returns the configured yaml path or `nil`.
  """
  @spec yaml_path :: String.t | nil
  def yaml_path do
    case get(:yaml) do
      nil  -> nil
      path -> Path.expand(path)
    end
  end


  defp maybe_fetch_system(config) when is_list(config) do
    Enum.map config, fn
      { k, v } -> { k, maybe_fetch_system(v) }
      other    -> other
    end
  end

  defp maybe_fetch_system({ :system, var }), do: System.get_env(var)
  defp maybe_fetch_system(config),           do: config
end
