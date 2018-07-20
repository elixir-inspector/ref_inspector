defmodule RefInspector.Benchmark.Database do
  def run() do
    entries = load_database()

    Benchee.run(
      %{
        "parse database" => fn -> RefInspector.Database.Parser.parse(entries) end
      },
      warmup: 2,
      time: 10
    )
  end

  defp load_database() do
    db_dir = RefInspector.Config.database_path()
    [db_file] = RefInspector.Config.database_files()

    [db_dir, db_file]
    |> Path.join()
    |> RefInspector.Database.Loader.load()
  end
end

RefInspector.Benchmark.Database.run()
