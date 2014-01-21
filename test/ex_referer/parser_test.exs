defmodule ExReferer.ParserTest do
  use ExUnit.Case, async: true

  test "empty referer" do
    ref_info = "" |> ExReferer.parse()

    assert ref_info[:string] == ""
    assert ref_info[:medium] == :unknown
    assert ref_info[:source] == :unknown
    assert ref_info[:term]   == ""
  end

  test "completely unknown" do
    referer  = "http://i.will.not.be.found/"
    ref_info = referer |> ExReferer.parse()

    assert ref_info[:string] == referer
    assert ref_info[:medium] == :unknown
    assert ref_info[:source] == :unknown
    assert ref_info[:term]   == ""
  end

  test "no query" do
    referer  = "http://www.google.com/search"
    ref_info = referer |> ExReferer.parse()

    assert ref_info[:string] == referer
    assert ref_info[:medium] == :search
    assert ref_info[:source] == :google
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

  test "parameters less referer" do
    referer  = "https://twitter.com/elixirlang"
    ref_info = referer |> ExReferer.parse()

    assert ref_info[:string] == referer
    assert ref_info[:medium] == :social
    assert ref_info[:source] == :twitter
    assert ref_info[:term]   == ""
  end
end
