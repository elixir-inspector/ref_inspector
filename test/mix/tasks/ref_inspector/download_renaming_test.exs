defmodule Mix.Tasks.RefInspector.DownloadRenamingTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias Mix.Tasks.RefInspector.Download

  @fixture_file "empty.yml"
  @fixture_path Path.expand("../../../fixtures", __DIR__)
  @test_file "empty_renamed.yml"
  @test_path Path.expand("../../../downloads", __DIR__)

  setup_all do
    httpd_opts = [
      port: 0,
      server_name: ~c"ref_inspector_test",
      server_root: String.to_charlist(@fixture_path),
      document_root: String.to_charlist(@fixture_path)
    ]

    {:ok, httpd_pid} = :inets.start(:httpd, httpd_opts)

    # configure app to use testing webserver
    remote_base = "http://localhost:#{:httpd.info(httpd_pid)[:port]}"
    yaml_urls = Application.get_env(:ref_inspector, :remote_urls)

    :ok =
      Application.put_env(:ref_inspector, :remote_urls, [
        {@test_file, "#{remote_base}/#{@fixture_file}"}
      ])

    on_exit(fn ->
      Application.put_env(:ref_inspector, :remote_urls, yaml_urls)
    end)
  end

  test "download with custom filename" do
    Mix.shell(Mix.Shell.IO)

    orig_path = Application.get_env(:ref_inspector, :database_path)
    test_file = Path.join([@test_path, @test_file])

    if File.exists?(test_file) do
      File.rm!(test_file)
    end

    console =
      capture_io(fn ->
        Application.put_env(:ref_inspector, :database_path, @test_path)
        Download.run(["--force"])
        Application.put_env(:ref_inspector, :database_path, orig_path)
      end)

    fixture_file = Path.join([@fixture_path, @fixture_file])

    assert File.exists?(test_file)
    assert String.contains?(console, test_file)
    assert File.stat!(test_file).size == File.stat!(fixture_file).size
  end
end
