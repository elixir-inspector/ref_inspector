defmodule RefInspector.Database do
  @moduledoc """
  Referer database.
  """

  use GenServer

  require Logger

  alias RefInspector.Config
  alias RefInspector.Database.Loader
  alias RefInspector.Database.Parser
  alias RefInspector.Database.State

  @drop_delay 30_000
  @lookup_table :ref_inspector

  # GenServer lifecycle

  @doc """
  Starts the database server.
  """
  @spec start_link() :: GenServer.on_start()
  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    :ok = GenServer.cast(__MODULE__, :reload)

    {:ok, %State{}}
  end

  # GenServer callbacks

  def handle_cast(:reload, %State{ets_tid: old_ets_tid}) do
    :ok = create_lookup_table()
    state = %State{ets_tid: create_data_table()}

    database_files = Config.database_files()
    database_path = Config.database_path()

    :ok = do_reload(database_files, database_path, state.ets_tid)
    _ = Process.send_after(self(), {:drop_data_table, old_ets_tid}, @drop_delay)
    true = :ets.insert(@lookup_table, {@lookup_table, state.ets_tid})

    {:noreply, state}
  end

  def handle_info({:drop_data_table, nil}, state), do: {:noreply, state}

  def handle_info({:drop_data_table, ets_tid}, state) do
    case state.ets_tid == ets_tid do
      true ->
        # ignore call!
        {:noreply, state}

      false ->
        :ok = drop_data_table(ets_tid)
        {:noreply, state}
    end
  end

  # Convenience methods

  @doc """
  Returns all referer definitions.
  """
  @spec list() :: [tuple]
  def list() do
    case :ets.info(@lookup_table) do
      :undefined ->
        []

      _ ->
        case :ets.lookup(@lookup_table, @lookup_table) do
          [{@lookup_table, ets_tid}] ->
            :ets.tab2list(ets_tid)

          _ ->
            []
        end
    end
  end

  @doc """
  Reloads all databases.
  """
  @spec reload() :: :ok
  def reload(), do: GenServer.cast(__MODULE__, :reload)

  # Internal methods

  defp create_data_table() do
    ets_name = :ref_inspector_data
    ets_opts = [:protected, :ordered_set, read_concurrency: true]

    :ets.new(ets_name, ets_opts)
  end

  defp create_lookup_table() do
    ets_name = :ref_inspector
    ets_opts = [:named_table, :protected, :set, read_concurrency: true]

    case :ets.info(ets_name) do
      :undefined ->
        _ = :ets.new(ets_name, ets_opts)
        :ok

      _ ->
        :ok
    end
  end

  defp do_reload([], _, _ets_tid) do
    Logger.warn("Reload error: no database files configured!")
    :ok
  end

  defp do_reload(_, nil, _ets_tid) do
    Logger.warn("Reload error: no database path configured!")
    :ok
  end

  defp do_reload(files, path, ets_tid) do
    _ =
      Enum.reduce(files, 0, fn file, acc_index ->
        database = Path.join([path, file])

        case Loader.load(database) do
          {:error, reason} ->
            Logger.info(reason)
            acc_index

          entries when is_list(entries) ->
            entries
            |> Parser.parse()
            |> store_refs(ets_tid, acc_index)
        end
      end)

    :ok
  end

  defp drop_data_table(ets_tid) do
    true =
      case :ets.info(ets_tid) do
        :undefined -> true
        _ -> :ets.delete(ets_tid)
      end

    :ok
  end

  defp store_refs([], _ets_tid, index), do: index

  defp store_refs([{medium, sources} | refs], ets_tid, index) do
    medium = String.to_atom(medium)
    dataset = {index, medium, sources}

    :ets.insert_new(ets_tid, dataset)
    store_refs(refs, ets_tid, index + 1)
  end
end
