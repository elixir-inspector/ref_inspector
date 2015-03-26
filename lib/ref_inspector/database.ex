defmodule RefInspector.Database do
  @moduledoc """
  Referer database.
  """

  use GenServer

  @ets_table      :ref_inspector
  @ets_table_refs :ref_inspector_refs
  @ets_counter    :referers


  # GenServer lifecycle

  @doc """
  Starts the database server.
  """
  @spec start_link(any) :: GenServer.on_start
  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, [ name: __MODULE__ ])
  end

  def init(_) do
    _tid = :ets.new(@ets_table,      [ :set,         :protected, :named_table ])
    _tid = :ets.new(@ets_table_refs, [ :ordered_set, :protected, :named_table ])

    :ets.insert(@ets_table, [{ @ets_counter, 0 }])

    { :ok, [] }
  end


  # GenServer callbacks

  def handle_call({ :load, file }, _from, state) do
    { :reply, load_file(file), state }
  end


  # Convenience methods

  @doc """
  Returns all referer definitions.
  """
  @spec list() :: list
  def list(), do: :ets.tab2list(@ets_table_refs)

  @doc """
  Loads a referer database file.
  """
  @spec load(String.t) :: :ok | { :error, String.t }
  def load(nil),  do: :ok
  def load(file), do: GenServer.call(__MODULE__, { :load, file })


  # Internal methods

  defp load_file(file) do
    if File.regular?(file) do
      parse_file(file)
    else
      { :error, "Invalid file given: '#{ file }'" }
    end
  end

  defp parse_file(file) do
    :yamerl_constr.file(file, [ :str_node_as_binary ])
      |> hd()
      |> parse_entries()
  end

  defp parse_entries([]),                              do: :ok
  defp parse_entries([{ medium, sources } | entries ]) do
    sources
    |> parse_sources([])
    |> sort_sources()
    |> store_ref(medium)

    parse_entries(entries)
  end

  defp store_ref(sources, medium) do
    medium  = String.to_atom(medium)
    dataset = { medium, sources }

    :ets.insert_new(@ets_table_refs, { update_counter(), dataset })
  end

  defp update_counter(), do: :ets.update_counter(@ets_table, @ets_counter, 1)


  # Parsing and sorting methods

  defp parse_domains(_,      [],                   acc), do: acc
  defp parse_domains(source, [ domain | domains ], acc)  do
    uri  = URI.parse("http://#{ domain }")
    data =
         source
      |> Map.put(:host, uri.host)
      |> Map.put(:path, uri.path || "/")

    parse_domains(source, domains, acc ++ [ data ])
  end

  defp parse_sources([],                             acc), do: acc
  defp parse_sources([{ name, details } | sources ], acc)  do
    details    = details |> Enum.into(%{})
    domains    = Map.get(details, "domains", [])
    parameters = Map.get(details, "parameters", [])

    source = %{ name: name, parameters: parameters }
    acc    = acc ++ parse_domains(source, domains, [])

    parse_sources(sources, acc)
  end

  defp sort_sources(sources) do
    sources
    |> Enum.map( &Map.put(&1, :sort, "#{ &1.host }#{ &1.path }") )
    |> Enum.sort( &(String.length(&1[:sort]) > String.length(&2[:sort])) )
    |> Enum.uniq( &(&1[:sort]) )
    |> Enum.map( &Map.delete(&1, :sort) )
  end
end
