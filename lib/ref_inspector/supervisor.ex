defmodule RefInspector.Supervisor do
  @moduledoc """
  RefInspector Supervisor.
  """

  use Supervisor

  alias RefInspector.Config


  @doc """
  Starts the supervisor.
  """
  @spec start_link(term) :: Supervisor.on_start
  def start_link(default \\ []) do
    Supervisor.start_link(__MODULE__, default, [ name: __MODULE__ ])
  end

  @doc false
  def init(_default) do
    :ok = case Config.get(:init) do
      nil          -> :ok
      { mod, fun } -> apply(mod, fun, [])
    end

    options  = [ strategy: :one_for_one, name: __MODULE__ ]
    children = [
      RefInspector.Pool.child_spec,
      worker(RefInspector.Database, [])
    ]

    supervise(children, options)
  end
end
