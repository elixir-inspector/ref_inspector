defmodule RefInspector.Server do
  @moduledoc """
  RefInspector poolboy worker (server).
  """

  use GenServer

  @behaviour :poolboy_worker

  def start_link(default \\ %{}) do
    GenServer.start_link(__MODULE__, default)
  end

  def init(state), do: {:ok, state}

  def handle_call({:parse, ref}, _from, state) do
    {:reply, RefInspector.Parser.parse(ref), state}
  end
end
