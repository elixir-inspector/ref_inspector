defmodule ExReferer.Server do
  use GenServer

  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, [ name: :ex_referer ])
  end

  def stop() do
    GenServer.call(:ex_referer, :stop)
  end

  def handle_call({ :parse, ref }, _from, state) do
    { :reply, ExReferer.Parser.parse(ref), state }
  end

  def handle_call(:stop, _from, state), do: { :stop, :normal, :ok, state }

  def terminate(_, _), do: :ok
end
