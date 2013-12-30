defmodule ExReferer.Parser do
  @doc """
  Parses a given referer string.
  """
  @spec parse(String.t) :: tuple
  def parse(ref) do
    [ string: ref,
      medium: nil,
      source: nil,
      term:   nil ]
  end
end
