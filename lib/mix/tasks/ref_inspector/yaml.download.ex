defmodule Mix.Tasks.RefInspector.Yaml.Download do
  @moduledoc """
  Fetches copies of each configured database file.

  The copies will be stored inside the configured path.

  `mix ref_inspector.yaml.download`
  """

  @shortdoc  "Downloads database files"

  alias RefInspector.Config
  alias RefInspector.Downloader


  use Mix.Task


  def run(args) do
    case Config.database_path do
      nil -> exit_unconfigured()
      _   -> do_run(args)
    end
  end


  defp do_run(args) do
    Mix.shell.info "Download paths:"

    Enum.each Config.yaml_urls, fn (yaml) ->
      Mix.shell.info "- #{ Downloader.path_local(yaml) }"
    end

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
    { :ok, _ } = Application.ensure_all_started(:hackney)
    :ok        = Downloader.download()

    Mix.shell.info "Download complete!"

    :ok
  end

  defp run_confirmed(_) do
    "Download referers.yml?"
    |> Mix.shell.yes?()
    |> run_confirmed()
  end
end
