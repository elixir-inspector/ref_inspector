defmodule Mix.Tasks.RefInspector.Yaml.DownloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "forceable download" do
    Mix.shell(Mix.Shell.IO)

    console = capture_io fn ->
      Mix.Tasks.Ref_inspector.Yaml.Download.run(["--force"])

      Mix.RefInspector.local_yaml()
        |> Path.expand()
        |> File.exists?
        |> assert
    end

    assert String.contains?(console, Mix.RefInspector.local_yaml)
  end
end
