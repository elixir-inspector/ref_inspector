urlstream =
  [__DIR__, "urls.txt"]
  |> Path.join()
  |> File.read!()
  |> Code.eval_string([], file: "urls.txt")
  |> case do
    {urllist, _} when is_list(urllist) -> urllist
    _ -> []
  end
  |> Stream.cycle()

Enum.each([2, 4, 8, 16, 32, 64, 128], fn parallel ->
  IO.puts("Starting parallel: #{parallel}")

  for _ <- 1..parallel do
    Task.async(fn ->
      urlstream
      |> Enum.take(1000)
      |> Enum.each(&RefInspector.parse/1)
    end)
  end
  |> Enum.map(&Task.await(&1, :infinity))

  IO.puts("done")
end)
