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

  alias RefInspector.Config

  @doc """
  Performs the download of the configured database files.
  """
  @spec download() :: :ok
  def download do
    File.mkdir_p!(Config.database_path())

    Enum.each(Config.yaml_urls(), fn config ->
      local = path_local(config)
      remote = path_remote(config)

      {:ok, content} = read_remote(remote)

      File.write(local, content)
    end)
  end

  @doc """
  Returns the local path to store a configured database at.
  """
  @spec path_local({binary, binary} | binary) :: binary
  def path_local({local, _remote}) do
    Path.join([Config.database_path(), local])
  end

  def path_local(remote) do
    Path.join([Config.database_path(), Path.basename(remote)])
  end

  @doc """
  Returns the remote path to download a configured database from.
  """
  @spec path_remote({binary, binary} | binary) :: binary
  def path_remote({_local, remote}), do: remote
  def path_remote(remote), do: remote

  @doc """
  Reads a remote file and returns it's contents.

  Uses the module returned by `Config.downloader_adpater/0`.
  """
  @spec read_remote(binary) :: {:ok, binary} | {:error, term}
  def read_remote(path), do: Config.downloader_adapter().read_remote(path)
end
