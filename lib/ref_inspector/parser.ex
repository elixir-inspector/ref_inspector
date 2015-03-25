defmodule RefInspector.Parser do
  @moduledoc """
  Parser module.
  """

  alias RefInspector.Result

  @doc """
  Parses a given referer string.
  """
  @spec parse(String.t) :: map
  def parse(ref) do
    { medium, source, term } =
         ref
      |> URI.parse()
      |> parse_ref(RefInspector.Database.list)

    %Result{
      referer: ref,
      medium:  medium,
      source:  source,
      term:    term
    }
  end


  defp matches_domain?(ref, domain) do
    String.ends_with?((ref.host || ""), domain[:host])
    && String.starts_with?((ref.path || "/"), domain[:path])
  end

  defp parse_ref(ref, [{ _index, { medium, sources }} | referers ]) do
    case parse_ref_medium(ref, medium, sources) do
      nil    -> parse_ref(ref, referers)
      parsed -> parsed
    end
  end
  defp parse_ref(_, []), do: { :unknown, :unknown, :none }

  defp parse_ref_medium(ref, medium, [ source | sources ]) do
    case parse_ref_source(ref, source[:name], source[:details]) do
      nil              -> parse_ref_medium(ref, medium, sources)
      { source, term } -> { String.to_atom(medium), source, term}
    end
  end
  defp parse_ref_medium(_, _, []), do: nil

  defp parse_ref_source(%{ query: ref_query } = ref, source, details) do
    case parse_ref_domains(ref, source, details[:domains]) do
      nil    -> nil
      source ->
        query = case ref_query do
          nil -> ""
          _   -> ref_query
        end

        { source,
          URI.decode_query(query) |> parse_ref_term(details[:parameters]) }
    end
  end

  defp parse_ref_domains(ref, source, [ domain | domains ]) do
    if matches_domain?(ref, domain) do
      source
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
