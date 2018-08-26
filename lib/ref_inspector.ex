defmodule RefInspector do
  @moduledoc """
  RefInspector - Referer parser library
  """

  alias RefInspector.Database
  alias RefInspector.Parser
  alias RefInspector.Result

  @doc """
  Checks if there is data to use in lookups.

  The check is done against the currently active internal data table.

  An empty database is considered to be "not ready".
  """
  @spec ready?() :: boolean
  def ready?(), do: [] != Database.list()

  @doc """
  Parses a referer.
  """
  @spec parse(URI.t() | String.t() | nil) :: Result.t()
  def parse(nil), do: %Result{}
  def parse(""), do: %Result{}

  def parse(%URI{} = uri) do
    uri
    |> Parser.parse()
    |> Map.put(:referer, URI.to_string(uri))
  end

  def parse(ref) when is_binary(ref) do
    ref
    |> URI.parse()
    |> Parser.parse()
    |> Map.put(:referer, ref)
  end

  @doc """
  Reloads all databases.
  """
  @spec reload() :: :ok
  def reload(), do: GenServer.cast(Database, :reload)
end
