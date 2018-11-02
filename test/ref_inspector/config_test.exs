defmodule RefInspector.ConfigTest do
  use ExUnit.Case, async: false

  alias RefInspector.Config

  setup do
    app_path = Application.get_env(:ref_inspector, :database_path)

    on_exit(fn ->
      Application.put_env(:ref_inspector, :database_path, app_path)
    end)
  end

  test "application configuration" do
    path = "/configuration/by/application/configuration"
    urls = ["http://some/host/database.yml"]

    Application.put_env(:ref_inspector, :database_path, path)
    Application.put_env(:ref_inspector, :remote_urls, urls)

    assert path == Config.database_path()
    assert urls == Config.yaml_urls()
  end

  test "priv dir fallback for misconfiguration" do
    Application.put_env(:ref_inspector, :database_path, nil)

    refute nil == Config.database_path()
  end
end
