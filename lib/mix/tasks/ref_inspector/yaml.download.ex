defmodule Mix.Tasks.Ref_inspector.Yaml.Download do
  @moduledoc """
  Fetches a copy of referers.yml from the
  [snowplow referer-parser](https://github.com/snowplow/referer-parser)
  project.

  The copy will be stored inside your MIX_HOME (defaults to ~/.mix).

  `mix ref_inspector.yaml.download`
  """

  use Mix.Task

  @yaml_url "https://raw.github.com/snowplow/referer-parser/master/resources/referers.yml"
  @shortdoc "Downloads referers.yml"

  def run(args) do
    Mix.shell.info "Download path: #{ Mix.RefInspector.local_yaml() }"
    Mix.shell.info "This command will replace any already existing copy!"

    { opts, _argv, _errors } = OptionParser.parse(args, aliases: [ f: :force ])

    run_confirmed(opts)

    Mix.shell.info "Download complete!"
  end

  defp run_confirmed([ force: true ]), do: run_confirmed(true)
  defp run_confirmed(false), do: :ok
  defp run_confirmed(true) do
    download_yaml()
  end
  defp run_confirmed(_) do
    Mix.shell.yes?("Download referers.yml?")
      |> run_confirmed()
  end

  defp download_yaml() do
    File.mkdir_p! Path.dirname(Mix.RefInspector.local_yaml())
    File.write! Mix.RefInspector.local_yaml(), Mix.Utils.read_path!(@yaml_url)
  end
end
