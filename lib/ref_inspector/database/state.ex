defmodule RefInspector.Database.State do
  @moduledoc false

  defstruct [
    :instance,
    :yaml_reader,
    startup_silent: false,
    startup_sync: true
  ]

  @type t :: %__MODULE__{
          instance: atom,
          startup_silent: boolean,
          startup_sync: boolean,
          yaml_reader: {module, atom, [term]}
        }
end
