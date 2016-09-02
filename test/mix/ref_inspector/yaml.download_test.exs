defmodule Mix.RefInspector.Yaml.DownloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO


  setup_all do
    # setup internal testing webserver
    Application.ensure_all_started(:inets)

    fixture_path       = Path.join([ __DIR__, '../../fixtures' ]) |> Path.expand()
    httpd_opts         = [ port:          0,
                           server_name:   'ref_inspector_test',
                           server_root:   fixture_path |> to_char_list,
                           document_root: fixture_path |> to_char_list ]
    { :ok, httpd_pid } = :inets.start(:httpd, httpd_opts)

    # configure app to use testing webserver
    yaml_url = Application.get_env(:ref_inspector, :remote_url)
    :ok      = Application.put_env(
      :ref_inspector,
      :remote_url,
      "http://localhost:#{ :httpd.info(httpd_pid)[:port] }/referers.yml"
    )

    on_exit fn ->
      Application.put_env(:ref_inspector, :remote_url, yaml_url)
    end
  end


  test "aborted download" do
    Mix.shell(Mix.Shell.IO)

    console = capture_io fn ->
      Mix.RefInspector.Yaml.Download.run([])

      IO.write "n"
    end

    assert String.contains?(console, "Download aborted")
  end

  test "confirmed download" do
    Mix.shell(Mix.Shell.IO)

    console = capture_io [capture_prompt: true], fn ->
      Mix.RefInspector.Yaml.Download.run([])
    end

    assert String.contains?(console, "Download referers.yml? [Yn]")
  end

  test "forceable download" do
    Mix.shell(Mix.Shell.IO)

    orig_path = Application.get_env(:ref_inspector, :database_path)
    test_path = Path.join([ __DIR__, "../../downloads" ]) |> Path.expand()
    test_file = Path.join([ test_path, "referers.yml" ])

    if File.exists?(test_file) do
      test_file |> File.rm!
    end

    console = capture_io fn ->
      Application.put_env(:ref_inspector, :database_path, test_path)
      Mix.RefInspector.Yaml.Download.run(["--force"])
      Application.put_env(:ref_inspector, :database_path, orig_path)

      assert File.exists?(test_file)
    end

    assert String.contains?(console, test_file)
  end

  test "missing configuration" do
    Mix.shell(Mix.Shell.IO)

    orig_path = Application.get_env(:ref_inspector, :database_path)

    console = capture_io :stderr, fn ->
      Application.put_env(:ref_inspector, :database_path, nil)
      Mix.RefInspector.Yaml.Download.run([])
      Application.put_env(:ref_inspector, :database_path, orig_path)
    end

    assert String.contains?(console, "not configured")
  end
end
