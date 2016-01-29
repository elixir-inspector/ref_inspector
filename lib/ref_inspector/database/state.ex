defmodule RefInspector.Database.State do
  @moduledoc """
  State definition for the parser database.
  """

  defstruct [
    :ets
  ]

  @opaque t :: %__MODULE__{
    ets: :ets.tid
  }
end
