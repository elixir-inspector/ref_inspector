defmodule ExReferer.ParserTest do
  use ExReferer.TestHelper.Case, async: false

  test "empty referer" do
    empty = %ExReferer.Response{
      string: "",
      medium: :unknown,
      source: :unknown,
      term:   :none
    }

    assert ExReferer.parse("") == empty
  end

  test "completely unknown" do
    referer  = "http://i.will.not.be.found/"
    response = %ExReferer.Response{
      string: referer,
      medium: :unknown,
      source: :unknown,
      term:   :none
    }

    assert ExReferer.parse(referer) == response
  end

  test "no query" do
    referer  = "http://www.google.com/search"
    response = %ExReferer.Response{
      string: referer,
      medium: :search,
      source: "google",
      term:   :none
    }

    assert ExReferer.parse(referer) == response
  end

  test "google search" do
    referer  = "http://www.google.com/search?q=snowplow+referer+parser&hl=en&client=chrome"
    response = %ExReferer.Response{
      string: referer,
      medium: :search,
      source: "google",
      term:   "snowplow referer parser"
    }

    assert ExReferer.parse(referer) == response
  end

  test "google empty search" do
    referer  = "http://www.google.com/search?q=&hl=en&client=chrome"
    response = %ExReferer.Response{
      string: referer,
      medium: :search,
      source: "google",
      term:   ""
    }

    assert ExReferer.parse(referer) == response
  end

  test "parameters less referer" do
    referer  = "https://twitter.com/elixirlang"
    response = %ExReferer.Response{
      string: referer,
      medium: :social,
      source: "twitter",
      term:   :none
    }

    assert ExReferer.parse(referer) == response
  end
end
