defmodule RefInspector.Database.Loader do
  @moduledoc false

  alias RefInspector.Config

  @doc """
  Returns the yaml contents of a database file.
  """
  @spec load(Path.t()) :: {:ok, list} | {:error, File.posix()}
  def load(file) do
    case File.stat(file) do
      {:ok, _} ->
        {reader_mod, reader_fun, reader_extra_args} = Config.yaml_file_reader()

        reader_mod
        |> apply(reader_fun, [file | reader_extra_args])
        |> maybe_hd()

      error ->
        error
    end
  end

  defp maybe_hd([]), do: {:ok, []}
  defp maybe_hd([data | _]), do: {:ok, data}
end
