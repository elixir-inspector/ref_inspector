defmodule RefInspector.Downloader.Adapter.HackneyTest do
  use ExUnit.Case, async: true

  alias RefInspector.Downloader.Adapter.Hackney

  test "errors returned from adapter" do
    assert Hackney.read_remote("invalid") == {:error, :nxdomain}
  end
end
