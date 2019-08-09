defmodule RefInspector.Database.EmptyTest do
  use ExUnit.Case, async: false

  alias RefInspector.Database
  alias RefInspector.Database.State

  setup do
    app_files = Application.get_env(:ref_inspector, :database_files)
    startup = Application.get_env(:ref_inspector, :startup_sync)

    on_exit(fn ->
      Application.put_env(:ref_inspector, :database_files, app_files)
      Application.put_env(:ref_inspector, :startup_sync, startup)
    end)
  end

  test "empty files are ignored" do
    Application.put_env(:ref_inspector, :database_files, ["empty.yml"])
    Application.put_env(:ref_inspector, :startup_sync, false)

    assert {:ok, _} = Database.init(%State{instance: :ignored})
  end
end
