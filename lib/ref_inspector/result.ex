defmodule RefInspector.Result do
  @moduledoc """
  Result struct.
  """

  @type t :: %__MODULE__{
          referer: String.t() | nil,
          medium: String.t() | :internal | :unknown,
          source: String.t() | :unknown,
          term: String.t() | :none
        }

  defstruct referer: "",
            medium: :unknown,
            source: :unknown,
            term: :none
end
