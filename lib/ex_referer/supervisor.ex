defmodule ExReferer.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    [
      worker(ExReferer.Database, []),
      ExReferer.Pool.child_spec
    ]
      |> supervise(strategy: :one_for_one)
  end
end
