defmodule ExReferer.Server do
  @moduledoc """
  ExReferer poolboy worker (server).
  """

  use GenServer

  @behaviour :poolboy_worker

  def start_link(default \\ %{}) do
    GenServer.start_link(__MODULE__, default)
  end

  def handle_call({ :parse, ref }, _from, state) do
    { :reply, ExReferer.Parser.parse(ref), state }
  end

  def handle_call(:stop, _from, state), do: { :stop, :normal, :ok, state }
end
