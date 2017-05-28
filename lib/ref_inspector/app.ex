defmodule RefInspector.App do
  @moduledoc false

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
end
