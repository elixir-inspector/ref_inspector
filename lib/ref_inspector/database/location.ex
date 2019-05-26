defmodule RefInspector.Database.Location do
  @moduledoc false

  alias RefInspector.Config

  @doc """
  Returns the local path to store a configured database at.
  """
  @spec local({binary, binary} | binary) :: binary
  def local({local, _remote}) do
    Path.join(Config.database_path(), local)
  end

  def local(remote) do
    Path.join(Config.database_path(), Path.basename(remote))
  end

  @doc """
  Returns the remote path to download a configured database from.
  """
  @spec remote({binary, binary} | binary) :: binary
  def remote({_local, remote}), do: remote
  def remote(remote), do: remote
end
