defmodule RefInspector.Downloader.README do
  @moduledoc false

  alias RefInspector.Config
  alias RefInspector.Database.Location

  @readme "ref_inspector.readme.md"

  @doc """
  Writes the informational README file if remote database is the default.
  """
  @spec write() :: :ok
  def write do
    default? = Config.default_remote_database?()
    readme? = !Config.get(:skip_download_readme)

    if default? && readme? do
      do_write()
    else
      :ok
    end
  end

  defp do_write do
    readme_local = Location.local(@readme)
    readme_priv = Application.app_dir(:ref_inspector, ["priv", @readme])

    dirname_local = Path.dirname(readme_local)

    unless File.dir?(dirname_local) do
      File.mkdir_p!(dirname_local)
    end

    _ =
      unless readme_priv == readme_local do
        File.copy!(readme_priv, readme_local)
      end

    :ok
  end
end
