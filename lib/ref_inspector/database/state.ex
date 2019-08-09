defmodule RefInspector.Database.State do
  @moduledoc false

  defstruct [
    :instance,
    startup_silent: false,
    startup_sync: true
  ]

  @type t :: %__MODULE__{
          instance: atom,
          startup_silent: boolean,
          startup_sync: boolean
        }
end
