defmodule RefInspector.ConfigTest do
  use ExUnit.Case, async: false

  alias RefInspector.Config

  setup do
    app_path = Application.get_env(:ref_inspector, :yaml)

    on_exit fn ->
      Application.put_env(:ref_inspector, :yaml, app_path)
    end
  end

  test "application configuration" do
    path = "/configuration/by/application/configuration"

    Application.put_env(:ref_inspector, :yaml, path)

    assert path == Config.yaml_path
  end

  test "system environment configuration" do
    path = "/configuration/by/system/environment"
    var  = "REF_INSPECTOR_CONFIG_TEST"

    Application.put_env(:ref_inspector, :yaml, { :system, var })
    System.put_env(var, path)

    assert path == Config.yaml_path
  end

  test "missing configuration" do
    Application.put_env(:ref_inspector, :yaml, nil)

    assert nil == Config.yaml_path
  end
end