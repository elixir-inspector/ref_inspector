defmodule Mix.Tasks.ExReferer.Yaml.DownloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "forceable download" do
    Mix.shell(Mix.Shell.IO)

    console = capture_io fn ->
      Mix.Tasks.Ex_referer.Yaml.Download.run(["--force"])

      Mix.ExReferer.local_yaml()
        |> Path.expand()
        |> File.exists?
        |> assert
    end

    assert String.contains?(console, Mix.ExReferer.local_yaml)
  end
end
