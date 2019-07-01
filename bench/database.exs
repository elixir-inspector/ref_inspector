defmodule RefInspector.Benchmark.Database do
  alias RefInspector.Config
  alias RefInspector.Database.Loader
  alias RefInspector.Database.Parser

  def run do
    {:ok, entries} = load_database()

    Benchee.run(
      %{
        "parse database" => fn -> Parser.parse(entries) end
      },
      warmup: 2,
      time: 10
    )
  end

  defp load_database do
    db_dir = Config.database_path()
    [db_file] = Config.database_files()

    [db_dir, db_file]
    |> Path.join()
    |> Loader.load()
  end
end

RefInspector.Benchmark.Database.run()
