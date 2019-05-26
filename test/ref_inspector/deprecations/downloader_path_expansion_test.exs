defmodule RefInspector.Deprecations.DownloaderPathExpansionTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias RefInspector.Downloader

  test "path_local/1" do
    assert capture_log(fn ->
             _ = Downloader.path_local({"local", "remote"})
           end) =~ ~r/declared internal/i
  end

  test "path_remote/1" do
    assert capture_log(fn ->
             _ = Downloader.path_remote({"local", "remote"})
           end) =~ ~r/declared internal/i
  end

  test "read_remote/1" do
    assert capture_log(fn ->
             _ = Downloader.read_remote("remote")
           end) =~ ~r/declared internal/i
  end
end
