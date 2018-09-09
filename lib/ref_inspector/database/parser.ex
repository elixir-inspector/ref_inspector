defmodule RefInspector.Database.Parser do
  @moduledoc false

  @doc """
  Parses a list of database entries and modifies them to be usable.
  """
  @spec parse(list) :: list
  def parse(entries), do: parse([], entries)

  defp parse(acc, []) do
    Enum.reduce(acc, %{}, fn source, red_acc ->
      last_part = List.first(source[:host_parts])
      part_acc = red_acc[last_part] || []

      Map.put(red_acc, last_part, [source | part_acc])
    end)
  end

  defp parse(acc, [{medium, sources} | entries]) do
    sources =
      sources
      |> parse_sources([])
      |> Enum.map(&Map.put(&1, :medium, String.to_atom(medium)))

    parse(sources ++ acc, entries)
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
    details = details |> Enum.into(%{})
    domains = Map.get(details, "domains", [])
    parameters = Map.get(details, "parameters", [])

    source = %{name: name, parameters: parameters}
    acc = acc ++ parse_domains(source, domains, [])

    parse_sources(sources, acc)
  end
end
