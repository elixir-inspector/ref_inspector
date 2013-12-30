defmodule ExReferer.ParserTest do
  use ExUnit.Case, async: true

  test "retain unparsed referer" do
    assert ExReferer.parse("http://www.example.dom/?q=search")[:string] == "http://www.example.dom/?q=search"
  end
end
