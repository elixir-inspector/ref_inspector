defmodule Mix.Tasks.Ex_referer.Yaml.Download do
  @moduledoc """
  Fetches a copy of referers.yml from the
  [snowplow referer-parser](https://github.com/snowplow/referer-parser)
  project.

  The copy will be stored inside your MIX_HOME (defaults to ~/.mix).

  `mix ex_referer.yaml.download`
  """

  use Mix.Task

  @yaml_url "https://raw.github.com/snowplow/referer-parser/master/resources/referers.yml"
  @shortdoc "Downloads referers.yml"

  def run(_args) do
    Mix.shell.info("Download path: #{ Mix.ExReferer.local_yaml() }")

    if File.regular?(Mix.ExReferer.local_yaml()) do
      if Mix.shell.yes?("Overwrite existing referers.yml?") do
        download_yaml()
      end
    else
      if Mix.shell.yes?("Download referers.yml?") do
        download_yaml()
      end
    end
  end

  defp download_yaml() do
    File.mkdir_p! Path.dirname(Mix.ExReferer.local_yaml())
    File.write! Mix.ExReferer.local_yaml(), Mix.Utils.read_path!(@yaml_url)
  end
end