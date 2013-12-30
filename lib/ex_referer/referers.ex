defmodule ExReferer.Referers do
  referers_url = "https://raw.github.com/snowplow/referer-parser/master/resources/referers.yml"

  HTTPotion.start
  HTTPotion.Response[body: referers_yaml] = referers_url |> HTTPotion.get()

  unless nil == referers_yaml do
    referers = case :yaml.load(referers_yaml) do
      { :ok, referers } -> referers
      { :error, err }  ->
        IO.puts "Failed to parse referers.yaml: " <> inspect(err)
        nil
    end
  end

  if nil == referers do
    def get() do
      IO.puts "Failed to parse referers.yaml"
      nil
    end
  else
    def get(), do: unquote(referers)
  end
end
