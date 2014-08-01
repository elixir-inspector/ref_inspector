defmodule ExReferer.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    supervise([ worker(ExReferer.Server, []) ], strategy: :one_for_one)
  end
end
