defmodule RefInspector.Config do
  @moduledoc """
  Utility module to simplify access to configuration values.
  """

  require Logger

  @upstream_remote "https://s3-eu-west-1.amazonaws.com/snowplow-hosted-assets/third-party/referer-parser/referers-latest.yml"

  @default_files ["referers.yml"]
  @default_urls [{"referers.yml", @upstream_remote}]

  @doc """
  Provides access to configuration values with optional environment lookup.
  """
  @spec get(atom, term) :: term
  def get(key, default \\ nil) do
    Application.get_env(:ref_inspector, key, default)
  end

  @doc """
  Returns the list of configured database files.
  """
  @spec database_files :: list
  def database_files do
    case get(:database_files) do
      nil -> @default_files
      files when is_list(files) -> files
    end
  end

  @doc """
  Returns the configured database path.

  If the path is not defined the `priv` dir of `:ref_inspector`
  as returned by `Application.app_dir(:ref_inspector, "priv")` will be used.
  """
  @spec database_path :: String.t()
  def database_path do
    case get(:database_path) do
      nil -> Application.app_dir(:ref_inspector, "priv")
      path -> path
    end
  end

  @doc """
  Returns whether the remote database matches the default.
  """
  @spec default_remote_database? :: boolean
  def default_remote_database?, do: yaml_urls() == @default_urls

  @doc """
  Calls the optionally configured init method.
  """
  @spec init_env() :: :ok
  def init_env() do
    case get(:init) do
      nil -> :ok
      {mod, fun} -> apply(mod, fun, [])
    end
  end

  @doc """
  Returns the remote urls of the database file.
  """
  @spec yaml_urls :: [String.t() | {String.t(), String.t()}]
  def yaml_urls do
    case get(:remote_urls) do
      files when is_list(files) and 0 < length(files) -> files
      _ -> @default_urls
    end
  end
end
