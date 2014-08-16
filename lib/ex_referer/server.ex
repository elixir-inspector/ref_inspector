defmodule ExReferer.Server do
  use GenServer

  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default)
  end

  def init(_), do: { :ok, [] }

  def handle_call({ :load, file }, _from, state) do
    { :reply, ExReferer.Database.load(file), state }
  end

  def handle_call({ :parse, ref }, _from, state) do
    { :reply, ExReferer.Parser.parse(ref), state }
  end

  def handle_call(:stop, _from, state), do: { :stop, :normal, :ok, state }
end
