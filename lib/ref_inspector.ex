defmodule RefInspector do
  @moduledoc """
  Ref Inspector - Referer parser library
  """

  alias RefInspector.Parser
  alias RefInspector.Result

  @doc """
  Checks if there is data to use in lookups.
  """
  @spec ready?() :: boolean
  defdelegate ready?(), to: RefInspector.Database

  @doc """
  Parses a referer.
  """
  @spec parse(String.t() | nil) :: Result.t()
  def parse(nil), do: %Result{}
  def parse(""), do: %Result{}

  def parse(ref) do
    ref
    |> URI.parse()
    |> Parser.parse()
    |> Map.put(:referer, ref)
  end

  @doc """
  Reloads all databases.
  """
  @spec reload() :: :ok
  defdelegate reload(), to: RefInspector.Database
end
