defmodule Mix.RefInspector.Yaml.Download do
  @moduledoc """
  Fetches copies of each configured database file.

  The copies will be stored inside the configured path.

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

    Enum.each Config.yaml_urls, fn (config) ->
      local  = local_path(config)
      remote = remote_path(config)

      { :ok, content } = Download.read_remote(remote)

      File.write(local, content)
    end
  end

  defp local_path({ local, _remote }) do
    Path.join([ Config.database_path, local ])
  end

  defp local_path(remote) do
    Path.join([ Config.database_path, Path.basename(remote) ])
  end

  defp remote_path({ _local, remote }), do: remote
  defp remote_path(remote),             do: remote
end
