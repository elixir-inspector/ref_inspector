defmodule RefInspector.Database.EmptyTest do
  use ExUnit.Case, async: false

  alias RefInspector.Database
  alias RefInspector.Database.State

  setup do
    app_files = Application.get_env(:ref_inspector, :database_files)

    on_exit(fn ->
      Application.put_env(:ref_inspector, :database_files, app_files)
    end)
  end

  test "empty files are ignored" do
    Application.put_env(:ref_inspector, :database_files, ["empty.yml"])

    state = %State{database: :ignored, startup_sync: false}

    assert {:ok, _} = Database.init(state)
  end
end
