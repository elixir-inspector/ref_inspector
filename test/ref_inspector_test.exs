defmodule RefInspectorTest do
  use ExUnit.Case, async: true

  test "unconfigured database path" do
    assert :ok == RefInspector.load(nil)
  end
end
