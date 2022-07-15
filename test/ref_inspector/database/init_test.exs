defmodule RefInspector.Database.InitTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias RefInspector.Database

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
        {Database, instance: :ref_inspector_init_test, startup_sync: false}
        |> start_supervised!()
        |> :sys.get_state()
      end)

    assert log =~ ~r/Failed to load #{file}: :enoent/
  end
end
