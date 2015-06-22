defmodule Mix.Tasks.RefInspector.Yaml.Download do
  @moduledoc """
  Fetches a copy of referers.yml from the
  [snowplow referer-parser](https://github.com/snowplow/referer-parser)
  project.

  The copy will be stored inside your configured path.

  `mix ref_inspector.yaml.download`
  """

  use Mix.Task

  alias RefInspector.Config


  if Version.match?(System.version, ">= 1.0.3") do
    # ensures "mix help" displays a proper task
    @shortdoc "Downloads referers.yml"
  end

  @yaml_url "https://raw.githubusercontent.com/snowplow/referer-parser/master/resources/referers.yml"

  def run(args) do
    case Config.yaml_path do
      nil -> exit_unconfigured()
      _   -> do_run(args)
    end
  end


  defp do_run(args) do
    Mix.shell.info "Download path: #{ Config.yaml_path }"
    Mix.shell.info "This command will replace any already existing copy!"

    { opts, _argv, _errors } = OptionParser.parse(args, aliases: [ f: :force ])

    run_confirmed(opts)
  end

  defp exit_unconfigured() do
    Mix.shell.error "Local path not configured."
    Mix.shell.error "See README.md for details."
  end


  defp run_confirmed([ force: true ]), do: run_confirmed(true)

  defp run_confirmed(false) do
    Mix.shell.info "Download aborted!"

    :ok
  end

  defp run_confirmed(true) do
    download_yaml()

    Mix.shell.info "Download complete!"

    :ok
  end

  defp run_confirmed(_) do
    "Download referers.yml?"
    |> Mix.shell.yes?()
    |> run_confirmed()
  end


  defp download_yaml() do
    Config.yaml_path |> Path.dirname() |> File.mkdir_p!
    Config.yaml_path |> File.write!(Mix.Utils.read_path!(@yaml_url))
  end
end

# Underscore naming required by elixir <= 1.0.2
if Version.match?(System.version, "<= 1.0.2") do
  defmodule Mix.Tasks.Ref_inspector.Yaml.Download do
    @moduledoc false
    @shortdoc  "Downloads referers.yml"

    use Mix.Task

    defdelegate run(args), to: Mix.Tasks.RefInspector.Yaml.Download
  end
end
