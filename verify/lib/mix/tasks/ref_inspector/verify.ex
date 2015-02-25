defmodule Mix.Tasks.Ref_inspector.Verify do
  use Mix.Task

  alias Mix.Tasks.Ref_inspector.Verify

  def run(_args) do
    :ok = Verify.Fixture.download()

    :ok
  end
end
