defmodule ExReferer do
  @moduledoc """
  ExReferer Application
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    options  = [ strategy: :one_for_one, name: ExReferer.Supervisor ]
    children = [ worker(ExReferer.Database, []), ExReferer.Pool.child_spec ]

    sup = Supervisor.start_link(children, options)

    if Application.get_env(:ex_referer, :yaml) do
      :ok = load(Application.get_env(:ex_referer, :yaml))
    end

    sup
  end

  @doc """
  Loads yaml file with referer definitions.
  """
  @spec load(String.t) :: :ok | { :error, String.t }
  def load(file), do: ExReferer.Database.load(file)

  @doc """
  Parses a referer.
  """
  @spec parse(String.t) :: map
  def parse(ref), do: ExReferer.Pool.parse(ref)
end
