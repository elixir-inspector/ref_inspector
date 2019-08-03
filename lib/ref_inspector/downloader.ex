defmodule RefInspector.Downloader do
  @moduledoc """
  Fetches copies of the configured database file(s).

  All files will be stored in the configured database path with the default
  setting being the result of `Application.app_dir(:ref_inspector, "priv")`.

  Please consult `RefInspector.Config` for details on database configuration.

  ## Mix Task

  Please see `Mix.Tasks.RefInspector.Download` if you are interested in
  using a mix task to obtain your database file(s).
  """

  require Logger

  alias RefInspector.Config
  alias RefInspector.Database.Location

  @doc """
  Performs the download of the configured database files.
  """
  @spec download() :: :ok
  def download do
    File.mkdir_p!(Config.database_path())

    Enum.each(Config.yaml_urls(), fn config ->
      local = Location.local(config)
      remote = Location.remote(config)

      {:ok, content} = Config.downloader_adapter().read_remote(remote)

      File.write(local, content)
    end)
  end
end
