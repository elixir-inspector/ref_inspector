defmodule RefInspector.Database.State do
  @moduledoc """
  State definition for the parser database.
  """

  defstruct ets_tid: nil

  @opaque t :: %__MODULE__{
            ets_tid: :ets.tid()
          }
end
