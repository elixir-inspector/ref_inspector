defmodule RefInspector.Downloader.README do
  @moduledoc """
  README writer for generic (license) information when using the default
  remote database configuration.
  """

  alias RefInspector.Config

  @readme "ref_inspector.readme.md"

  @doc """
  Returns the path to the local copy of the README file.
  """
  @spec path :: Path.t()
  def path(), do: Path.join(Config.database_path(), @readme)

  @doc """
  Writes the informational README file if remote database is the default.
  """
  @spec write :: :ok
  def write() do
    case Config.default_remote_database?() do
      true -> do_write()
      false -> :ok
    end
  end

  defp do_write() do
    source = Path.join(:code.priv_dir(:ref_inspector), @readme)
    target = path()

    {:ok, _} = File.copy(source, target)
    :ok
  end
end
