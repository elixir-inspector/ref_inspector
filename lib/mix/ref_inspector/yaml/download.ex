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
    Mix.shell.info "Download paths:"
    Enum.each Config.yaml_urls, &( Mix.shell.info "- #{ local_path(&1) }" )
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
    File.mkdir_p! Config.database_path

    Enum.each Config.yaml_urls, fn (yaml_url) ->
      { :ok, content } = Download.read_remote(yaml_url)

      yaml_url |> local_path() |> File.write(content)
    end
  end


  defp local_path(url) do
    database_file = Path.basename(url)
    database_path = Config.database_path

    Path.join([ database_path, database_file ])
  end
end
