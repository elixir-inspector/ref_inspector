defmodule Mix.RefInspector.Verify.Fixture do
  @moduledoc """
  Utility module to bundle/download the verification fixture.
  """

  alias RefInspector.Config
  alias RefInspector.Database.Location

  @local "referer-tests.json"
  @remote "https://raw.githubusercontent.com/snowplow-referer-parser/referer-parser/master/resources/referer-tests.json"

  def download do
    Mix.shell().info("Download path: #{Config.database_path()}")

    setup()
    download_fixture()

    Mix.shell().info("Download complete!")
    :ok
  end

  def download_fixture do
    Mix.shell().info(".. downloading: #{@local}")

    {:ok, content} = Config.downloader_adapter().read_remote(@remote)

    File.write!(local_file(), content)
  end

  def local_file, do: Location.local(@local)
  def setup, do: File.mkdir_p!(Config.database_path())
end
