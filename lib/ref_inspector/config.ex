defmodule RefInspector.Config do
  @moduledoc """
  Utility module to simplify access to configuration values.
  """

  @default_url   "https://raw.githubusercontent.com/snowplow/referer-parser/master/resources/referers.yml"
  @default_files [ "referers.yml" ]

  @doc """
  Provides access to configuration values with optional environment lookup.
  """
  @spec get(atom, term) :: term
  def get(key, default \\ nil) do
    :ref_inspector
    |> Application.get_env(key, default)
    |> maybe_fetch_system()
  end

  @doc """
  Returns the list of configured database files.
  """
  @spec database_files :: list
  def database_files do
    case get(:database_files) do
      files when is_list(files) and 0 < length(files) -> files

      _ -> maybe_fetch_legacy_files() || @default_files
    end
  end

  @doc """
  Returns the configured database path or `nil`.
  """
  @spec database_path :: String.t | nil
  def database_path do
    case get(:database_path) do
      nil  -> maybe_fetch_legacy_path()
      path -> Path.expand(path)
    end
  end

  @doc """
  Returns the remote url of the database file.
  """
  @spec yaml_url :: String.t
  def yaml_url, do: get(:remote_url, @default_url)


  defp maybe_fetch_system(config) when is_list(config) do
    Enum.map config, fn
      { k, v } -> { k, maybe_fetch_system(v) }
      other    -> other
    end
  end

  defp maybe_fetch_system({ :system, var }), do: System.get_env(var)
  defp maybe_fetch_system(config),           do: config


  defp maybe_fetch_legacy_files() do
    case get(:yaml) do
      nil  -> nil
      yaml ->
        IO.write :stderr, "You are using a deprecated ':yaml' configuration" <>
                          " to define the filename for your database." <>
                          " Please update your configuration to the new format."

        [ Path.basename(yaml) ]
    end
  end

  defp maybe_fetch_legacy_path() do
    case get(:yaml) do
      nil  -> nil
      yaml ->
        IO.write :stderr, "You are using a deprecated ':yaml' configuration" <>
                          " to define the path for your database." <>
                          " Please update your configuration to the new format."

        Path.dirname(yaml)
    end
  end
end
