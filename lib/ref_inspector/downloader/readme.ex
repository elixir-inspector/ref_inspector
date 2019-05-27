defmodule RefInspector.Downloader.README do
  @moduledoc false

  alias RefInspector.Config
  alias RefInspector.Database.Location

  @readme "ref_inspector.readme.md"

  @doc """
  Returns the path to the local copy of the README file.
  """
  @spec path_local() :: binary
  def path_local, do: Location.local(@readme)

  @doc """
  Returns the path of the README file distributed in priv_dir.
  """
  @spec path_priv() :: binary
  def path_priv, do: Application.app_dir(:ref_inspector, ["priv", @readme])

  @doc """
  Writes the informational README file if remote database is the default.
  """
  @spec write() :: :ok
  def write do
    default? = Config.default_remote_database?()
    readme? = !Config.get(:skip_download_readme)

    case default? && readme? do
      true -> do_write()
      false -> :ok
    end
  end

  defp do_write do
    readme_local = path_local()
    dirname_local = Path.dirname(readme_local)

    unless File.dir?(dirname_local) do
      File.mkdir_p!(dirname_local)
    end

    {:ok, _} = File.copy(path_priv(), readme_local)
    :ok
  end
end
