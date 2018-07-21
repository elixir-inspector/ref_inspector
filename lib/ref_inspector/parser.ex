defmodule RefInspector.Parser do
  @moduledoc """
  Parser module.
  """

  alias RefInspector.Database
  alias RefInspector.Result

  @doc """
  Parses a given referer string.
  """
  @spec parse(String.t()) :: map
  def parse(ref) do
    ref
    |> URI.parse()
    |> do_parse()
    |> Map.put(:referer, ref)
  end

  # Internal methods

  defp do_parse(%{host: nil}), do: %Result{}

  defp do_parse(%{host: host} = uri) do
    case is_internal?(host) do
      true ->
        %Result{medium: :internal}

      false ->
        uri
        |> Map.from_struct()
        |> Map.put(:host_parts, uri.host |> String.split(".") |> Enum.reverse())
        |> Map.put(:path, uri.path || "/")
        |> parse_ref(Database.list())
    end
  end

  defp is_internal?(host) do
    sources = Application.get_env(:ref_inspector, :internal, [])

    String.ends_with?(host, sources)
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

  defp match_medium(_, {_, []}), do: nil

  defp match_medium(ref, {medium, [source | sources]}) do
    case matches_source?(ref, source) do
      false ->
        match_medium(ref, {medium, sources})

      true ->
        result = %Result{
          medium: medium,
          source: source.name
        }

        maybe_parse_query(ref.query, source[:parameters], result)
    end
  end

  defp matches_source?(
         %{host: ref_host, host_parts: [first | _], path: ref_path},
         %{host: src_host, host_parts: [first | _], path: src_path}
       ) do
    String.ends_with?(ref_host, src_host) && String.starts_with?(ref_path, src_path)
  end

  defp matches_source?(_, _), do: false

  defp parse_query(_, []), do: :none

  defp parse_query(query, [param | params]) do
    Map.get(query, param, parse_query(query, params))
  end

  defp parse_ref(_, []), do: %Result{}

  defp parse_ref(ref, [medium | referers]) do
    case match_medium(ref, medium) do
      nil -> parse_ref(ref, referers)
      match -> match
    end
  end
end
