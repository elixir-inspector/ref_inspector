defmodule ExReferer do
  @doc """
  Parses a referer.
  """
  @spec parse(String.t) :: tuple
  def parse(ref), do: ExReferer.Parser.parse(ref)
end
