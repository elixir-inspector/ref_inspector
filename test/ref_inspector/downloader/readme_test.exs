defmodule RefInspector.Downloader.READMETest do
  use ExUnit.Case, async: false

  alias RefInspector.Downloader.README

  @test_path Path.expand("../../downloads", __DIR__)
  @test_readme Path.join(@test_path, "ref_inspector.readme.md")

  setup_all do
    database_path = Application.get_env(:ref_inspector, :database_path)
    remote_urls = Application.get_env(:ref_inspector, :remote_urls)

    :ok = Application.put_env(:ref_inspector, :database_path, @test_path)
    _ = File.rm(@test_readme)

    on_exit(fn ->
      :ok = Application.put_env(:ref_inspector, :database_path, database_path)
      :ok = Application.put_env(:ref_inspector, :remote_urls, remote_urls)
    end)
  end

  test "README creation for default remote" do
    :ok = Application.put_env(:ref_inspector, :remote_urls, ["non-default-remote.yml"])
    :ok = README.write()

    refute File.exists?(@test_readme)

    :ok = Application.delete_env(:ref_inspector, :remote_urls)
    :ok = Application.put_env(:ref_inspector, :skip_download_readme, true)
    :ok = README.write()

    refute File.exists?(@test_readme)

    :ok = Application.delete_env(:ref_inspector, :skip_download_readme)
    :ok = README.write()

    assert File.exists?(@test_readme)
  end
end
