defmodule RefInspector.Database.InitTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  @filename "something_that_is_no_file"

  setup do
    app_path = Application.get_env(:ref_inspector, :yaml)

    Application.put_env(:ref_inspector, :yaml, @filename)

    on_exit fn ->
      Application.put_env(:ref_inspector, :yaml, app_path)
    end
  end

  test "log info when initial load failed" do
    log = capture_io :user, fn ->
      RefInspector.Database.init(:ignored)
      Logger.flush()
    end

    assert String.contains?(log, "invalid file")
    assert String.contains?(log, @filename)
  end
end
