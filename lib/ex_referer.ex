defmodule ExReferer do
  @doc """
  Parses a referer.
  """
  @spec parse(String.t) :: ExReferer.Response.t
  def parse(ref), do: ExReferer.Parser.parse(ref)
end
