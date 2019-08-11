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
  def start_link(instance) when is_atom(instance), do: start_link(instance: instance)

  def start_link(opts) do
    state = init_state(opts)

    GenServer.start_link(__MODULE__, state, name: state.instance)
  end

  @doc false
  def init(%State{instance: nil}), do: {:stop, "missing instance name"}

  def init(%State{} = state) do
    if state.startup_sync do
      :ok = reload_databases(state)
    else
      :ok = GenServer.cast(state.instance, :reload)
    end

    {:ok, state}
  end

  def handle_call(:reload, _from, state) do
    state = reinit_state(state)

    {:reply, reload_databases(state), state}
  end

  def handle_cast(:reload, state) do
    state = reinit_state(state)
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

  defp init_state(opts) do
    :ok = Config.init_env()
    state = %State{}

    opts =
      opts
      |> init_state_option(:startup_silent, state)
      |> init_state_option(:startup_sync, state)

    struct!(State, opts)
  end

  defp init_state_option(opts, key, state) do
    default = Map.fetch!(state, key)
    config = Config.get(key, default)

    Keyword.put_new(opts, key, config)
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

  defp reinit_state(state), do: state |> Map.to_list() |> init_state()

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
