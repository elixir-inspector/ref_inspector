defmodule RefInspector do
  @moduledoc """
  RefInspector Application
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    options  = [ strategy: :one_for_one, name: RefInspector.Supervisor ]
    children = [
      RefInspector.Pool.child_spec,
      worker(RefInspector.Database, [])
    ]

    Supervisor.start_link(children, options)
  end

  @doc """
  Parses a referer.
  """
  @spec parse(String.t) :: map
  defdelegate parse(ref), to: RefInspector.Pool
end
