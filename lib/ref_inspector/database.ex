defmodule RefInspector.Database do
  @moduledoc false

  use GenServer

  require Logger

  alias RefInspector.Config
  alias RefInspector.Database.Loader
  alias RefInspector.Database.Parser

  @ets_table_name :ref_inspector
  @ets_table_opts [:named_table, :protected, :set, read_concurrency: true]

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
    :ok = create_ets_table()

    :ok =
      Config.database_files()
      |> read_databases()
      |> update_ets_table()

    {:noreply, state}
  end

  # Convenience methods

  @doc """
  Returns all referer definitions.
  """
  @spec list() :: [tuple]
  def list do
    case :ets.info(@ets_table_name) do
      :undefined ->
        []

      _ ->
        @ets_table_name
        |> :ets.lookup(:data)
        |> Keyword.get(:data, [])
    end
  end

  # Internal methods

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
    _ = Logger.warn("Reload error: no database files configured!")

    []
  end

  defp read_databases(files) do
    database_path = Config.database_path()

    Enum.map(files, fn file ->
      entries =
        database_path
        |> Path.join(file)
        |> Loader.load()
        |> case do
          {:error, reason} ->
            _ = Logger.info(reason)
            %{}

          entries when is_list(entries) ->
            Parser.parse(entries)
        end

      {file, entries}
    end)
  end

  defp update_ets_table(datasets) do
    true = :ets.insert(@ets_table_name, {:data, datasets})
    :ok
  end
end
