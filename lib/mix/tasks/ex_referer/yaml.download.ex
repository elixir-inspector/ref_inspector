defmodule Mix.Tasks.Ex_referer.Yaml.Download do
  use Mix.Task

  @yaml_repo "https://github.com/snowplow/referer-parser"
  @yaml_url  "https://raw.github.com/snowplow/referer-parser/master/resources/referers.yml"
  @shortdoc  "Downloads referers.yml"

  @moduledoc """
  Fetch a copy of referers.yml from #{ @yaml_repo }.
  The copy will be stored inside your MIX_HOME (defaults to ~/.mix).

  Full path to your copy: MIX_HOME/ex_referer/referers.yml

  `mix ex_referer.yaml.download`
  """

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