defmodule RefInspector.Database.Parser do
  @moduledoc """
  YAML database entry parser.
  """

  @doc """
  Parses a list of database entries and modifies them to be usable.
  """
  @spec parse(list) :: list
  def parse(entries), do: parse([], entries)

  defp parse(acc, []), do: Enum.reverse(acc)

  defp parse(acc, [{medium, sources} | entries]) do
    sources =
      sources
      |> parse_sources([])
      |> sort_sources()

    parse([{medium, sources}] ++ acc, entries)
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

  defp sort_sources(sources) do
    sources
    |> Enum.map(&Map.put(&1, :sort, "#{&1.host}#{&1.path}"))
    |> Enum.sort(&(String.length(&1[:sort]) > String.length(&2[:sort])))
    |> Enum.uniq_by(& &1[:sort])
    |> Enum.map(&Map.delete(&1, :sort))
  end
end
