defmodule RefInspector.Deprecations.SingleRemoteCOnfigTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias RefInspector.Config


  setup_all do
    remote_urls = Application.get_env(:ref_inspector, :remote_urls)

    Application.put_env(:ref_inspector, :remote_urls, nil)
    Application.put_env(:ref_inspector, :remote_url, "http://localhost/file.yml")

    on_exit fn ->
      Application.put_env(:ref_inspector, :remote_urls, remote_urls)

      Application.delete_env(:ref_inspector, :remote_url)
    end
  end


  test "single remote url" do
    stderr = capture_io :stderr, fn ->
      Config.yaml_urls
    end

    assert String.contains?(stderr, "deprecated")
  end
end
