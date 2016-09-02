defmodule RefInspector.Database.EmptyTest do
  use ExUnit.Case, async: false

  @filename Path.join([ __DIR__, "../../fixtures/empty.yml" ])

  setup do
    app_path = Application.get_env(:ref_inspector, :yaml)

    Application.put_env(:ref_inspector, :yaml, @filename)

    on_exit fn ->
      Application.put_env(:ref_inspector, :yaml, app_path)
    end
  end

  test "empty files are ignored" do
    assert { :ok, _ } = RefInspector.Database.init(:ignored)
  end
end
