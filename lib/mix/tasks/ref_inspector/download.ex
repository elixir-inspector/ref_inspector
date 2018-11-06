defmodule Mix.Tasks.RefInspector.Download do
  @moduledoc """
  Fetches copies of each configured database file.

  The copies will be stored inside the configured path.

  `mix ref_inspector.yaml.download`
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

  defp exit_unconfirmed() do
    Mix.shell().info("Download aborted!")
    :ok
  end

  defp perform_download() do
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
