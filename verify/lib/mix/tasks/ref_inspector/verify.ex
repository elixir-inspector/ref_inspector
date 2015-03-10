defmodule Mix.Tasks.RefInspector.Verify do
  use Mix.Task

  alias Mix.Tasks.RefInspector.Verify

  def run(_args) do
    :ok = Verify.Fixture.download()

    :ok
  end
end

# Underscore naming required by elixir <= 1.0.2
defmodule Mix.Tasks.Ref_inspector.Verify do
  defdelegate run(args), to: Mix.Tasks.RefInspector.Verify
end
