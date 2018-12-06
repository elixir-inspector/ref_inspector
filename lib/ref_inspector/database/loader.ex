defmodule RefInspector.Database.Loader do
  @moduledoc false

  alias RefInspector.Config

  @doc """
  Returns the yaml contents of a database file.
  """
  @spec load(Path.t()) :: list | {:error, term}
  def load(file) do
    case File.regular?(file) do
      true ->
        {reader_mod, reader_fun, reader_extra_args} = Config.yaml_file_reader()

        apply(reader_mod, reader_fun, [file | reader_extra_args])
        |> maybe_hd()

      false ->
        {:error, "invalid file given: '#{file}'"}
    end
  end

  defp maybe_hd([data | _]), do: data
  defp maybe_hd(_), do: []
end
