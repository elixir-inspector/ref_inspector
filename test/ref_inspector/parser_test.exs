defmodule RefInspector.ParserTest do
  use ExUnit.Case, async: true

  alias RefInspector.Result

  test "empty referer" do
    assert %Result{} == RefInspector.parse(nil)
    assert %Result{} == RefInspector.parse("")
  end

  test "URI struct referer" do
    referer = "http://does.not/matter"
    uri = URI.parse(referer)

    assert %Result{referer: referer} == RefInspector.parse(uri)
  end

  test "completely unknown" do
    referer = "http://i.will.not.be.found/"
    parsed = %Result{referer: referer}

    assert parsed == RefInspector.parse(referer)
  end

  test "internal referer" do
    referer = "http://www.example.com/sub-page"
    parsed = %Result{referer: referer, medium: :internal}

    assert parsed == RefInspector.parse(referer)
  end

  test "internal referer (subdomain)" do
    referer = "http://some.subdomain.from.www.example.org/"
    parsed = %Result{referer: referer, medium: :internal}

    assert parsed == RefInspector.parse(referer)
  end

  test "no query" do
    referer = "http://www.google.fr/imgres?ignored=parameters"

    parsed = %Result{
      referer: referer,
      medium: :search,
      source: "Google Images"
    }

    assert parsed == RefInspector.parse(referer)
  end

  test "google search" do
    referer = "http://www.google.com/search?q=snowplow+referer+parser&hl=en&client=chrome"

    parsed = %Result{
      referer: referer,
      medium: :search,
      source: "Google",
      term: "snowplow referer parser"
    }

    assert parsed == RefInspector.parse(referer)
  end

  test "google empty search" do
    referer = "http://www.google.com/search?q=&hl=en&client=chrome"

    parsed = %Result{
      referer: referer,
      medium: :search,
      source: "Google",
      term: ""
    }

    assert parsed == RefInspector.parse(referer)
  end

  test "referer without parameters" do
    referer = "https://twitter.com/elixirlang"

    parsed = %Result{
      referer: referer,
      medium: :social,
      source: "Twitter"
    }

    assert parsed == RefInspector.parse(referer)
  end

  test "referer without defined parameters" do
    referer = "https://twitter.com/elixirlang?nothing=defined"

    parsed = %Result{
      referer: referer,
      medium: :social,
      source: "Twitter"
    }

    assert parsed == RefInspector.parse(referer)
  end
end
