defmodule RefInspector.Supervisor do
  @moduledoc """
  RefInspector Supervisor.
  """

  alias RefInspector.Config

  @doc """
  Starts the supervisor.
  """
  @spec start_link(term) :: Supervisor.on_start()
  def start_link(default \\ nil) do
    Supervisor.start_link(__MODULE__, default, name: __MODULE__)
  end

  @doc false
  def init(_state) do
    :ok = Config.init_env()

    options = [strategy: :one_for_one, name: __MODULE__]
    children = [RefInspector.Database]

    Supervisor.init(children, options)
  end
end
