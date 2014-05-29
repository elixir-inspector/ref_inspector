defmodule ExReferer.Response do
  @type t :: map

  defstruct string: nil :: String.t,
            medium: nil :: atom,
            source: nil :: String.t,
            term:   nil :: String.t
end
