defmodule Mix.Tasks.RefInspector.Verify.Cleanup do
  @moduledoc """
  Cleans up testcases.
  """

  @doc """
  Cleans up a test case.
  """
  @spec cleanup(testcase :: map) :: map
  def cleanup(testcase) do
    testcase
    |> cleanup_medium()
    |> cleanup_source()
    |> cleanup_term()
  end


  defp cleanup_medium(%{ medium: :null } = testcase) do
    %{ testcase | medium: :unknown }
  end
  defp cleanup_medium(%{ medium: "internal" } = testcase) do
    %{ testcase | medium: :unknown }
  end
  defp cleanup_medium(%{ medium: medium } = testcase) do
    %{ testcase | medium: String.to_atom(medium) }
  end


  defp cleanup_source(%{ source: :null } = testcase) do
    %{ testcase | source: :unknown }
  end
  defp cleanup_source(testcase), do: testcase


  defp cleanup_term(%{ term: :null } = testcase) do
    %{ testcase | term: :none }
  end
  defp cleanup_term(testcase), do: testcase
end
