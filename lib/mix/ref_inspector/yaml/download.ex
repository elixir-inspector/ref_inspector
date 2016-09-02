defmodule Mix.RefInspector.Yaml.Download do
  @moduledoc """
  Fetches a copy of referers.yml from the
  [snowplow referer-parser](https://github.com/snowplow/referer-parser)
  project.

  The copy will be stored inside your configured path.

  `mix ref_inspector.yaml.download`
  """

  alias Mix.RefInspector.Download
  alias RefInspector.Config


  @behaviour Mix.Task


  def run(args) do
    case Config.database_path do
      nil -> exit_unconfigured()
      _   -> do_run(args)
    end
  end


  defp do_run(args) do
    Mix.shell.info "Download path: #{ yaml_path() }"
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
    yaml_path() |> Path.dirname() |> File.mkdir_p!

    { :ok, content } = Download.read_remote(Config.yaml_url)

    yaml_path() |> File.write(content)
  end


  defp yaml_path do
    database_file = hd(Config.database_files)
    database_path = Config.database_path

    Path.join([ database_path, database_file ])
  end
end
