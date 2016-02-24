defmodule RefInspector.Database.State do
  @moduledoc """
  State definition for the parser database.
  """

  defstruct [
    ets_index: 0,
    ets_tid:   nil
  ]

  @opaque t :: %__MODULE__{
    ets_index: non_neg_integer,
    ets_tid:   :ets.tid
  }
end
