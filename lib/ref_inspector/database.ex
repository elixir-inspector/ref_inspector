defmodule RefInspector.Database do
  @moduledoc false

  use GenServer

  require Logger

  alias RefInspector.Config
  alias RefInspector.Database.Loader
  alias RefInspector.Database.Parser

  @ets_table_name __MODULE__
  @ets_table_opts [:named_table, :protected, :set, read_concurrency: true]

  @doc false
  def start_link(default \\ nil) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @doc false
  def init(state) do
    if Config.get(:startup_sync, false) do
      :ok = reload_databases()
    else
      :ok = GenServer.cast(__MODULE__, :reload)
    end

    {:ok, state}
  end

  def handle_call(:reload, _from, state) do
    {:reply, reload_databases(), state}
  end

  def handle_cast(:reload, state) do
    :ok = reload_databases()

    {:noreply, state}
  end

  @doc """
  Returns all referer definitions.
  """
  @spec list() :: [tuple]
  def list do
    case :ets.info(@ets_table_name) do
      :undefined ->
        []

      _ ->
        case :ets.lookup(@ets_table_name, :data) do
          [{:data, entries}] -> entries
          _ -> []
        end
    end
  end

  defp create_ets_table do
    case :ets.info(@ets_table_name) do
      :undefined ->
        _ = :ets.new(@ets_table_name, @ets_table_opts)
        :ok

      _ ->
        :ok
    end
  end

  defp read_databases([]) do
    _ =
      unless Config.get(:startup_silent) do
        Logger.warn("Reload error: no database files configured!")
      end

    []
  end

  defp read_databases(files) do
    Enum.map(files, fn file ->
      entries =
        Config.database_path()
        |> Path.join(file)
        |> Loader.load()
        |> parse_database(file)

      {file, entries}
    end)
  end

  defp parse_database({:ok, entries}, _) do
    Parser.parse(entries)
  end

  defp parse_database({:error, reason}, file) do
    _ =
      unless Config.get(:startup_silent) do
        Logger.info("Failed to load #{file}: #{inspect(reason)}")
      end

    %{}
  end

  defp reload_databases do
    :ok = create_ets_table()

    Config.database_files()
    |> read_databases()
    |> update_ets_table()
  end

  defp update_ets_table(datasets) do
    true = :ets.insert(@ets_table_name, {:data, datasets})
    :ok
  end
end
