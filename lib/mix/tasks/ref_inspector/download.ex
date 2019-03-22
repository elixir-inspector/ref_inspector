defmodule Mix.Tasks.RefInspector.Download do
  @moduledoc """
  Mix task to download database file(s) from your command line.

  ## Arguments

  When run without arguments the task will display the target directory for the
  downloaded files and will ask for confirmation before downloading.

  - `--force`: skip confirmation before downloading

  ## Informational README

  If you are using the default databases from the default remote location an
  informational README with the filename `ref_inspector.readme.md` will be
  placed next to the downloaded file(s). Inside you will find a link to the
  original database source.

  The creation of this file can be deactivated by configuration:

      config :ref_inspector,
        skip_download_readme: true
  """

  @shortdoc "Downloads database files"

  alias RefInspector.Config
  alias RefInspector.Downloader

  use Mix.Task

  @cli_options [
    aliases: [f: :force],
    strict: [force: :boolean]
  ]

  def run(args) do
    :ok = Config.init_env()

    Mix.shell().info("Download paths:")

    Enum.each(Config.yaml_urls(), fn yaml ->
      Mix.shell().info("- #{Downloader.path_local(yaml)}")
    end)

    Mix.shell().info("This command will replace any already existing copy!")

    if request_confirmation(args) do
      perform_download()
    else
      exit_unconfirmed()
    end
  end

  defp exit_unconfirmed do
    Mix.shell().info("Download aborted!")
    :ok
  end

  defp perform_download do
    :ok = Downloader.download()
    :ok = Downloader.README.write()

    Mix.shell().info("Download complete!")
    :ok
  end

  defp request_confirmation(args) do
    {opts, _argv, _errors} = OptionParser.parse(args, @cli_options)

    case opts[:force] do
      true -> true
      _ -> Mix.shell().yes?("Download databases?")
    end
  end
end
