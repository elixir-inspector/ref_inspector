defmodule RefInspector do
  @moduledoc """
  RefInspector Application
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    options  = [ strategy: :one_for_one, name: RefInspector.Supervisor ]
    children = [ worker(RefInspector.Database, []), RefInspector.Pool.child_spec ]

    sup = Supervisor.start_link(children, options)

    if Application.get_env(:ref_inspector, :yaml) do
      :ok = load(Application.get_env(:ref_inspector, :yaml))
    end

    sup
  end

  @doc """
  Loads yaml file with referer definitions.
  """
  @spec load(String.t) :: :ok | { :error, String.t }
  def load(file), do: RefInspector.Database.load(file)

  @doc """
  Parses a referer.
  """
  @spec parse(String.t) :: map
  def parse(ref), do: RefInspector.Pool.parse(ref)
end
