defmodule ExReferer.Pool do
  @moduledoc """
  Connects the plain ExReferer interface with the underlying pool.
  """

  @pool_name    :ex_referer_pool
  @pool_options [
    name:          { :local, @pool_name },
    worker_module: ExReferer.Server,
    size:          Application.get_env(:ex_referer, :pool_size, 5),
    max_overflow:  Application.get_env(:ex_referer, :pool_max_overflow, 10)
  ]

  @doc """
  Returns poolboy child specification for supervision tree.
  """
  def child_spec(), do: :poolboy.child_spec(@pool_name, @pool_options, [])

  @doc false
  def load(file) do
    :poolboy.transaction(
      @pool_name,
      &GenServer.call(&1, { :load, file })
    )
  end

  @doc false
  def parse(ref) do
    :poolboy.transaction(
      @pool_name,
      &GenServer.call(&1, { :parse, ref })
    )
  end
end
