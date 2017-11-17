defmodule Mix.Tasks.RefInspector.Yaml.Download do
  @moduledoc false
  @shortdoc false

  use Mix.Task

  def run(args) do
    Mix.shell().info("The mix task you are using has been renamed.")
    Mix.shell().info("Please use 'mix ref_inspector.download' in the future.")
    Mix.shell().info("The old task will cease to function in a future release.")

    Mix.Tasks.RefInspector.Download.run(args)
  end
end
