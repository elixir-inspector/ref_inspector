defmodule RefInspector do
  @moduledoc """
  Ref Inspector - Referer parser library
  """

  @doc """
  Parses a referer.
  """
  @spec parse(String.t) :: map
  defdelegate parse(ref), to: RefInspector.Pool
end
