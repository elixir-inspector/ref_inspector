defmodule RefInspector.Database do
  @moduledoc false

  use GenServer

  require Logger

  alias RefInspector.Config
  alias RefInspector.Database.Loader
  alias RefInspector.Database.Parser
  alias RefInspector.Database.State

  @ets_table_opts [:named_table, :protected, :set, read_concurrency: true]

  @doc false
  def start_link(instance) do
    GenServer.start_link(__MODULE__, %State{instance: instance}, name: instance)
  end

  @doc false
  def init(%State{} = state) do
    state = init_state(state)

    if state.startup_sync do
      :ok = reload_databases(state)
    else
      :ok = GenServer.cast(state.instance, :reload)
    end

    {:ok, state}
  end

  def handle_call(:reload, _from, state) do
    {:reply, reload_databases(state), state}
  end

  def handle_cast(:reload, state) do
    :ok = reload_databases(state)

    {:noreply, state}
  end

  @doc """
  Returns all referer definitions.
  """
  @spec list(atom) :: [tuple]
  def list(instance) do
    case :ets.info(instance) do
      :undefined ->
        []

      _ ->
        case :ets.lookup(instance, :data) do
          [{:data, entries}] -> entries
          _ -> []
        end
    end
  end

  @doc """
  Reloads the database.

  Depending on the boolean option `:async` the reload will be performed
  using `GenServer.cast/2` oder `GenServer.call/2`.
  """
  def reload(opts) do
    if opts[:async] do
      GenServer.cast(opts[:instance], :reload)
    else
      GenServer.call(opts[:instance], :reload)
    end
  end

  defp create_ets_table(instance) do
    case :ets.info(instance) do
      :undefined ->
        _ = :ets.new(instance, @ets_table_opts)
        :ok

      _ ->
        :ok
    end
  end

  defp init_state(state) do
    :ok = Config.init_env()

    %State{
      state
      | startup_silent: Config.get(:startup_silent, state.startup_silent),
        startup_sync: Config.get(:startup_sync, state.startup_sync)
    }
  end

  defp read_databases([], silent) do
    _ =
      unless silent do
        Logger.warn("Reload error: no database files configured!")
      end

    []
  end

  defp read_databases(files, silent) do
    Enum.map(files, fn file ->
      entries =
        Config.database_path()
        |> Path.join(file)
        |> Loader.load()
        |> parse_database(file, silent)

      {file, entries}
    end)
  end

  defp parse_database({:ok, entries}, _, _) do
    Parser.parse(entries)
  end

  defp parse_database({:error, reason}, file, silent) do
    _ =
      unless silent do
        Logger.info("Failed to load #{file}: #{inspect(reason)}")
      end

    %{}
  end

  defp reload_databases(%{instance: instance, startup_silent: silent}) do
    :ok = create_ets_table(instance)

    Config.database_files()
    |> read_databases(silent)
    |> update_ets_table(instance)
  end

  defp update_ets_table(datasets, instance) do
    true = :ets.insert(instance, {:data, datasets})
    :ok
  end
end
