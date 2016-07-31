defmodule Mix.Tasks.RefInspector.Yaml.Download do
  @moduledoc false
  @shortdoc  "Downloads referers.yml"

  use Mix.Task

  defdelegate run(args), to: Mix.RefInspector.Yaml.Download
end
