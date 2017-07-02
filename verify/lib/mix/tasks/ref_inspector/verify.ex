defmodule Mix.Tasks.RefInspector.Verify do
  @moduledoc false
  @shortdoc  "Verifies parser results"

  use Mix.Task

  defdelegate run(args), to: Mix.RefInspector.Verify
end
