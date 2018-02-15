defmodule RefInspector do
  @moduledoc """
  Ref Inspector - Referer parser library
  """

  require Logger

  @doc """
  Checks if there is data to use in lookups.
  """
  @spec ready?() :: boolean
  defdelegate ready?(), to: RefInspector.Database

  @doc """
  Parses a referer.
  """
  @spec parse(String.t()) :: map
  defdelegate parse(ref), to: RefInspector.Pool

  @doc """
  Reloads all databases.
  """
  @spec reload() :: :ok
  defdelegate reload(), to: RefInspector.Database
end
