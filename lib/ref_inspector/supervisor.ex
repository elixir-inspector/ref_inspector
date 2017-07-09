defmodule RefInspector.Supervisor do
  @moduledoc """
  RefInspector Supervisor.
  """

  use Supervisor


  @doc """
  Starts the supervisor.
  """
  @spec start_link(term) :: Supervisor.on_start
  def start_link(default \\ []) do
    Supervisor.start_link(__MODULE__, default)
  end

  @doc false
  def init(_default) do
    options  = [ strategy: :one_for_one, name: RefInspector.Supervisor ]
    children = [
      RefInspector.Pool.child_spec,
      worker(RefInspector.Database, [])
    ]

    supervise(children, options)
  end
end
