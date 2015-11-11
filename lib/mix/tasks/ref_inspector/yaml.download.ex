if Version.match?(System.version, ">= 1.0.3") do
  #
  # Elixir 1.0.3 and up requires mixed case module namings.
  #
  defmodule Mix.Tasks.RefInspector.Yaml.Download do
    @moduledoc false
    @shortdoc  "Downloads referers.yml"

    use Mix.Task

    defdelegate run(args), to: Mix.RefInspector.Yaml.Download
  end
else
  #
  # Elixir 1.0.2 requires the underscore module naming.
  #
  defmodule Mix.Tasks.Ref_inspector.Yaml.Download do
    @moduledoc false
    @shortdoc  "Downloads referers.yml"

    use Mix.Task

    defdelegate run(args), to: Mix.RefInspector.Yaml.Download
  end
end
