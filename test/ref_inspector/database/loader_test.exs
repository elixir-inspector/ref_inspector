defmodule RefInspector.Database.LoaderTest do
  use ExUnit.Case, async: false

  alias RefInspector.Database.Loader

  setup do
    yaml_file_reader = Application.get_env(:ref_inspector, :yaml_file_reader)

    on_exit(fn ->
      Application.put_env(:ref_inspector, :yaml_file_reader, yaml_file_reader)
    end)
  end

  defmodule NoopYAML do
    def call_mf(_file), do: [:ok_mf]
    def call_mfa(_file, [:arg]), do: [:ok_mfa]
  end

  test "yaml file reader: {mod, fun}" do
    Application.put_env(:ref_inspector, :yaml_file_reader, {NoopYAML, :call_mf})

    assert :ok_mf = Loader.load(__ENV__.file)
  end

  test "yaml file reader: {mod, fun, extra_args}" do
    Application.put_env(:ref_inspector, :yaml_file_reader, {NoopYAML, :call_mfa, [[:arg]]})

    assert :ok_mfa = Loader.load(__ENV__.file)
  end
end
