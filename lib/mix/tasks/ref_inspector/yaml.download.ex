defmodule Mix.Tasks.RefInspector.Yaml.Download do
  @moduledoc false
  @shortdoc  "Downloads database files"

  use Mix.Task

  defdelegate run(args), to: Mix.RefInspector.Yaml.Download
end
