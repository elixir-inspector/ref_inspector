defmodule RefInspector.Database.Loader do
  @moduledoc """
  Locates a database file and reads the (yaml) contents.
  """

  @doc """
  Returns the yaml contents of a database file.
  """
  @spec load(Path.t()) :: list | {:error, term}
  def load(file) do
    case File.regular?(file) do
      true ->
        file
        |> :yamerl_constr.file([:str_node_as_binary])
        |> maybe_hd()

      false ->
        {:error, "invalid file given: '#{file}'"}
    end
  end

  defp maybe_hd([data | _]), do: data
  defp maybe_hd(_), do: []
end
