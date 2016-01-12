defmodule RefInspector.Database.State do
  @moduledoc """
  State definition for the parser database.
  """

  defstruct [
    :ets_counter,
    :ets_referers
  ]

  @opaque t :: %__MODULE__{
    ets_counter:  :ets.tid,
    ets_referers: :ets.tid
  }
end
