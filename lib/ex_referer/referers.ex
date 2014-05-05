defmodule ExReferer.Referers do
  referers_url = "https://raw.github.com/snowplow/referer-parser/master/resources/referers.yml"

  :ssl.start
  :inets.start

  headers = [ { 'user-agent', 'ExAgent/#{System.version}' } ]
  request = { :binary.bin_to_list(referers_url), headers }

  referers_yaml = case :httpc.request(:get, request, [], body_format: :binary) do
    { :ok, {{_, status, _}, _, body} } when status in 200..299 ->
      body
    { :ok, {{_, status, _}, _, _} } ->
      raise "Failed to download #{ referers_url }, status: #{ status }"
    { :error, reason } ->
      raise "Failed to download #{ referers_url }, error: #{ reason }"
  end

  :application.start(:yamerl)

  referers_list =
       referers_yaml
    |> :yamerl_constr.string([ :str_node_as_binary ])
    |> hd()

  referers = referers_list |> Enum.map(fn ({ type, sources }) ->
    sources = Enum.map(sources, fn ({ name, details }) ->
      details = Enum.map(details, fn({ key, values }) ->
        { binary_to_atom(key), values }
      end)

      { name, details }
    end)

    { type, sources }
  end)

  def get(), do: unquote(referers)
end
