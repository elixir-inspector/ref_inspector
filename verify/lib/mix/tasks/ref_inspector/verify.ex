defmodule Mix.Tasks.RefInspector.Verify do
  @moduledoc """
  Verifies RefInspector results.
  """

  if Version.match?(System.version, ">= 1.0.3") do
    # ensures "mix help" displays a proper task
    use Mix.Task

    @shortdoc "Verifies parser results"
  end

  alias Mix.Tasks.RefInspector.Verify

  def run(_args) do
    { :ok, _ } = Application.ensure_all_started(:ref_inspector)
    :ok        = Verify.Fixture.download()

    Verify.Fixture.local_file() |> verify_all()

    Mix.shell.info "Verification complete!"
    :ok
  end


  defp compare(testcase, result) do
    testcase.uri == result.referer
    && testcase.medium == result.medium
    && testcase.source == result.source
    && testcase.term == result.term
  end

  defp parse(case_data) when is_list(case_data) do
    case_data
    |> Enum.map(fn ({ k, v }) -> { String.to_atom(k), parse(v) } end)
    |> Enum.into(%{})
  end
  defp parse(case_data), do: case_data

  defp unravel_list([ cases ]), do: cases

  defp verify([]),                      do: nil
  defp verify([ testcase | testcases ]) do
    testcase = testcase |> parse() |> Verify.Cleanup.cleanup()
    result   = testcase[:uri] |> RefInspector.parse()

    case compare(testcase, result) do
      true  -> verify(testcases)
      false ->
        IO.puts "-- verification failed --"
        IO.puts "referer: #{ testcase[:uri] }"
        IO.puts "testcase: #{ inspect testcase }"
        IO.puts "result: #{ inspect result }"

        throw "verification failed"
    end
  end

  defp verify_all(fixture) do
    testcases =
         fixture
      |> :yamerl_constr.file([ :str_node_as_binary ])
      |> unravel_list()

    verify(testcases)
  end
end

# Underscore naming required by elixir <= 1.0.2
if Version.match?(System.version, "<= 1.0.2") do
  defmodule Mix.Tasks.Ref_inspector.Verify do
    @moduledoc false
    @shortdoc  "Verifies parser results"

    use Mix.Task

    defdelegate run(args), to: Mix.Tasks.RefInspector.Verify
  end
end
