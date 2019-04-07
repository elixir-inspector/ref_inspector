defmodule RefInspector.Benchmark.Parse do
  @uri_email "http://co106w.col106.mail.live.com/default.aspx?rru=inbox"
  @uri_search "http://www.google.com/search?q=gateway+oracle+cards+denise+linn&hl=en&client=safari"
  @uri_social "http://www.facebook.com/l.php?u=http%3A%2F%2Fwww.psychicbazaar.com&h=yAQHZtXxS&s=1"

  def run do
    Benchee.run(
      %{
        "Parse: email" => fn -> RefInspector.parse(@uri_email) end,
        "Parse: search" => fn -> RefInspector.parse(@uri_search) end,
        "Parse: social" => fn -> RefInspector.parse(@uri_social) end
      },
      formatters: [{Benchee.Formatters.Console, comparison: false}],
      warmup: 2,
      time: 10
    )
  end
end

RefInspector.Benchmark.Parse.run()
