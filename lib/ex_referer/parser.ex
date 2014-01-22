defmodule ExReferer.Parser do
  @doc """
  Parses a given referer string.
  """
  @spec parse(String.t) :: tuple
  def parse(ref) do
    Keyword.merge(
      [ string: ref, medium: :unknown, source: :unknown, term: :none ],
      ref |> URI.parse() |> parse_ref(ExReferer.Referers.get())
    )
  end

  defp parse_ref(_, []), do: []
  defp parse_ref(ref, [{ medium, sources } | referers]) do
    case parse_ref_medium(ref, medium, sources) do
      []     -> parse_ref(ref, referers)
      parsed -> parsed
    end
  end

  defp parse_ref_medium(_, _, []), do: []
  defp parse_ref_medium(ref, medium, [{ source, details } | sources]) do
    case parse_ref_source(ref, source, details) do
      []     -> parse_ref_medium(ref, medium, sources)
      parsed -> parsed |> Keyword.merge([ medium: medium |> binary_to_atom() ])
    end
  end

  defp parse_ref_source(ref, source, details) do
    case parse_ref_domains(ref, source, details["domains"]) do
      []     -> []
      parsed ->
        query = case ref.query do
          nil   -> ""
          query -> query
        end

        query
          |> URI.query_decoder()
          |> Enum.map( &(&1) )
          |> parse_ref_term(details["parameters"])
          |> Keyword.merge(parsed)
    end
  end

  defp parse_ref_domains(_, _, []), do: []
  defp parse_ref_domains(ref, source, [domain | domains]) do
    if domain == ref.host do
      [ source: source |> String.downcase() ]
    else
      parse_ref_domains(ref, source, domains)
    end
  end

  defp parse_ref_term(_, nil), do: []
  defp parse_ref_term(_, []),  do: []
  defp parse_ref_term(query, [param | params]) do
    if query[param] do
      [ term: query[param] ]
    else
      parse_ref_term(query, params)
    end
  end
end
