defmodule Mix.Tasks.Ref_inspector.Verify.Fixture do
  @moduledoc """
  Utility module to bundle/download the verification fixture.
  """

  @fixture { "referer-tests.json", "https://raw.githubusercontent.com/snowplow/referer-parser/master/resources/referer-tests.json" }

  def download() do
    Mix.shell.info "Download path: #{ download_path }"

    setup()
    download(@fixture)

    Mix.shell.info "Download complete!"
    :ok
  end

  def download({ local, remote }) do
    target = Path.join([ download_path, local ])

    Mix.shell.info ".. downloading: #{ local }"
    File.write! target, Mix.Utils.read_path!(remote)
  end

  def download_path, do: Path.join(__DIR__, "../../../../../database")

  def setup() do
    File.mkdir_p! download_path
  end
end