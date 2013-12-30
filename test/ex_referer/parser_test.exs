defmodule ExReferer.ParserTest do
  use ExUnit.Case, async: true

  test "retain unparsed referer" do
    assert ExReferer.parse("http://www.example.dom/?q=search")[:string] == "http://www.example.dom/?q=search"
  end

  test "completely unknown" do
    referer = ExReferer.parse("http://i.will.not.be.found/")

    assert referer[:medium] == :unknown
    assert referer[:source] == :unknown
    assert referer[:term]   == ""
  end

  test "google search" do
    referer = ExReferer.parse("http://www.google.com/search?q=snowplow+referer+parser&hl=en&client=chrome")

    assert referer[:medium] == :search
    assert referer[:source] == :google
    assert referer[:term]   == "snowplow referer parser"
  end

  test "google empty search" do
    referer = ExReferer.parse("http://www.google.com/search?q=&hl=en&client=chrome")

    assert referer[:medium] == :search
    assert referer[:source] == :google
    assert referer[:term]   == ""
  end
end
