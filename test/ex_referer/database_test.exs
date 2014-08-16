defmodule ExReferer.DatabaseTest do
  use ExUnit.Case, async: true

  test "invalid file yields error" do
    assert { :error, _ } = ExReferer.load("--does-not-exist--")
  end
end
