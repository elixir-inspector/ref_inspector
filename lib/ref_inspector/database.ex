defmodule RefInspector.Database do
  @moduledoc false

  use GenServer

  require Logger

  alias RefInspector.Config
  alias RefInspector.Database.Loader
  alias RefInspector.Database.Parser
  alias RefInspector.Database.State

  @ets_table_opts [:named_table, :protected, :set, read_concurrency: true]

  def start_link(opts) do
    state = init_state(opts)
    name = identifier(state.database)

    GenServer.start_link(__MODULE__, state, name: name)
  end

  @doc false
  def init(%State{database: nil}), do: {:stop, "missing database name"}

  def init(%State{} = state) do
    if state.startup_sync do
      :ok = reload_databases(state)
    else
      :ok =
        state.database
        |> identifier()
        |> GenServer.cast(:reload)
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
  def list(database) do
    table_name = identifier(database)

    case :ets.lookup(table_name, :data) do
      [{:data, entries}] -> entries
      _ -> []
    end
  rescue
    _ -> []
  end

  @doc """
  Reloads the database.

  Depending on the boolean option `:async` the reload will be performed
  using `GenServer.cast/2` or `GenServer.call/2`.
  """
  def reload(opts) do
    identifier = identifier(opts[:database])

    if opts[:async] do
      GenServer.cast(identifier, :reload)
    else
      GenServer.call(identifier, :reload)
    end
  end

  defp create_ets_table(table_name) do
    case :ets.info(table_name) do
      :undefined ->
        _ = :ets.new(table_name, @ets_table_opts)
        :ok

      _ ->
        :ok
    end
  end

  defp identifier(database), do: :"ref_inspector_#{database}"

  defp init_state(opts) do
    :ok = Config.init_env()
    state = %State{}

    opts =
      opts
      |> init_state_option(:startup_silent, state)
      |> init_state_option(:startup_sync, state)
      |> Keyword.put_new(:database, :default)
      |> Keyword.put_new(:yaml_reader, Config.yaml_file_reader())

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

  if macro_exported?(Logger, :warning, 1) do
    defp read_databases([], silent, _) do
      _ =
        unless silent do
          Logger.warning("Reload error: no database files configured!")
        end

      []
    end
  else
    defp read_databases([], silent, _) do
      _ =
        unless silent do
          Logger.warn("Reload error: no database files configured!")
        end

      []
    end
  end

  defp read_databases(files, silent, yaml_reader) do
    Enum.map(files, fn file ->
      entries =
        Config.database_path()
        |> Path.join(file)
        |> Loader.load(yaml_reader)
        |> parse_database(file, silent)

      {file, entries}
    end)
  end

  defp reinit_state(state), do: state |> Map.to_list() |> init_state()

  defp reload_databases(%{database: database, startup_silent: silent, yaml_reader: yaml_reader}) do
    table_name = identifier(database)
    :ok = create_ets_table(table_name)

    Config.database_files()
    |> read_databases(silent, yaml_reader)
    |> update_ets_table(table_name)
  end

  defp update_ets_table(datasets, table_name) do
    true = :ets.insert(table_name, {:data, datasets})
    :ok
  end
end
