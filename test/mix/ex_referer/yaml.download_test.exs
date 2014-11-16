defmodule Mix.Tasks.ExAgent.Yaml.DownloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  require Logger

  test "forceable download" do
    Mix.Tasks.ExRefererYaml.Download.run(["--force"])

    Mix.ExReferer.local_yaml()
      |> Path.expand()
      |> File.exists?
      |> assert
    end
  end
end
