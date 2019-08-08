defmodule RefInspector.Database.InitializerTest do
  use ExUnit.Case, async: false

  defmodule Initializer do
    use Agent

    def start_link(_), do: Agent.start_link(fn -> nil end, name: __MODULE__)

    def call_init, do: call_init(:ok_empty)
    def call_init(result), do: Agent.update(__MODULE__, fn _ -> result end)

    def get_init, do: Agent.get(__MODULE__, & &1)
  end

  setup_all do
    init = Application.get_env(:ref_inspector, :init)

    on_exit(fn ->
      :ok = Application.put_env(:ref_inspector, :init, init)
    end)
  end

  test "init {mod, fun} called upon database (re-) start" do
    :ok = Application.put_env(:ref_inspector, :init, {Initializer, :call_init})

    {:ok, _} = start_supervised(Initializer)
    {:ok, _} = start_supervised({RefInspector.Database, :initializer_test})

    assert :ok_empty == Initializer.get_init()
  end

  test "init {mod, fun, args} called upon database (re-) start" do
    :ok = Application.put_env(:ref_inspector, :init, {Initializer, :call_init, [:ok_passed]})

    {:ok, _} = start_supervised(Initializer)
    {:ok, _} = start_supervised({RefInspector.Database, :initializer_test})

    assert :ok_passed == Initializer.get_init()
  end
end
