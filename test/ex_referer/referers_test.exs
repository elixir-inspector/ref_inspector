defmodule ExReferer.ReferersTest do
  use ExReferer.TestHelper.Case, async: false

  test "invalid file yields error" do
    assert { :error, _ } = ExReferer.load_yaml("--does-not-exist--")
  end
end
