defmodule RefInspector.Database.ReloadTest do
  use ExUnit.Case, async: false

  @fixture_search "referers_search.yml"
  @fixture_social "referers_social.yml"

  setup do
    app_files = Application.get_env(:ref_inspector, :database_files)

    Application.put_env(:ref_inspector, :database_files, [])

    on_exit(fn ->
      Application.put_env(:ref_inspector, :database_files, app_files)
    end)
  end

  test "reloading databases" do
    Application.put_env(:ref_inspector, :database_files, [@fixture_search])
    RefInspector.reload_databases()
    :timer.sleep(100)

    assert RefInspector.parse("http://www.google.com/test").source == "Google"
    assert RefInspector.parse("http://twitter.com/test").source == :unknown

    Application.put_env(:ref_inspector, :database_files, [@fixture_social])
    RefInspector.reload_databases()
    :timer.sleep(100)

    assert RefInspector.parse("http://www.google.com/test").source == :unknown
    assert RefInspector.parse("http://twitter.com/test").source == "Twitter"
  end
end
