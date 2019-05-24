defmodule RefInspector.Downloader.Adapter.Hackney do
  @moduledoc false

  alias RefInspector.Config

  @behaviour RefInspector.Downloader.Adapter

  @doc """
  Reads a remote file and returns it's contents.
  """
  @spec read_remote(binary) :: {:ok, binary} | {:error, term}
  def read_remote(path) do
    _ = Application.ensure_all_started(:hackney)

    http_opts = Config.get(:http_opts, [])
    {:ok, _, _, client} = :hackney.get(path, [], [], http_opts)

    :hackney.body(client)
  end
end
