defmodule ExReferer do
  use Application

  def start(_, _) do
    ExReferer.Supervisor.start_link()

    if Application.get_env(:ex_referer, :yaml) do
      load(Application.get_env(:ex_referer, :yaml))
    end

    { :ok, self() }
  end

  @doc """
  Loads yaml file with referer definitions.
  """
  @spec load(String.t) :: :ok | { :error, String.t }
  def load(file), do: GenServer.call(:ex_referer, { :load, file })

  @doc """
  Parses a referer.
  """
  @spec parse(String.t) :: Map.t
  def parse(ref), do: GenServer.call(:ex_referer, { :parse, ref })
end
