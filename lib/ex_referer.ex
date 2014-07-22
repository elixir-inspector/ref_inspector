defmodule ExReferer do
  use Application

  def start(_, _) do
    ExReferer.Supervisor.start_link()

    if Application.get_env(:ex_referer, :yaml) do
      load_yaml(Application.get_env(:ex_referer, :yaml))
    end

    { :ok, self() }
  end

  @doc """
  Loads yaml file with referer definitions.
  """
  @spec load_yaml(String.t) :: :ok | { :error, String.t }
  def load_yaml(file), do: GenServer.call(:ex_referer, { :load_yaml, file })

  @doc """
  Parses a referer.
  """
  @spec parse(String.t) :: ExReferer.Response.t
  def parse(ref), do: GenServer.call(:ex_referer, { :parse, ref })
end
