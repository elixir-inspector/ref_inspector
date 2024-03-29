defmodule RefInspector.Downloader.Adapter.Hackney do
  @moduledoc false

  alias RefInspector.Config

  @behaviour RefInspector.Downloader.Adapter

  @impl RefInspector.Downloader.Adapter
  def read_remote(location) do
    _ = Application.ensure_all_started(:hackney)

    http_opts = Config.get(:http_opts, [])

    case :hackney.get(location, [], [], http_opts) do
      {:ok, _, _, client} -> :hackney.body(client)
      {:error, _} = error -> error
    end
  end
end
