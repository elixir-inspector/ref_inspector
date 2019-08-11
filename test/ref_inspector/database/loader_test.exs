defmodule RefInspector.Database.LoaderTest do
  use ExUnit.Case, async: false

  alias RefInspector.Database.Loader

  defmodule NoopYAML do
    def call_mf(_file), do: [:ok_mf]
    def call_mfa(_file, [:arg]), do: [:ok_mfa]
  end

  test "yaml file reader: {mod, fun}" do
    assert {:ok, :ok_mf} = Loader.load(__ENV__.file, {NoopYAML, :call_mf, []})
  end

  test "yaml file reader: {mod, fun, extra_args}" do
    assert {:ok, :ok_mfa} = Loader.load(__ENV__.file, {NoopYAML, :call_mfa, [[:arg]]})
  end
end
