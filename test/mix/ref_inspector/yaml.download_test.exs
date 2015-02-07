defmodule Mix.Tasks.RefInspector.Yaml.DownloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "forceable download" do
    Mix.shell(Mix.Shell.IO)

    orig_yaml = Application.get_env(:ref_inspector, :yaml)
    test_yaml = Path.join(__DIR__, "../../downloads/referers.yml")

    if File.exists?(test_yaml) do
      test_yaml |> File.rm!
    end

    console = capture_io fn ->
      Application.put_env(:ref_inspector, :yaml, test_yaml)
      Mix.Tasks.Ref_inspector.Yaml.Download.run(["--force"])
      Application.put_env(:ref_inspector, :yaml, orig_yaml)

      assert File.exists?(test_yaml)
    end

    assert String.contains?(console, test_yaml)
  end
end
