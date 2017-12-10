defmodule RefInspector.Database.InitTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  setup do
    app_files = Application.get_env(:ref_inspector, :database_files)

    on_exit(fn ->
      Application.put_env(:ref_inspector, :database_files, app_files)
    end)
  end

  test "log info when initial load failed" do
    file = "something_that_is_no_file"

    Application.put_env(:ref_inspector, :database_files, [file])

    log =
      capture_log(fn ->
        RefInspector.Database.init(:ignored)
        :timer.sleep(100)
      end)

    assert log =~ ~r/invalid file.*#{file}/
  end
end
