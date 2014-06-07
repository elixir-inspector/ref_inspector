defmodule ExReferer.Referers do
  @doc """
  Returns all referer definitions.
  """
  @spec get() :: [ Atom.t ]
  def get(), do: :ets.tab2list(:ex_referer_ref)

  @doc """
  Loads yaml file with referer definitions.
  """
  @spec load_yaml(String.t) :: :ok | { :error, String.t }
  def load_yaml(file) do
    if File.regular?(file) do
      parse_yaml_file(file)
    else
      { :error, "Invalid file given: '#{ file }'" }
    end
  end

  defp parse_yaml_file(file) do
    :yamerl_constr.file(file, [ :str_node_as_binary ])
      |> hd()
      |> parse_yaml_data()
  end

  defp parse_yaml_data([]), do: :ok
  defp parse_yaml_data([ { medium, sources } | datasets ]) do
    store_refs(medium, sources)
    parse_yaml_data(datasets)
  end

  defp store_refs(medium, sources) do
    sources = Enum.map(sources, fn ({ name, details }) ->
      details = Enum.map(details, fn({ key, values }) ->
        { binary_to_atom(key), values }
      end)

      { name, details }
    end)

    store_ref({ medium, sources })
  end

  defp store_ref(ref) do
    :ets.insert_new(
      :ex_referer_ref,
      { :ets.update_counter(:ex_referer, :ref_count, 1), ref }
    )
  end
end
