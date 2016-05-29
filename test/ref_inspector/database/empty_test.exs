defmodule RefInspector.Database.EmptyTest do
  use ExUnit.Case, async: false

  setup do
    on_exit fn ->
      :ref_inspector
      |> Application.get_env(:yaml)
      |> RefInspector.Database.load()
    end
  end

  test "empty files are ignored" do
    empty = Path.join(__DIR__, "../../fixtures/empty.yml")

    assert :ok == RefInspector.Database.load(empty)
  end
end
