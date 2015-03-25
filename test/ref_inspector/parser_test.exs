defmodule RefInspector.ParserTest do
  use ExUnit.Case, async: true

  alias RefInspector.Result

  test "empty referer" do
    assert %Result{} == RefInspector.parse("")
  end

  test "completely unknown" do
    referer = "http://i.will.not.be.found/"
    parsed  = %Result{ referer: referer }

    assert parsed == RefInspector.parse(referer)
  end

  test "no query" do
    referer = "http://www.google.fr/imgres?ignored=parameters"
    parsed  = %Result{
      referer: referer,
      medium:  :search,
      source:  "Google Images"
    }

    assert parsed == RefInspector.parse(referer)
  end

  test "google search" do
    referer = "http://www.google.com/search?q=snowplow+referer+parser&hl=en&client=chrome"
    parsed = %Result{
      referer: referer,
      medium:  :search,
      source:  "Google",
      term:    "snowplow referer parser"
    }

    assert parsed == RefInspector.parse(referer)
  end

  test "google empty search" do
    referer = "http://www.google.com/search?q=&hl=en&client=chrome"
    parsed  = %Result{
      referer: referer,
      medium:  :search,
      source:  "Google",
      term:    ""
    }

    assert parsed == RefInspector.parse(referer)
  end

  test "parameters less referer" do
    referer = "https://twitter.com/elixirlang"
    parsed  = %Result{
      referer: referer,
      medium:  :social,
      source:  "Twitter"
    }

    assert parsed == RefInspector.parse(referer)
  end
end
