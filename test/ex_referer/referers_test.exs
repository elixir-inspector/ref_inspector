defmodule ExReferer.ReferersTest do
  use ExUnit.Case, async: true

  test "invalid file yields error" do
    assert { :error, _ } = ExReferer.load_yaml("--does-not-exist--")
  end
end
