defmodule ExReferer do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    import Supervisor.Spec

    supervise([ worker(ExReferer.Server, []) ], strategy: :one_for_one)
  end

  @doc """
  Parses a referer.
  """
  @spec parse(String.t) :: ExReferer.Response.t
  def parse(ref), do: GenServer.call(:ex_referer, { :parse, ref })
end
