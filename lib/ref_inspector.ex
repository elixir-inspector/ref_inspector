defmodule RefInspector do
  @moduledoc """
  Ref Inspector - Referer parser library
  """

  @doc """
  Checks if there is data to use in lookups.
  """
  @spec ready?() :: boolean
  defdelegate ready?(), to: RefInspector.Database

  @doc """
  Parses a referer.
  """
  @spec parse(String.t() | nil) :: RefInspector.Result.t()
  defdelegate parse(ref), to: RefInspector.Parser

  @doc """
  Reloads all databases.
  """
  @spec reload() :: :ok
  defdelegate reload(), to: RefInspector.Database
end
