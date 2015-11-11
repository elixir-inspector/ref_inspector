if Version.match?(System.version, ">= 1.0.3") do
  #
  # Elixir 1.0.3 and up requires mixed case module namings.
  #
  defmodule Mix.Tasks.RefInspector.Verify do
    @moduledoc false
    @shortdoc  "Verifies parser results"

    use Mix.Task

    defdelegate run(args), to: Mix.RefInspector.Verify
  end
else
  #
  # Elixir 1.0.2 requires the underscore module naming.
  #
  defmodule Mix.Tasks.Ref_inspector.Verify do
    @moduledoc false
    @shortdoc  "Verifies parser results"

    use Mix.Task

    defdelegate run(args), to: Mix.RefInspector.Verify
  end
end
