defmodule Mix.Tasks.RefInspector.Verify do
  @moduledoc """
  Verifies RefInspector results.
  """

  @shortdoc "Verifies parser results"

  use Mix.Task

  alias Mix.RefInspector.Verify
  alias RefInspector.Downloader

  def run(args) do
    {opts, _argv, _errors} = OptionParser.parse(args, strict: [quick: :boolean])

    :ok = maybe_download(opts)
    {:ok, _} = Application.ensure_all_started(:ref_inspector)

    verify_all()
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

  defp verify([]), do: nil

  defp verify([%{uri: testuri} = testcase | testcases]) do
    result = RefInspector.parse(testuri)

    if compare(testcase, result) do
      verify(testcases)
    else
      IO.puts("-- verification failed --")
      IO.puts("referer: #{testuri}")
      IO.puts("testcase: #{inspect(testcase)}")
      IO.puts("result: #{inspect(result)}")

      throw("verification failed")
    end
  end

  defp verify_all do
    fixture = Verify.Fixture.local_file()

    if File.exists?(fixture) do
      verify_fixture(fixture)
    else
      Mix.shell().error("Fixture file #{fixture} is missing.")
      Mix.shell().error("Please run without '--quick' param to download it!")
    end
  end

  defp verify_fixture(fixture) do
    [testcases] = :yamerl_constr.file(fixture, [:str_node_as_binary])

    testcases
    |> Enum.map(fn testcase ->
      testcase
      |> Enum.into(%{}, fn {k, v} -> {String.to_atom(k), v} end)
      |> Verify.Cleanup.cleanup()
    end)
    |> verify()
  end
end
