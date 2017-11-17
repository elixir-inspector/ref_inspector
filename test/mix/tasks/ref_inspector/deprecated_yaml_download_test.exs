defmodule Mix.Tasks.RefInspector.DeprecatedYamlDownloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias Mix.Tasks.RefInspector.Yaml.Download

  test "aborted download" do
    Mix.shell(Mix.Shell.IO)

    console =
      capture_io(fn ->
        Download.run([])
        IO.write("n")
      end)

    assert String.contains?(console, "renamed")
    assert String.contains?(console, "ref_inspector.download")
  end
end
