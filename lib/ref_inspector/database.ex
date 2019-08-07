defmodule RefInspector.Database do
  @moduledoc false

  use GenServer

  require Logger

  alias RefInspector.Config
  alias RefInspector.Database.Loader
  alias RefInspector.Database.Parser

  @ets_table_opts [:named_table, :protected, :set, read_concurrency: true]

  @doc false
  def start_link(instance) do
    GenServer.start_link(__MODULE__, instance, name: instance)
  end

  @doc false
  def init(instance) do
    if Config.get(:startup_sync, true) do
      :ok = reload_databases(instance)
    else
      :ok = GenServer.cast(instance, :reload)
    end

    {:ok, instance}
  end

  def handle_call(:reload, _from, instance) do
    {:reply, reload_databases(instance), instance}
  end

  def handle_cast(:reload, instance) do
    :ok = reload_databases(instance)

    {:noreply, instance}
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

  defp reload_databases(instance) do
    :ok = create_ets_table(instance)

    Config.database_files()
    |> read_databases()
    |> update_ets_table(instance)
  end

  defp update_ets_table(datasets, instance) do
    true = :ets.insert(instance, {:data, datasets})
    :ok
  end
end
