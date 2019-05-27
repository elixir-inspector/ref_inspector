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

  @doc false
  @spec path_local({binary, binary} | binary) :: binary
  def path_local(local) do
    _ =
      Logger.info(
        "RefInspector.Downloader.path_local/1 has been" <>
          " declared internal and will eventually be removed."
      )

    Location.local(local)
  end

  @doc false
  @spec path_remote({binary, binary} | binary) :: binary
  def path_remote(remote) do
    _ =
      Logger.info(
        "RefInspector.Downloader.path_remote/1 has been" <>
          " declared internal and will eventually be removed."
      )

    Location.remote(remote)
  end

  @doc false
  @spec read_remote(binary) :: {:ok, binary} | {:error, term}
  def read_remote(location) do
    _ =
      Logger.info(
        "RefInspector.Downloader.read_remote/1 has been" <>
          " declared internal and will eventually be removed."
      )

    Config.downloader_adapter().read_remote(location)
  end
end
