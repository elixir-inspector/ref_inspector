defmodule RefInspector.Deprecations.ReloadDatabaseTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "RefInspector.reload_databases/0 informs about rename" do
    log =
      capture_io(:user, fn ->
        RefInspector.reload_databases()

        :timer.sleep(100)
        Logger.flush()
      end)

    assert log =~ ~r(.+reload_databases/0.+renamed.+reload/0)
  end
end
