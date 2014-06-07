defmodule ExReferer.Server do
  use GenServer

  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, [ name: :ex_referer ])
  end

  def init(_) do
    :ets.new(:ex_referer,     [ :set,         :private, :named_table ])
    :ets.new(:ex_referer_ref, [ :ordered_set, :private, :named_table ])

    :ets.insert(:ex_referer, [ ref_count: 0 ])

    { :ok, [] }
  end

  def stop() do
    GenServer.call(:ex_referer, :stop)
  end

  def handle_call({ :load_yaml, file }, _from, state) do
    { :reply, ExReferer.Referers.load_yaml(file), state }
  end

  def handle_call({ :parse, ref }, _from, state) do
    { :reply, ExReferer.Parser.parse(ref), state }
  end

  def handle_call(:stop, _from, state), do: { :stop, :normal, :ok, state }

  def terminate(_, _) do
    :ets.delete(:ex_referer_ref)
    :ets.delete(:ex_referer)
    :ok
  end
end
