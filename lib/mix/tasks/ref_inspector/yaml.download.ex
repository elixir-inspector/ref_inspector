defmodule Mix.Tasks.Ref_inspector.Yaml.Download do
  @moduledoc """
  Fetches a copy of referers.yml from the
  [snowplow referer-parser](https://github.com/snowplow/referer-parser)
  project.

  The copy will be stored inside your configured path.

  `mix ref_inspector.yaml.download`
  """

  use Mix.Task

  @yaml_url "https://raw.githubusercontent.com/snowplow/referer-parser/master/resources/referers.yml"
  @shortdoc "Downloads referers.yml"

  def run(args) do
    Mix.shell.info "Download path: #{ local_yaml }"
    Mix.shell.info "This command will replace any already existing copy!"

    { opts, _argv, _errors } = OptionParser.parse(args, aliases: [ f: :force ])

    run_confirmed(opts)

    Mix.shell.info "Download complete!"
  end

  defp run_confirmed([ force: true ]), do: run_confirmed(true)
  defp run_confirmed(false),           do: :ok
  defp run_confirmed(true)             do
    download_yaml()
  end
  defp run_confirmed(_) do
    "Download referers.yml?"
    |> Mix.shell.yes?()
    |> run_confirmed()
  end

  defp download_yaml() do
    local_yaml |> Path.dirname() |> File.mkdir_p!
    local_yaml |> File.write!(Mix.Utils.read_path!(@yaml_url))
  end

  defp local_yaml, do: Application.get_env(:ref_inspector, :yaml)
end
