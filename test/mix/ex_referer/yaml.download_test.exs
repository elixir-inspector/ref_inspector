defmodule Mix.Tasks.ExAgent.Yaml.DownloadTest do
  use ExUnit.Case, async: false

  require Logger

  test "forceable download" do
    Mix.Tasks.Ex_referer.Yaml.Download.run(["--force"])

    Mix.ExReferer.local_yaml()
      |> Path.expand()
      |> File.exists?
      |> assert
  end
end
