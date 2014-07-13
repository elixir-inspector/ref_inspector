defmodule ExReferer.Response do
  @type t :: %__MODULE__{
    string: String.t,
    medium: atom,
    source: String.t,
    term:   String.t
  }

  defstruct string: nil,
            medium: nil,
            source: nil,
            term:   nil
end
