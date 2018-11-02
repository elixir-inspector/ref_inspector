defmodule RefInspector.Database do
  @moduledoc false

  use GenServer

  require Logger

  alias RefInspector.Config
  alias RefInspector.Database.Loader
  alias RefInspector.Database.Parser

  @ets_cleanup_delay_default 30_000
  @ets_data_table_name :ref_inspector_data
  @ets_data_table_opts [:protected, :ordered_set, read_concurrency: true]
  @ets_lookup_table_name :ref_inspector_lookup
  @ets_lookup_table_opts [:named_table, :protected, :set, read_concurrency: true]

  # GenServer lifecycle

  @doc """
  Starts the database server.
  """
  @spec start_link(term) :: GenServer.on_start()
  def start_link(default \\ nil) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(state) do
    :ok = GenServer.cast(__MODULE__, :reload)

    {:ok, state}
  end

  # GenServer callbacks

  def handle_cast(:reload, state) do
    :ok = create_lookup_table()
    old_ets_tid = fetch_data_table()
    new_ets_tid = create_data_table()

    database_files = Config.database_files()
    database_path = Config.database_path()

    :ok = do_reload(database_files, database_path, new_ets_tid)

    :ok = schedule_data_cleanup(old_ets_tid)
    true = :ets.insert(@ets_lookup_table_name, {@ets_data_table_name, new_ets_tid})

    {:noreply, state}
  end

  def handle_info({:drop_data_table, nil}, state), do: {:noreply, state}

  def handle_info({:drop_data_table, ets_tid}, state) do
    :ok = drop_data_table(ets_tid)

    {:noreply, state}
  end

  # Convenience methods

  @doc """
  Returns all referer definitions.
  """
  @spec list() :: [tuple]
  def list() do
    case fetch_data_table() do
      nil -> []
      ets_tid -> :ets.tab2list(ets_tid)
    end
  end

  # Internal methods

  defp create_data_table() do
    :ets.new(@ets_data_table_name, @ets_data_table_opts)
  end

  defp create_lookup_table() do
    case :ets.info(@ets_lookup_table_name) do
      :undefined ->
        _ = :ets.new(@ets_lookup_table_name, @ets_lookup_table_opts)
        :ok

      _ ->
        :ok
    end
  end

  defp do_reload([], _, _ets_tid) do
    Logger.warn("Reload error: no database files configured!")
    :ok
  end

  defp do_reload(files, path, ets_tid) do
    Enum.each(files, fn file ->
      database = Path.join([path, file])

      case Loader.load(database) do
        {:error, reason} ->
          Logger.info(reason)

        entries when is_list(entries) ->
          dataset = {database, Parser.parse(entries)}
          true = :ets.insert_new(ets_tid, dataset)
      end
    end)
  end

  defp drop_data_table(ets_tid) do
    true =
      case :ets.info(ets_tid) do
        :undefined -> true
        _ -> :ets.delete(ets_tid)
      end

    :ok
  end

  defp fetch_data_table() do
    case :ets.info(@ets_lookup_table_name) do
      :undefined ->
        nil

      _ ->
        case :ets.lookup(@ets_lookup_table_name, @ets_data_table_name) do
          [{@ets_data_table_name, ets_tid}] -> ets_tid
          _ -> nil
        end
    end
  end

  defp schedule_data_cleanup(ets_tid) do
    Process.send_after(
      self(),
      {:drop_data_table, ets_tid},
      Config.get(:ets_cleanup_delay, @ets_cleanup_delay_default)
    )

    :ok
  end
end
