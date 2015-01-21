defmodule RefInspector.DatabaseTest do
  use ExUnit.Case, async: true

  test "invalid file yields error" do
    assert { :error, _ } = RefInspector.load("--does-not-exist--")
  end
end
