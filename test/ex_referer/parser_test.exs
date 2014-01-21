defmodule ExReferer.ParserTest do
  use ExUnit.Case, async: true

  test "completely unknown" do
    referer  = "http://i.will.not.be.found/"
    ref_info = referer |> ExReferer.parse()

    assert ref_info[:string] == referer
    assert ref_info[:medium] == :unknown
    assert ref_info[:source] == :unknown
    assert ref_info[:term]   == ""
  end

  test "google search" do
    referer  = "http://www.google.com/search?q=snowplow+referer+parser&hl=en&client=chrome"
    ref_info = referer |> ExReferer.parse()

    assert ref_info[:string] == referer
    assert ref_info[:medium] == :search
    assert ref_info[:source] == :google
    assert ref_info[:term]   == "snowplow referer parser"
  end

  test "google empty search" do
    referer  = "http://www.google.com/search?q=&hl=en&client=chrome"
    ref_info = referer |> ExReferer.parse()

    assert ref_info[:string] == referer
    assert ref_info[:medium] == :search
    assert ref_info[:source] == :google
    assert ref_info[:term]   == ""
  end
end
