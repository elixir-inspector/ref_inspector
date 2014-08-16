defmodule ExReferer.Database do
  @ets_table      :ex_referer
  @ets_table_refs :ex_referer_refs
  @ets_counter    :referers

  def init() do
    :ets.new(@ets_table,      [ :set,         :public, :named_table ])
    :ets.new(@ets_table_refs, [ :ordered_set, :public, :named_table ])

    :ets.insert(@ets_table, [{ @ets_counter, 0 }])
  end

  def terminate() do
    :ets.delete(@ets_table_refs)
    :ets.delete(@ets_table)
  end

  @doc """
  Returns all referer definitions.
  """
  @spec list() :: [ Atom.t ]
  def list(), do: :ets.tab2list(@ets_table_refs)

  @doc """
  Loads yaml file with referer definitions.
  """
  @spec load(String.t) :: :ok | { :error, String.t }
  def load(file) do
    if File.regular?(file) do
      parse_file(file)
    else
      { :error, "Invalid file given: '#{ file }'" }
    end
  end

  defp parse_file(file) do
    :yamerl_constr.file(file, [ :str_node_as_binary ])
      |> hd()
      |> parse_data()
  end

  defp parse_data([]), do: :ok
  defp parse_data([ { medium, sources } | datasets ]) do
    store_refs(medium, sources)
    parse_data(datasets)
  end

  defp store_refs(medium, sources) do
    sources = Enum.map(sources, fn ({ name, details }) ->
      details = Enum.map(details, fn({ key, values }) ->
        { String.to_atom(key), values }
      end)

      { name, details }
    end)

    store_ref({ medium, sources })
  end

  defp store_ref(ref) do
    :ets.insert_new(@ets_table_refs, { update_counter(), ref })
  end

  defp update_counter(), do: :ets.update_counter(@ets_table, @ets_counter, 1)
end
