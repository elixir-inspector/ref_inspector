defmodule Mix.Tasks.RefInspector.Verify do
  @moduledoc """
  Verifies RefInspector results.
  """

  @shortdoc "Verifies parser results"

  use Mix.Task

  alias Mix.RefInspector.Verify
  alias RefInspector.Downloader

  def run(args) do
    {opts, _argv, _errors} = OptionParser.parse(args)

    :ok = maybe_download(opts)
    {:ok, _} = Application.ensure_all_started(:ref_inspector)

    Verify.Fixture.local_file() |> verify_all()

    Mix.shell().info("Verification complete!")
    :ok
  end

  defp compare(testcase, result) do
    testcase.uri == result.referer && testcase.medium == result.medium &&
      testcase.source == result.source && testcase.term == result.term
  end

  defp maybe_download(quick: true), do: :ok

  defp maybe_download(_) do
    {:ok, _} = Application.ensure_all_started(:hackney)
    :ok = Downloader.download()
    :ok = Verify.Fixture.download()

    Mix.shell().info("=== Skip download using '--quick' ===")

    :ok
  end

  defp parse(case_data) when is_list(case_data) do
    case_data
    |> Enum.map(fn {k, v} -> {String.to_atom(k), parse(v)} end)
    |> Enum.into(%{})
  end

  defp parse(case_data), do: case_data

  defp unravel_list([cases]), do: cases

  defp verify([]), do: nil

  defp verify([testcase | testcases]) do
    testcase = testcase |> parse() |> Verify.Cleanup.cleanup()
    result = testcase[:uri] |> RefInspector.parse()

    case compare(testcase, result) do
      true ->
        verify(testcases)

      false ->
        IO.puts("-- verification failed --")
        IO.puts("referer: #{testcase[:uri]}")
        IO.puts("testcase: #{inspect(testcase)}")
        IO.puts("result: #{inspect(result)}")

        throw("verification failed")
    end
  end

  defp verify_all(fixture) do
    case File.exists?(fixture) do
      false ->
        Mix.shell().error("Fixture file #{fixture} is missing.")
        Mix.shell().error("Please run without '--quick' param to download it!")

      true ->
        testcases =
          fixture
          |> :yamerl_constr.file([:str_node_as_binary])
          |> unravel_list()

        verify(testcases)
    end
  end
end
