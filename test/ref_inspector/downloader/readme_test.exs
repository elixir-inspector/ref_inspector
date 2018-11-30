defmodule RefInspector.Downloader.READMETest do
  use ExUnit.Case, async: false

  alias RefInspector.Downloader.README

  setup_all do
    database_path = Application.get_env(:ref_inspector, :database_path)
    remote_urls = Application.get_env(:ref_inspector, :remote_urls)
    test_path = Path.expand("../../downloads", __DIR__)

    :ok = Application.put_env(:ref_inspector, :database_path, test_path)
    _ = File.rm(README.path_local())

    on_exit(fn ->
      :ok = Application.put_env(:ref_inspector, :database_path, database_path)
      :ok = Application.put_env(:ref_inspector, :remote_urls, remote_urls)
    end)
  end

  test "README creation for default remote" do
    :ok = Application.put_env(:ref_inspector, :remote_urls, ["non-default-remote.yml"])
    :ok = README.write()

    refute File.exists?(README.path_local())

    :ok = Application.delete_env(:ref_inspector, :remote_urls)
    :ok = Application.put_env(:ref_inspector, :skip_download_readme, true)
    :ok = README.write()

    refute File.exists?(README.path_local())

    :ok = Application.delete_env(:ref_inspector, :skip_download_readme)
    :ok = README.write()

    assert File.exists?(README.path_local())
  end
end
