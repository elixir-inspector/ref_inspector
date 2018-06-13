defmodule RefInspector.Benchmark.Parse do
  def run() do
    [__DIR__, "urls.txt"]
    |> Path.join()
    |> File.read!()
    |> Code.eval_string([], file: "urls.txt")
    |> case do
      {urllist, _} when is_list(urllist) -> urllist
      _ -> []
    end
    |> Stream.cycle()
    |> run_benchmark()
  end

  defp run_benchmark(urlstream) do
    Enum.each([2, 4, 8, 16, 32, 64, 128], fn parallel ->
      IO.puts("Starting parallel: #{parallel}")

      {us, _} =
        :timer.tc(fn ->
          for _ <- 1..parallel do
            Task.async(fn ->
              urlstream
              |> Enum.take(1000)
              |> Enum.each(&RefInspector.parse/1)
            end)
          end
          |> Enum.map(&Task.await(&1, :infinity))
        end)

      IO.puts("done in #{us} microseconds")
    end)
  end
end

RefInspector.Benchmark.Parse.run()
