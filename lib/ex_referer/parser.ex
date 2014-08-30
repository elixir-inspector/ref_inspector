defmodule ExReferer.Parser do
  @moduledoc """
  Parser module.
  """

  @doc """
  Parses a given referer string.
  """
  @spec parse(String.t) :: map
  def parse(ref) do
    { medium, source, term } =
         ref
      |> URI.parse()
      |> parse_ref(ExReferer.Database.list)

    %{
      string: ref,
      medium: medium,
      source: source,
      term:   term
    }
  end

  defp parse_ref(ref, [ { _index, { medium, sources }} | referers]) do
    case parse_ref_medium(ref, medium, sources) do
      nil    -> parse_ref(ref, referers)
      parsed -> parsed
    end
  end
  defp parse_ref(_, []), do: { :unknown, :unknown, :none }

  defp parse_ref_medium(ref, medium, [{ source, details } | sources]) do
    case parse_ref_source(ref, source, details) do
      nil              -> parse_ref_medium(ref, medium, sources)
      { source, term } -> { String.to_atom(medium), source, term}
    end
  end
  defp parse_ref_medium(_, _, []), do: nil

  defp parse_ref_source(ref, source, details) do
    case parse_ref_domains(ref, source, details[:domains]) do
      nil    -> nil
      source ->
        query = case ref.query do
          nil   -> ""
          query -> query
        end

        { source,
          URI.decode_query(query) |> parse_ref_term(details[:parameters]) }
    end
  end

  defp parse_ref_domains(ref, source, [domain | domains]) do
    if domain == ref.host do
      source |> String.downcase()
    else
      parse_ref_domains(ref, source, domains)
    end
  end
  defp parse_ref_domains(_, _, []), do: nil

  defp parse_ref_term(query, [param | params]) do
    if Map.has_key?(query, param) do
      Map.get(query, param)
    else
      parse_ref_term(query, params)
    end
  end
  defp parse_ref_term(%{}, _), do: :none
end
