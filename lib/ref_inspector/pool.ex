defmodule RefInspector.Pool do
  @moduledoc """
  Connects the plain RefInspector interface with the underlying pool.
  """

  @pool_name    :ref_inspector_pool
  @pool_options [
    name:          { :local, @pool_name },
    worker_module: RefInspector.Server,
    size:          5,
    max_overflow:  10
  ]

  @doc """
  Returns poolboy child specification for supervision tree.
  """
  @spec child_spec :: Supervisor.Spec.spec
  def child_spec do
    opts =
         @pool_options
      |> Keyword.merge(Application.get_env(:ref_inspector, :pool, []))

    :poolboy.child_spec(@pool_name, opts, [])
  end

  @doc """
  Sends a parse request to a pool worker.
  """
  @spec parse(String.t) :: map
  def parse(ref) do
    :poolboy.transaction(
      @pool_name,
      &GenServer.call(&1, { :parse, ref })
    )
  end
end
