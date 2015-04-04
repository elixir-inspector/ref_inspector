defmodule Mix.Tasks.RefInspector.Yaml.DownloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "aborted download" do
    Mix.shell(Mix.Shell.IO)

    console = capture_io fn ->
      Mix.Tasks.RefInspector.Yaml.Download.run([])

      IO.write "n"
    end

    assert String.contains?(console, "Download aborted")
  end

  test "confirmed download" do
    Mix.shell(Mix.Shell.IO)

    console = capture_io [capture_prompt: true], fn ->
      Mix.Tasks.RefInspector.Yaml.Download.run([])
    end

    assert String.contains?(console, "Download referers.yml? [Yn]")
  end

  test "forceable download" do
    Mix.shell(Mix.Shell.IO)

    orig_yaml = Application.get_env(:ref_inspector, :yaml)
    test_yaml = Path.join(__DIR__, "../../downloads/referers.yml") |> Path.expand()

    if File.exists?(test_yaml) do
      test_yaml |> File.rm!
    end

    console = capture_io fn ->
      Application.put_env(:ref_inspector, :yaml, test_yaml)
      Mix.Tasks.RefInspector.Yaml.Download.run(["--force"])
      Application.put_env(:ref_inspector, :yaml, orig_yaml)

      assert File.exists?(test_yaml)
    end

    assert String.contains?(console, test_yaml)
  end

  test "missing configuration" do
    Mix.shell(Mix.Shell.IO)

    orig_yaml = Application.get_env(:ref_inspector, :yaml)

    console = capture_io :stderr, fn ->
      Application.put_env(:ref_inspector, :yaml, nil)
      Mix.Tasks.RefInspector.Yaml.Download.run([])
      Application.put_env(:ref_inspector, :yaml, orig_yaml)
    end

    assert String.contains?(console, "not configured")
  end
end
