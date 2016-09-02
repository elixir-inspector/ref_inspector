defmodule RefInspector.Deprecations.YamlConfigTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias RefInspector.Config

  setup_all do
    database_files = Application.get_env(:ref_inspector, :database_files)
    database_path  = Application.get_env(:ref_inspector, :database_path)

    Application.put_env(:ref_inspector, :database_files, nil)
    Application.put_env(:ref_inspector, :database_path, nil)
    Application.put_env(:ref_inspector, :yaml, "/just/some/file.yml")

    on_exit fn ->
      Application.put_env(:ref_inspector, :database_files, database_files)
      Application.put_env(:ref_inspector, :database_path, database_path)

      Application.delete_env(:ref_inspector, :yaml)
    end
  end


  test "database path from :yaml" do
    stderr = capture_io :stderr, fn ->
      Config.database_path
    end

    assert String.contains?(stderr, "deprecated")
  end

  test "database files from :yaml" do
    stderr = capture_io :stderr, fn ->
      Config.database_files
    end

    assert String.contains?(stderr, "deprecated")
  end
end