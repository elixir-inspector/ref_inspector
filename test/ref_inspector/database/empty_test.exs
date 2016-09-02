defmodule RefInspector.Database.EmptyTest do
  use ExUnit.Case, async: false

  @filename "empty.yml"

  setup do
    app_files = Application.get_env(:ref_inspector, :database_files)

    Application.put_env(:ref_inspector, :database_files, [ @filename ])

    on_exit fn ->
      Application.put_env(:ref_inspector, :database_files, app_files)
    end
  end

  test "empty files are ignored" do
    assert { :ok, _ } = RefInspector.Database.init(:ignored)
  end
end
