defmodule RefInspector.Parser do
  @moduledoc false

  alias RefInspector.Database
  alias RefInspector.Result

  @doc """
  Checks if a given URI struct is a known referer.
  """
  @spec parse(URI.t(), Keyword.t()) :: Result.t()
  def parse(%URI{host: nil}, _), do: %Result{}

  def parse(%URI{host: host, path: path, query: query}, opts) do
    if internal?(host, Application.get_env(:ref_inspector, :internal, [])) do
      %Result{medium: :internal}
    else
      %{
        host: host,
        host_parts: host |> String.split(".") |> Enum.reverse(),
        path: path || "/",
        query: query
      }
      |> parse_ref(Database.list(opts[:instance]))
    end
  end

  defp internal?(_, []), do: false

  defp internal?(host, [internal_host | internal_hosts]) do
    if host == internal_host || String.ends_with?(host, "." <> internal_host) do
      true
    else
      internal?(host, internal_hosts)
    end
  end

  defp maybe_parse_query(nil, _, result), do: result
  defp maybe_parse_query(_, [], result), do: result

  defp maybe_parse_query(query, params, result) do
    term =
      query
      |> URI.decode_query()
      |> parse_query(params)

    %{result | term: term}
  end

  defp match_sources(_, []), do: nil

  defp match_sources(
         %{host: ref_host, path: ref_path, query: query} = ref,
         [
           {src_host, src_subdomains, src_path, src_subpaths, src_parameters, src_medium,
            src_name}
           | sources
         ]
       ) do
    if (ref_host == src_host || String.ends_with?(ref_host, src_subdomains)) &&
         (ref_path == src_path || String.starts_with?(ref_path, src_subpaths)) do
      result = %Result{
        medium: src_medium,
        source: src_name
      }

      maybe_parse_query(query, src_parameters, result)
    else
      match_sources(ref, sources)
    end
  end

  defp parse_query(_, []), do: :none

  defp parse_query(query, [param | params]) do
    case query do
      %{^param => value} -> value
      _ -> parse_query(query, params)
    end
  end

  defp parse_ref(_, []), do: %Result{}

  defp parse_ref(%{host_parts: [first | _]} = ref, [{_database, entries} | referers]) do
    sources = Map.get(entries, first, [])

    case match_sources(ref, sources) do
      nil -> parse_ref(ref, referers)
      match -> match
    end
  end
end
