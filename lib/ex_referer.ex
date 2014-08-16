defmodule ExReferer do
  use Application

  def start(_, _) do
    ExReferer.Database.init()
    ExReferer.Supervisor.start_link()

    if Application.get_env(:ex_referer, :yaml) do
      load(Application.get_env(:ex_referer, :yaml))
    end

    { :ok, self() }
  end

  def stop(), do: ExReferer.Database.terminate()

  @doc """
  Loads yaml file with referer definitions.
  """
  @spec load(String.t) :: :ok | { :error, String.t }
  def load(file), do: ExReferer.Pool.load(file)

  @doc """
  Parses a referer.
  """
  @spec parse(String.t) :: Map.t
  def parse(ref), do: ExReferer.Pool.parse(ref)
end
