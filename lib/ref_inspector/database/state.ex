defmodule RefInspector.Database.State do
  @moduledoc false

  defstruct [
    :database,
    :yaml_reader,
    startup_silent: false,
    startup_sync: true
  ]

  @type t :: %__MODULE__{
          database: atom,
          startup_silent: boolean,
          startup_sync: boolean,
          yaml_reader: {module, atom, [term]}
        }
end
