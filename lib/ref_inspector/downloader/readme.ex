defmodule RefInspector.Downloader.README do
  @moduledoc false

  require Logger

  alias RefInspector.Config
  alias RefInspector.Database.Location

  @readme "ref_inspector.readme.md"

  @doc false
  @spec path_local() :: binary
  def path_local do
    _ =
      Logger.info(
        "RefInspector.Downloader.README.path_local/0 has been" <>
          " declared internal and will eventually be removed."
      )

    Location.local(@readme)
  end

  @doc false
  @spec path_priv() :: binary
  def path_priv do
    _ =
      Logger.info(
        "RefInspector.Downloader.README.path_priv/0 has been" <>
          " declared internal and will eventually be removed."
      )

    Application.app_dir(:ref_inspector, ["priv", @readme])
  end

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
    readme_local = Location.local(@readme)
    readme_priv = Application.app_dir(:ref_inspector, ["priv", @readme])

    dirname_local = Path.dirname(readme_local)

    unless File.dir?(dirname_local) do
      File.mkdir_p!(dirname_local)
    end

    {:ok, _} = File.copy(readme_priv, readme_local)
    :ok
  end
end
