defmodule ExReferer do
  @moduledoc """
  ExReferer Application
  """

  use Application

  def start(_type, _args) do
    { :ok, _pid } = ExReferer.Supervisor.start_link()

    if Application.get_env(:ex_referer, :yaml) do
      :ok = load(Application.get_env(:ex_referer, :yaml))
    end

    { :ok, self() }
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
