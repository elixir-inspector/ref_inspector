defmodule ExReferer.ReferersTest do
  use ExUnit.Case, async: false
  use ExReferer.TestHelper.Suite

  test "invalid file yields error" do
    assert { :error, _ } = ExReferer.load_yaml("--does-not-exist--")
  end
end
