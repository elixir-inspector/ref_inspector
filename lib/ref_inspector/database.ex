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

  def handle_call(:ets_tid, _from, state) do
    {:reply, state.ets_tid, state}
  end

  def handle_cast(:reload, _state) do
    state = %State{ets_tid: create_ets_table()}

    database_files = Config.database_files()
    database_path = Config.database_path()

    state =
      Enum.reduce(database_files, state, fn database_file, acc_state ->
        database = Path.join([database_path, database_file])

        case Loader.load(database) do
          {:error, reason} ->
            Logger.info(reason)

          entries when is_list(entries) ->
            entries
            |> Parser.parse()
            |> store_refs(acc_state)
        end
      end)

    {:noreply, state}
  end

  # Convenience methods

  @doc """
  Returns all referer definitions.
  """
  @spec list() :: [tuple]
  def list() do
    case GenServer.call(__MODULE__, :ets_tid) do
      nil -> []
      ets_tid -> :ets.tab2list(ets_tid)
    end
  end

  @doc """
  Reloads all databases.
  """
  @spec reload() :: :ok
  def reload(), do: GenServer.cast(__MODULE__, :reload)

  # Internal methods

  defp create_ets_table() do
    ets_name = :ref_inspector
    ets_opts = [:protected, :ordered_set, read_concurrency: true]

    :ets.new(ets_name, ets_opts)
  end

  defp store_refs([], state), do: state

  defp store_refs([{medium, sources} | refs], state) do
    index = state.ets_index + 1
    medium = String.to_atom(medium)
    dataset = {index, medium, sources}

    :ets.insert_new(state.ets_tid, dataset)
    store_refs(refs, %{state | ets_index: index})
  end
end
