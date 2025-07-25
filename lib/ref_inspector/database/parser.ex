defmodule RefInspector.Database.Parser do
  @moduledoc false

  @doc """
  Parses a list of database entries and modifies them to be usable.
  """
  @spec parse(list) :: map
  def parse(entries) do
    entries
    |> parse([])
    |> Enum.reduce(%{}, &reduce_database/2)
  end

  defp parse([], acc), do: acc

  defp parse([{medium, sources} | entries], acc) do
    sources =
      sources
      |> parse_sources([])
      |> Enum.map(&Map.put(&1, :medium, medium))

    parse(entries, sources ++ acc)
  end

  defp parse_domains(_, [], acc), do: acc

  defp parse_domains(source, [domain | domains], acc) do
    uri = URI.parse("http://#{domain}")

    data =
      source
      |> Map.put(:host, uri.host)
      |> Map.put(:host_parts, uri.host |> String.split(".") |> Enum.reverse())
      |> Map.put(:path, uri.path || "/")

    parse_domains(source, domains, acc ++ [data])
  end

  defp parse_sources([], acc), do: acc

  defp parse_sources([{name, details} | sources], acc) do
    details = Enum.into(details, %{})
    domains = Map.get(details, "domains", [])
    parameters = Map.get(details, "parameters", [])

    source = %{name: name, parameters: parameters}
    acc = acc ++ parse_domains(source, domains, [])

    parse_sources(sources, acc)
  end

  defp reduce_database(source, red_acc) do
    %{
      host: host,
      host_parts: [last_part | _],
      medium: medium,
      name: name,
      parameters: parameters,
      path: path
    } = source

    part_acc = red_acc[last_part] || []

    entry = {
      host,
      "." <> String.trim_leading(host, "."),
      path,
      String.trim_trailing(path, "/") <> "/",
      parameters,
      medium,
      name
    }

    Map.put(red_acc, last_part, [entry | part_acc])
  end
end
