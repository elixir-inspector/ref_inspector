defmodule RefInspector.Downloader do
  @moduledoc """
  Fetches copies of each configured database file.

  The copies will be stored inside the configured path.
  """

  alias RefInspector.Config


  @doc """
  Performs the download of the configured database files.
  """
  @spec download() :: :ok
  def download() do
    File.mkdir_p! Config.database_path

    Enum.each Config.yaml_urls, fn (config) ->
      local  = path_local(config)
      remote = path_remote(config)

      { :ok, content } = read_remote(remote)

      File.write(local, content)
    end
  end

  @doc """
  Returns the local path to store a configured database at.
  """
  @spec path_local({ String.t, String.t } | String.t) :: String.t
  def path_local({ local, _remote }) do
    Path.join([ Config.database_path, local ])
  end

  def path_local(remote) do
    Path.join([ Config.database_path, Path.basename(remote) ])
  end

  @doc """
  Returns the remote path to download a configured database from.
  """
  @spec path_remote({ String.t, String.t } | String.t) :: String.t
  def path_remote({ _local, remote }), do: remote
  def path_remote(remote),             do: remote

  @doc """
  Reads a remote file and returns it's contents.
  """
  @spec read_remote(String.t) :: String.t
  def read_remote(path) do
    http_opts             = Config.get(:http_opts, [])
    { :ok, _, _, client } = :hackney.get(path, [], [], http_opts)

    :hackney.body(client)
  end
end
