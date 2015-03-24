defmodule RefInspector.Result do
  @moduledoc """
  Result struct.
  """

  defstruct [
    referer: "",
    medium:  :unknown,
    source:  :unknown,
    term:    :none
  ]
end
