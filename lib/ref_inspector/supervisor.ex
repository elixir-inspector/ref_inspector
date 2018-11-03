defmodule RefInspector.Supervisor do
  @moduledoc """
  RefInspector Supervisor.
  """

  use Supervisor

  alias RefInspector.Config

  @doc false
  def start_link(default \\ nil) do
    Supervisor.start_link(__MODULE__, default, name: __MODULE__)
  end

  @doc false
  def init(_state) do
    :ok = Config.init_env()

    Supervisor.init([RefInspector.Database], strategy: :one_for_one)
  end
end
